import Foundation

/// One half of the diptych. Seat A posts first. Seat B stays shuttered until PostedA.
enum Seat: String, Codable, Sendable, Equatable {
    case a
    case b
}
