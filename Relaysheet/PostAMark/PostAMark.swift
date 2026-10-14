import Foundation

/// SeatAMark. Text plus optional frame markup. Folding Idle to PostedA writes this mark.
struct PostAMark: Codable, Sendable, Equatable, Identifiable {
    var id: String
    var daykey: Int
    var text: String
    var frameMarkup: FrameMarkup?

    init(id: String = UUID().uuidString, daykey: Int, text: String, frameMarkup: FrameMarkup? = nil) {
        self.id = id
        self.daykey = daykey
        self.text = text
        self.frameMarkup = frameMarkup
    }
}
