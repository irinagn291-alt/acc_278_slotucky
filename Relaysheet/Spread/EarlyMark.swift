import Foundation

/// Refusal recorded when Seat B posts while the fold is still Idle.
struct EarlyMark: Codable, Sendable, Equatable, Identifiable {
    var id: String
    var daykey: Int
    var attemptedText: String

    init(id: String = UUID().uuidString, daykey: Int, attemptedText: String) {
        self.id = id
        self.daykey = daykey
        self.attemptedText = attemptedText
    }
}
