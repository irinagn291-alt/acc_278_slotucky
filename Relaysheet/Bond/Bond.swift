import Foundation

/// Names, frame colors, and the day the two seats bonded. An empty bond is Blank.
struct Bond: Codable, Sendable, Equatable {
    var bondedAt: Date?
    var seatAName: String
    var seatBName: String
    /// Token names from the colour accessor, never raw hex.
    var seatAColor: String
    var seatBColor: String

    static let empty = Bond(bondedAt: nil, seatAName: "", seatBName: "", seatAColor: "accent", seatBColor: "ink")

    var isEmpty: Bool { bondedAt == nil }
}
