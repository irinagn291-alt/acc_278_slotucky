import Foundation

/// Refusal recorded when Seat A posts again while the fold is already PostedA.
struct EchoMark: Codable, Sendable, Equatable, Identifiable {
    var id: String
    var daykey: Int
    var attemptedText: String

    init(id: String = UUID().uuidString, daykey: Int, attemptedText: String) {
        self.id = id
        self.daykey = daykey
        self.attemptedText = attemptedText
    }
}
