import Foundation

/// Optional PencilKit margin stored as drawing data. The live canvas stays on the open seat.
struct FrameMarkup: Codable, Sendable, Equatable {
    var drawingData: Data
}
