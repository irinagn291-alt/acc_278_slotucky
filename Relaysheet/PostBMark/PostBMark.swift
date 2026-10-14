import Foundation

/// SeatBMark. Written only from PostedA. Folding to Stitched files the PairEntry.
struct PostBMark: Codable, Sendable, Equatable, Identifiable {
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
