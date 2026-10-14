import Foundation

/// Stitched spread filed under a daykey once both seats have posted.
struct PairEntry: Codable, Sendable, Equatable, Identifiable {
    var id: String
    var daykey: Int
    var promptID: String
    var markA: PostAMark
    var markB: PostBMark

    init(daykey: Int, promptID: String, markA: PostAMark, markB: PostBMark) {
        self.id = "pair-\(daykey)"
        self.daykey = daykey
        self.promptID = promptID
        self.markA = markA
        self.markB = markB
    }
}
