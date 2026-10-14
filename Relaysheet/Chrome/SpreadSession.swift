import SwiftUI

/// Presentation seam over SpreadStore. Screens read the copied record and never touch the file.
@MainActor
@Observable
final class SpreadSession {
    enum Cover: String, Identifiable {
        case bond
        case shelf
        case settings
        case shutter

        var id: String { rawValue }
    }

    let store: SpreadStore
    private(set) var record: SpreadRecord
    private(set) var recoveryMessage: String?
    private(set) var didLoad = false
    var showSpinner = false
    var cover: Cover?
    var focusedDaykey: Int?
    var notice: String?
    var posting = false
    var successTitle: String?
    private var reviewConsumed = false

    init(store: SpreadStore = SpreadStore()) {
        self.store = store
        self.record = store.record
        self.recoveryMessage = store.recoveryMessage
    }

    func load() async {
        let work = Task { @MainActor in
            await store.load()
            pull()
        }
        try? await Task.sleep(nanoseconds: 150_000_000)
        if !didLoad {
            showSpinner = true
        }
        await work.value
        pull()
        showSpinner = false
        didLoad = true
        openReviewIfNeeded()
    }

    func sceneLeftActive() {
        store.sceneLeftActive()
    }

    func openReviewIfNeeded() {
        guard didLoad, record.onboardingComplete, !reviewConsumed else { return }
        reviewConsumed = true
        switch ReviewLaunch.screen {
        case "log":
            cover = .shelf
        case "goals":
            cover = .bond
        case "settings":
            cover = .settings
        case "shutter":
            cover = .shutter
        default:
            cover = nil
        }
    }

    func post(text: String, drawing: Data) {
        posting = true
        let markup = drawing.isEmpty ? nil : FrameMarkup(drawingData: drawing)
        let result: MarkResult
        switch record.fold {
        case .idle:
            result = store.postA(text: text, frameMarkup: markup)
        case .postedA:
            result = store.postB(text: text, frameMarkup: markup)
        case .blank, .stitched:
            result = .refusedBlank
        }
        pull()
        posting = false
        switch result {
        case .accepted(let fold):
            notice = nil
            focusedDaykey = nil
            successTitle = fold == .stitched ? "Stitched" : "Posted"
            UINotificationFeedbackGenerator().notificationOccurred(.success)
        case .refusedEarly:
            notice = "The first half posts first. This reply was not filed."
        case .refusedEcho:
            notice = "This half is already posted. Peel it if you want a rewrite."
        case .refusedBlank:
            notice = "Name both people before you post."
        case .refusedEmpty:
            notice = "Write a line before you post."
        }
    }

    func noteClock() {
        store.noteClock()
        pull()
    }

    func peel() {
        let result = store.peel()
        pull()
        if case .peeled = result {
            notice = nil
            UINotificationFeedbackGenerator().notificationOccurred(.success)
        }
    }

    func finishOnboarding(seatAName: String, seatBName: String) {
        store.finishOnboarding(seatAName: seatAName, seatBName: seatBName)
        pull()
        openReviewIfNeeded()
    }

    func reopenOnboarding() {
        store.reopenOnboarding()
        pull()
        cover = nil
    }

    func rename(seatAName: String, seatBName: String) {
        store.renameSeats(seatAName: seatAName, seatBName: seatBName)
        pull()
    }

    func paint(seatAColor: String, seatBColor: String) {
        store.paintSeats(seatAColor: seatAColor, seatBColor: seatBColor)
        pull()
    }

    func resetAllData() async {
        await store.resetAllData()
        pull()
        focusedDaykey = nil
        notice = nil
        cover = nil
    }

    func retryLoad() async {
        didLoad = false
        await load()
    }

    var shelf: Shelf { record.shelf }

    var activeSeat: Seat? {
        switch record.fold {
        case .idle:
            return .a
        case .postedA:
            return .b
        case .blank, .stitched:
            return nil
        }
    }

    private func pull() {
        record = store.record
        recoveryMessage = store.recoveryMessage
    }
}
