import Foundation

/// The only storage seam. Memory is the source of truth. UserDefaults key
/// `rls.spread.v1` and the Application Support file are projections of it.
/// Settings calls `resetAllData()`. The UI does not touch UserDefaults or the file.
@MainActor
final class SpreadStore {
    static let defaultsKey = "rls.spread.v1"
    static let demoKey = "rls.demo.v1"
    static let debounceNanoseconds: UInt64 = 400_000_000

    private(set) var record: SpreadRecord
    private(set) var recoveryMessage: String?
    private let defaults: UserDefaults
    private let disk: SpreadDisk
    private let debounceNanoseconds: UInt64
    private let seedDemo: Bool
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder
    private var saveTask: Task<Void, Never>?
    private var flushTask: Task<Void, Never>?
    private var generation = 0
    private var loaded = false

    init(
        defaults: UserDefaults = .standard,
        fileURL: URL? = nil,
        debounceNanoseconds: UInt64 = SpreadStore.debounceNanoseconds,
        seedDemo: Bool = true,
        now: Date = Date()
    ) {
        self.defaults = defaults
        self.debounceNanoseconds = debounceNanoseconds
        self.seedDemo = seedDemo
        let url = fileURL ?? SpreadStore.defaultFileURL()
        self.disk = SpreadDisk(fileURL: url)
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        self.encoder = encoder
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        decoder.keyDecodingStrategy = .useDefaultKeys
        self.decoder = decoder
        self.record = .blank(now: now)
    }

    func load(now: Date = Date(), calendar: Calendar = .current) async {
        let primary = await readData(backup: false)
        if let data = primary.data, let decoded = decode(data) {
            record = decoded
            recoveryMessage = nil
        } else if primary.failed || primary.data != nil {
            let backup = await readData(backup: true)
            let backupDecoded = backup.data.flatMap { decode($0) }
            if let decoded = backupDecoded {
                record = decoded
                recoveryMessage = "The spread file was unreadable. Restored the previous copy."
            } else if let data = defaults.data(forKey: Self.defaultsKey), let decoded = decode(data) {
                record = decoded
                recoveryMessage = "The spread file was unreadable. Restored the saved copy."
            } else {
                record = .blank(now: now, calendar: calendar)
                recoveryMessage = "The spread file was unreadable. Started from a blank bond."
            }
        }
        applySeedIfNeeded(now: now, calendar: calendar)
        reconcileDay(now: now, calendar: calendar)
        if record.bond.isEmpty {
            record.fold = .blank
        }
        loaded = true
    }

    /// Post on Seat A. Idle folds to PostedA. A second post records EchoMark and stays PostedA.
    @discardableResult
    func postA(text: String, frameMarkup: FrameMarkup? = nil, now: Date = Date(), calendar: Calendar = .current) -> MarkResult {
        reconcileDay(now: now, calendar: calendar)
        if record.bond.isEmpty {
            record.fold = .blank
            return .refusedBlank
        }
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return .refusedEmpty }
        let daykey = record.fold == .postedA ? record.liveDaykey : Daykey.from(now, calendar: calendar)
        switch record.fold {
        case .blank:
            return .refusedBlank
        case .stitched:
            return .refusedBlank
        case .idle:
            let mark = PostAMark(daykey: daykey, text: trimmed, frameMarkup: frameMarkup)
            record.liveDaykey = daykey
            record.postA = mark
            record.postB = nil
            record.fold = .postedA
            scheduleSave()
            return .accepted(.postedA)
        case .postedA:
            let echo = EchoMark(daykey: record.liveDaykey, attemptedText: trimmed)
            record.echoMarks.append(echo)
            scheduleSave()
            return .refusedEcho(echo)
        }
    }

    /// Post on Seat B. PostedA folds to Stitched and files PairEntry. Idle records EarlyMark.
    @discardableResult
    func postB(text: String, frameMarkup: FrameMarkup? = nil, now: Date = Date(), calendar: Calendar = .current) -> MarkResult {
        reconcileDay(now: now, calendar: calendar)
        if record.bond.isEmpty {
            record.fold = .blank
            return .refusedBlank
        }
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return .refusedEmpty }
        switch record.fold {
        case .blank, .stitched:
            return .refusedBlank
        case .idle:
            let early = EarlyMark(daykey: Daykey.from(now, calendar: calendar), attemptedText: trimmed)
            record.earlyMarks.append(early)
            scheduleSave()
            return .refusedEarly(early)
        case .postedA:
            guard let markA = record.postA else { return .refusedBlank }
            let markB = PostBMark(daykey: record.liveDaykey, text: trimmed, frameMarkup: frameMarkup)
            let prompt = PromptDeck.prompt(for: record.liveDaykey)
            let entry = PairEntry(daykey: record.liveDaykey, promptID: prompt.id, markA: markA, markB: markB)
            record.postB = markB
            record.pairsByDaykey[String(record.liveDaykey)] = entry
            record.fold = .stitched
            scheduleSave()
            return .accepted(.stitched)
        }
    }

    /// Drops the last mark before Stitched. Peel of PostA re-shutters Seat B.
    @discardableResult
    func peel() -> PeelResult {
        switch record.fold {
        case .postedA:
            record.postA = nil
            record.postB = nil
            record.fold = .idle
            scheduleSave()
            return .peeled(.idle)
        case .idle, .stitched, .blank:
            return .refused
        }
    }

    func renameSeats(seatAName: String, seatBName: String) {
        let left = seatAName.trimmingCharacters(in: .whitespacesAndNewlines)
        let right = seatBName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard record.bond.bondedAt != nil, !left.isEmpty, !right.isEmpty else { return }
        record.bond.seatAName = left
        record.bond.seatBName = right
        scheduleSave()
    }

    func paintSeats(seatAColor: String, seatBColor: String) {
        guard record.bond.bondedAt != nil else { return }
        record.bond.seatAColor = seatAColor
        record.bond.seatBColor = seatBColor
        scheduleSave()
    }

    /// Writes both seat names, keeps an existing bond date, and marks onboarding done.
    func finishOnboarding(seatAName: String, seatBName: String, now: Date = Date(), calendar: Calendar = .current) {
        let left = seatAName.trimmingCharacters(in: .whitespacesAndNewlines)
        let right = seatBName.trimmingCharacters(in: .whitespacesAndNewlines)
        let seatA = left.isEmpty ? "Ada" : left
        let seatB = right.isEmpty ? "Ren" : right
        if record.bond.isEmpty {
            establishBond(
                bondedAt: calendar.startOfDay(for: now),
                seatAName: seatA,
                seatBName: seatB,
                now: now,
                calendar: calendar
            )
        } else {
            record.bond.seatAName = seatA
            record.bond.seatBName = seatB
        }
        record.onboardingComplete = true
        scheduleSave()
    }

    func reopenOnboarding() {
        record.onboardingComplete = false
        scheduleSave()
    }

    func establishBond(bondedAt: Date, seatAName: String, seatBName: String, now: Date = Date(), calendar: Calendar = .current) {
        record.bond = Bond(
            bondedAt: bondedAt,
            seatAName: seatAName,
            seatBName: seatBName,
            seatAColor: "accent",
            seatBColor: "ink"
        )
        if record.fold == .blank {
            record.fold = .idle
            record.liveDaykey = Daykey.from(now, calendar: calendar)
        }
        scheduleSave()
    }

    func bondDaySpan(now: Date = Date(), calendar: Calendar = .current) -> Int {
        guard let bondedAt = record.bond.bondedAt else { return 0 }
        return BondDays.span(now: now, bondedAt: bondedAt, calendar: calendar)
    }

    func milestoneCounts(now: Date = Date(), calendar: Calendar = .current) -> [Int: Int] {
        BondDays.milestoneCounts(pairs: Array(record.pairsByDaykey.values), now: now, calendar: calendar)
    }

    /// A one-sided day stays on the diptych. Only a stitched fold is on the shelf.
    var oneSidedStaysHome: Bool {
        record.fold == .postedA && record.pairsByDaykey[String(record.liveDaykey)] == nil
    }

    func sceneLeftActive() {
        flushTask?.cancel()
        flushTask = Task { await self.flush() }
    }

    /// Day edges and daylight-saving shifts while the app stays open.
    func noteClock(now: Date = Date(), calendar: Calendar = .current) {
        guard loaded else { return }
        let previousFold = record.fold
        let previousKey = record.liveDaykey
        reconcileDay(now: now, calendar: calendar)
        if record.fold != previousFold || record.liveDaykey != previousKey {
            scheduleSave()
        }
    }

    func flush() async {
        generation += 1
        let token = generation
        saveTask?.cancel()
        saveTask = nil
        await writeProjection(token: token)
    }

    /// Clears the key and the file. Settings reaches this. Tests use it too.
    func resetAllData(now: Date = Date(), calendar: Calendar = .current) async {
        saveTask?.cancel()
        saveTask = nil
        generation += 1
        record = .blank(now: now, calendar: calendar)
        recoveryMessage = nil
        defaults.removeObject(forKey: Self.defaultsKey)
        defaults.removeObject(forKey: Self.demoKey)
        do {
            try await disk.removeAll()
        } catch {
            recoveryMessage = "Reset could not remove the spread file."
        }
    }

    private func scheduleSave() {
        generation += 1
        let token = generation
        saveTask?.cancel()
        let delay = debounceNanoseconds
        saveTask = Task { [weak self] in
            do {
                try await Task.sleep(nanoseconds: delay)
            } catch {
                return
            }
            guard let self else { return }
            await self.writeProjection(token: token)
        }
    }

    private func writeProjection(token: Int) async {
        guard token == generation else { return }
        guard let data = encode(record) else {
            recoveryMessage = "The spread could not be saved."
            return
        }
        do {
            try await disk.writeAtomically(data)
            defaults.set(data, forKey: Self.defaultsKey)
        } catch {
            recoveryMessage = "The spread could not be saved."
        }
    }

    private func encode(_ record: SpreadRecord) -> Data? {
        do {
            return try encoder.encode(record)
        } catch {
            return nil
        }
    }

    private func decode(_ data: Data) -> SpreadRecord? {
        do {
            return try decoder.decode(SpreadRecord.self, from: data)
        } catch {
            return nil
        }
    }

    private struct ReadOutcome {
        var data: Data?
        var failed: Bool
    }

    private func readData(backup: Bool) async -> ReadOutcome {
        do {
            let data = backup ? try await disk.readBackup() : try await disk.readPrimary()
            return ReadOutcome(data: data, failed: false)
        } catch {
            return ReadOutcome(data: nil, failed: true)
        }
    }

    private func reconcileDay(now: Date, calendar: Calendar) {
        let today = Daykey.from(now, calendar: calendar)
        if record.fold == .stitched, record.liveDaykey < today {
            record.fold = .idle
            record.postA = nil
            record.postB = nil
            record.liveDaykey = today
        }
    }

    private func applySeedIfNeeded(now: Date, calendar: Calendar) {
        guard seedDemo else { return }
        #if targetEnvironment(simulator)
        let untouched = record.bond.isEmpty && record.pairsByDaykey.isEmpty && record.postA == nil
        guard untouched else { return }
        seedSimulator(now: now, calendar: calendar)
        defaults.set(true, forKey: Self.demoKey)
        if let data = encode(record) {
            defaults.set(data, forKey: Self.defaultsKey)
        }
        scheduleSave()
        #endif
    }

    private func seedSimulator(now: Date, calendar: Calendar) {
        let bondedAt = calendar.date(byAdding: .day, value: -40, to: calendar.startOfDay(for: now)) ?? now
        record.bond = Bond(
            bondedAt: bondedAt,
            seatAName: "Ada",
            seatBName: "Ren",
            seatAColor: "accent",
            seatBColor: "ink"
        )
        record.onboardingComplete = true
        let today = Daykey.from(now, calendar: calendar)
        let answers = [
            (
                "The porch light was already on when I turned the corner.",
                "I wanted you to see it before I said anything."
            ),
            (
                "Your cup was still on the table this morning.",
                "I left it there. It can stay."
            ),
            (
                "I walked past the river instead of the hill.",
                "Next time we stop where the ducks were."
            ),
            (
                "The window went blue and I did not turn a lamp on.",
                "I hoped you were watching that blue too."
            )
        ]
        let offsets = [-12, -9, -5, -2]
        for (index, offset) in offsets.enumerated() {
            guard let day = calendar.date(byAdding: .day, value: offset, to: calendar.startOfDay(for: now)) else { continue }
            let key = Daykey.from(day, calendar: calendar)
            let prompt = PromptDeck.prompt(for: key)
            let pair = answers[index]
            let markA = PostAMark(daykey: key, text: pair.0)
            let markB = PostBMark(daykey: key, text: pair.1)
            record.pairsByDaykey[String(key)] = PairEntry(daykey: key, promptID: prompt.id, markA: markA, markB: markB)
        }
        record.liveDaykey = today
        record.postA = PostAMark(daykey: today, text: "I thought of you on the stairs, before I meant to.")
        record.postB = nil
        record.fold = .postedA
    }

    private static func defaultFileURL() -> URL {
        let base = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
            ?? URL(fileURLWithPath: NSTemporaryDirectory())
        return base.appendingPathComponent("Slotucky", isDirectory: true).appendingPathComponent("spread.json")
    }
}
