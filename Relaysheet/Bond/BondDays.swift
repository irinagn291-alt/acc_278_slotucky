import Foundation

/// Bond days are the calendar span from startOfDay(bondedAt) to startOfDay(now).
/// Milestone counts at 7, 30, 90, and 365 come from stitched PairEntry records.
enum BondDays {
    static let milestones = [7, 30, 90, 365]

    static func span(now: Date, bondedAt: Date, calendar: Calendar = .current) -> Int {
        let start = calendar.startOfDay(for: bondedAt)
        let end = calendar.startOfDay(for: now)
        return calendar.dateComponents([.day], from: start, to: end).day ?? 0
    }

    /// How many stitched spreads are at least `threshold` days old.
    static func milestoneCounts(
        pairs: [PairEntry],
        now: Date,
        calendar: Calendar = .current
    ) -> [Int: Int] {
        var counts: [Int: Int] = [:]
        for threshold in milestones {
            counts[threshold] = 0
        }
        let today = calendar.startOfDay(for: now)
        for entry in pairs {
            guard let posted = Daykey.date(from: entry.daykey, calendar: calendar) else { continue }
            let age = calendar.dateComponents([.day], from: posted, to: today).day ?? 0
            for threshold in milestones where age >= threshold {
                counts[threshold, default: 0] += 1
            }
        }
        return counts
    }
}
