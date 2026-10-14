import Foundation

/// Two-beat prompt. Part A is visible on Seat A. Part B stays shuttered until PostedA.
struct Prompt: Codable, Sendable, Equatable, Identifiable {
    var id: String
    var partA: String
    var partB: String
}
