import Foundation

/// Newest-first shelf of stitched PairEntry values. The filmstrip reads this, not storage.
struct Shelf: Sendable, Equatable {
    var entries: [PairEntry]

    init(pairsByDaykey: [String: PairEntry]) {
        entries = pairsByDaykey.values.sorted { $0.daykey > $1.daykey }
    }

    func entry(daykey: Int) -> PairEntry? {
        entries.first { $0.daykey == daykey }
    }
}
