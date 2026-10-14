import XCTest
@testable import Relaysheet

@MainActor
final class RelaysheetTests: XCTestCase {
    private var suite = ""
    private var defaults: UserDefaults?
    private var fileURL: URL?

    override func setUp() {
        super.setUp()
        suite = "rls.tests.\(UUID().uuidString)"
        defaults = UserDefaults(suiteName: suite)
        fileURL = FileManager.default.temporaryDirectory.appendingPathComponent("rls-\(UUID().uuidString).json")
    }

    override func tearDown() {
        if let defaults {
            defaults.removePersistentDomain(forName: suite)
        }
        if let fileURL {
            try? FileManager.default.removeItem(at: fileURL)
            try? FileManager.default.removeItem(at: fileURL.appendingPathExtension("backup"))
        }
        super.tearDown()
    }

    func testBondDaysUseStartOfDayOfNowAndBondedAt() {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0) ?? calendar.timeZone
        let bondedAt = date(2026, 1, 1, 23, calendar: calendar)
        let now = date(2026, 1, 8, 1, calendar: calendar)
        let span = BondDays.span(now: now, bondedAt: bondedAt, calendar: calendar)
        let startOfDay = calendar.dateComponents(
            [.day],
            from: calendar.startOfDay(for: bondedAt),
            to: calendar.startOfDay(for: now)
        ).day
        XCTAssertEqual(span, startOfDay)
        XCTAssertEqual(span, 7)
        let sameMorning = BondDays.span(now: date(2026, 1, 1, 8, calendar: calendar), bondedAt: bondedAt, calendar: calendar)
        XCTAssertEqual(sameMorning, 0)
    }

    func testMilestoneCountsComeFromStitchedPairEntryRecords() {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0) ?? calendar.timeZone
        let now = date(2026, 6, 1, 12, calendar: calendar)
        let old = PairEntry(
            daykey: 20260101,
            promptID: "porch",
            markA: PostAMark(daykey: 20260101, text: "A"),
            markB: PostBMark(daykey: 20260101, text: "B")
        )
        let recent = PairEntry(
            daykey: 20260520,
            promptID: "table",
            markA: PostAMark(daykey: 20260520, text: "A"),
            markB: PostBMark(daykey: 20260520, text: "B")
        )
        let counts = BondDays.milestoneCounts(pairs: [old, recent], now: now, calendar: calendar)
        XCTAssertEqual(counts[7], 2)
        XCTAssertEqual(counts[30], 1)
        XCTAssertEqual(counts[90], 1)
        XCTAssertEqual(counts[365], 0)
    }

    func testPostAThenPostBStitchesPairEntry() async {
        let store = makeStore()
        await store.load(now: date(2026, 3, 2, 12))
        store.establishBond(bondedAt: date(2026, 1, 1, 9), seatAName: "Ada", seatBName: "Ren", now: date(2026, 3, 2, 12))
        let first = store.postA(text: "Porch light", now: date(2026, 3, 2, 12))
        guard case .accepted(.postedA) = first else {
            return XCTFail("expected PostedA")
        }
        XCTAssertTrue(store.oneSidedStaysHome)
        XCTAssertNil(store.record.pairsByDaykey["20260302"])
        let second = store.postB(text: "I wanted to tell you first", now: date(2026, 3, 2, 12))
        guard case .accepted(.stitched) = second else {
            return XCTFail("expected Stitched")
        }
        XCTAssertEqual(store.record.pairsByDaykey["20260302"]?.markB.text, "I wanted to tell you first")
        XCTAssertFalse(store.oneSidedStaysHome)
    }

    func testEarlyMarkWhenSeatBPostsBeforeSeatA() async {
        let store = makeStore()
        await store.load()
        store.establishBond(bondedAt: Date(), seatAName: "Ada", seatBName: "Ren")
        let result = store.postB(text: "Too soon")
        guard case .refusedEarly(let mark) = result else {
            return XCTFail("expected EarlyMark")
        }
        XCTAssertEqual(store.record.fold, .idle)
        XCTAssertEqual(store.record.earlyMarks, [mark])
        XCTAssertTrue(store.record.pairsByDaykey.isEmpty)
    }

    func testEchoMarkOnSecondPostA() async {
        let store = makeStore()
        await store.load()
        store.establishBond(bondedAt: Date(), seatAName: "Ada", seatBName: "Ren")
        _ = store.postA(text: "First line")
        let result = store.postA(text: "Again")
        guard case .refusedEcho = result else {
            return XCTFail("expected EchoMark")
        }
        XCTAssertEqual(store.record.fold, .postedA)
        XCTAssertEqual(store.record.postA?.text, "First line")
        XCTAssertEqual(store.record.echoMarks.count, 1)
    }

    func testPeelDropsPostAAndReshuttersSeatB() async {
        let store = makeStore()
        await store.load()
        store.establishBond(bondedAt: Date(), seatAName: "Ada", seatBName: "Ren")
        _ = store.postA(text: "Rewrite me")
        let peeled = store.peel()
        XCTAssertEqual(peeled, .peeled(.idle))
        XCTAssertNil(store.record.postA)
        XCTAssertEqual(store.peel(), .refused)
    }

    func testEmptyTextAndBlankBondAreRefused() async {
        let store = makeStore()
        await store.load()
        XCTAssertEqual(store.postA(text: "  "), .refusedBlank)
        XCTAssertEqual(store.record.fold, .blank)
        store.establishBond(bondedAt: Date(), seatAName: "Ada", seatBName: "Ren")
        XCTAssertEqual(store.postA(text: "   "), .refusedEmpty)
        XCTAssertEqual(store.record.fold, .idle)
        XCTAssertEqual(store.postB(text: ""), .refusedEmpty)
    }

    func testArchitectureFoldIdlePostedAStitched() async {
        let store = makeStore()
        await store.load(now: date(2026, 4, 4, 10))
        XCTAssertEqual(store.record.fold, .blank)
        store.establishBond(bondedAt: date(2026, 4, 1, 8), seatAName: "Ada", seatBName: "Ren", now: date(2026, 4, 4, 10))
        XCTAssertEqual(store.record.fold, .idle)
        _ = store.postA(text: "A", now: date(2026, 4, 4, 10))
        XCTAssertEqual(store.record.fold, .postedA)
        _ = store.postB(text: "B", now: date(2026, 4, 4, 10))
        XCTAssertEqual(store.record.fold, .stitched)
        XCTAssertEqual(store.record.schemaVersion, 1)
    }

    func testOneSidedDayStaysHomeAcrossMidnight() async {
        let store = makeStore()
        let first = date(2026, 5, 1, 21)
        let next = date(2026, 5, 2, 9)
        await store.load(now: first)
        store.establishBond(bondedAt: date(2026, 4, 1, 8), seatAName: "Ada", seatBName: "Ren", now: first)
        _ = store.postA(text: "Still open", now: first)
        await store.flush()
        let reloaded = makeStore()
        await reloaded.load(now: next)
        XCTAssertEqual(reloaded.record.fold, .postedA)
        XCTAssertEqual(reloaded.record.postA?.text, "Still open")
        XCTAssertTrue(reloaded.oneSidedStaysHome)
        XCTAssertTrue(reloaded.record.pairsByDaykey.isEmpty)
    }

    func testPersistenceRoundTrip() async {
        let store = makeStore()
        await store.load(now: date(2026, 2, 2, 8))
        store.establishBond(bondedAt: date(2026, 1, 1, 8), seatAName: "Ada", seatBName: "Ren", now: date(2026, 2, 2, 8))
        _ = store.postA(text: "Kept", now: date(2026, 2, 2, 8))
        _ = store.postB(text: "Filed", now: date(2026, 2, 2, 8))
        await store.flush()
        let reloaded = makeStore()
        await reloaded.load(now: date(2026, 2, 2, 8))
        XCTAssertEqual(reloaded.record.pairsByDaykey["20260202"]?.markA.text, "Kept")
        XCTAssertEqual(reloaded.record.fold, .stitched)
        XCTAssertEqual(reloaded.bondDaySpan(now: date(2026, 2, 2, 8)), store.bondDaySpan(now: date(2026, 2, 2, 8)))
    }

    func testCorruptFileFallsBackToBackupThenBlank() async throws {
        let store = makeStore()
        await store.load()
        store.establishBond(bondedAt: date(2026, 1, 2, 8), seatAName: "Ada", seatBName: "Ren")
        _ = store.postA(text: "Safe")
        await store.flush()
        guard let fileURL else {
            return XCTFail("missing file")
        }
        try Data("not-json".utf8).write(to: fileURL, options: .atomic)
        let restored = makeStore()
        await restored.load()
        XCTAssertEqual(restored.record.postA?.text, "Safe")
        XCTAssertNotNil(restored.recoveryMessage)

        try Data("still-bad".utf8).write(to: fileURL, options: .atomic)
        try Data("also-bad".utf8).write(to: fileURL.appendingPathExtension("backup"), options: .atomic)
        defaults?.removeObject(forKey: SpreadStore.defaultsKey)
        let blank = makeStore()
        await blank.load()
        XCTAssertEqual(blank.record.fold, .blank)
        XCTAssertNotNil(blank.recoveryMessage)
    }

    func testResetAllDataClearsKey() async {
        let store = makeStore()
        await store.load()
        store.establishBond(bondedAt: Date(), seatAName: "Ada", seatBName: "Ren")
        _ = store.postA(text: "Gone")
        await store.flush()
        await store.resetAllData()
        XCTAssertEqual(store.record.fold, .blank)
        XCTAssertNil(defaults?.data(forKey: SpreadStore.defaultsKey))
        let reloaded = makeStore()
        await reloaded.load()
        XCTAssertEqual(reloaded.record.fold, .blank)
    }

    func testReviewLaunchParsesArguments() {
        XCTAssertEqual(ReviewLaunch.screen(in: ["Relaysheet", "-ReviewScreen", "today"]), "today")
        XCTAssertEqual(ReviewLaunch.screen(in: ["Relaysheet", "-ReviewScreen", "log"]), "log")
        XCTAssertEqual(ReviewLaunch.screen(in: ["Relaysheet", "-ReviewScreen", "goals"]), "goals")
        XCTAssertNil(ReviewLaunch.screen(in: ["Relaysheet"]))
        XCTAssertNil(ReviewLaunch.screen(in: ["Relaysheet", "-ReviewScreen"]))
    }

    func testDaykeyIsYYYYMMDDFromStartOfDay() {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0) ?? calendar.timeZone
        let evening = date(2026, 9, 27, 23, calendar: calendar)
        XCTAssertEqual(Daykey.from(evening, calendar: calendar), 20260927)
    }

    private func makeStore() -> SpreadStore {
        let defaults = self.defaults ?? UserDefaults.standard
        let fileURL = self.fileURL ?? FileManager.default.temporaryDirectory.appendingPathComponent("rls-fallback.json")
        return SpreadStore(defaults: defaults, fileURL: fileURL, debounceNanoseconds: 50_000_000, seedDemo: false)
    }

    private func date(_ year: Int, _ month: Int, _ day: Int, _ hour: Int, calendar: Calendar = .current) -> Date {
        var parts = DateComponents()
        parts.year = year
        parts.month = month
        parts.day = day
        parts.hour = hour
        parts.timeZone = calendar.timeZone
        return calendar.date(from: parts) ?? Date(timeIntervalSince1970: 0)
    }
}
