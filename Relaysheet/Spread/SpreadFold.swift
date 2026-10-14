import Foundation

/// Relay fold over today's Prompt. Idle accepts PostA, PostedA accepts PostB,
/// Stitched has already filed a PairEntry. Blank is an empty bond.
enum SpreadFold: String, Codable, Sendable, Equatable {
    case blank
    case idle
    case postedA
    case stitched
}

enum Daykey {
    /// YYYYMMDD from `Calendar.startOfDay`.
    static func from(_ date: Date, calendar: Calendar = .current) -> Int {
        let start = calendar.startOfDay(for: date)
        let parts = calendar.dateComponents([.year, .month, .day], from: start)
        let year = parts.year ?? 0
        let month = parts.month ?? 0
        let day = parts.day ?? 0
        return year * 10_000 + month * 100 + day
    }

    static func date(from daykey: Int, calendar: Calendar = .current) -> Date? {
        let year = daykey / 10_000
        let month = (daykey / 100) % 100
        let day = daykey % 100
        var parts = DateComponents()
        parts.year = year
        parts.month = month
        parts.day = day
        guard let date = calendar.date(from: parts) else { return nil }
        return calendar.startOfDay(for: date)
    }
}
