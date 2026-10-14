import Foundation

/// One Codable root. Islands, Books, Sessions, Runs, and Rhumbs are not types.
/// This record is the single chart: bond, live fold, marks, refusals, and pairs.
struct SpreadRecord: Codable, Sendable, Equatable {
    static let currentSchema = 1

    var schemaVersion: Int
    var bond: Bond
    var fold: SpreadFold
    var liveDaykey: Int
    var postA: PostAMark?
    var postB: PostBMark?
    var pairsByDaykey: [String: PairEntry]
    var earlyMarks: [EarlyMark]
    var echoMarks: [EchoMark]
    var onboardingComplete: Bool

    static func blank(now: Date = Date(), calendar: Calendar = .current) -> SpreadRecord {
        SpreadRecord(
            schemaVersion: currentSchema,
            bond: .empty,
            fold: .blank,
            liveDaykey: Daykey.from(now, calendar: calendar),
            postA: nil,
            postB: nil,
            pairsByDaykey: [:],
            earlyMarks: [],
            echoMarks: [],
            onboardingComplete: false
        )
    }

    var shelf: Shelf { Shelf(pairsByDaykey: pairsByDaykey) }

    enum CodingKeys: String, CodingKey {
        case schemaVersion
        case bond
        case fold
        case liveDaykey
        case postA
        case postB
        case pairsByDaykey
        case earlyMarks
        case echoMarks
        case onboardingComplete
    }

    init(
        schemaVersion: Int,
        bond: Bond,
        fold: SpreadFold,
        liveDaykey: Int,
        postA: PostAMark?,
        postB: PostBMark?,
        pairsByDaykey: [String: PairEntry],
        earlyMarks: [EarlyMark],
        echoMarks: [EchoMark],
        onboardingComplete: Bool
    ) {
        self.schemaVersion = schemaVersion
        self.bond = bond
        self.fold = fold
        self.liveDaykey = liveDaykey
        self.postA = postA
        self.postB = postB
        self.pairsByDaykey = pairsByDaykey
        self.earlyMarks = earlyMarks
        self.echoMarks = echoMarks
        self.onboardingComplete = onboardingComplete
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let version = try container.decode(Int.self, forKey: .schemaVersion)
        switch version {
        case 1:
            schemaVersion = version
            bond = try container.decode(Bond.self, forKey: .bond)
            fold = try container.decode(SpreadFold.self, forKey: .fold)
            liveDaykey = try container.decode(Int.self, forKey: .liveDaykey)
            postA = try container.decodeIfPresent(PostAMark.self, forKey: .postA)
            postB = try container.decodeIfPresent(PostBMark.self, forKey: .postB)
            pairsByDaykey = try container.decode([String: PairEntry].self, forKey: .pairsByDaykey)
            earlyMarks = try container.decode([EarlyMark].self, forKey: .earlyMarks)
            echoMarks = try container.decode([EchoMark].self, forKey: .echoMarks)
            onboardingComplete = try container.decode(Bool.self, forKey: .onboardingComplete)
        default:
            throw DecodingError.dataCorruptedError(
                forKey: .schemaVersion,
                in: container,
                debugDescription: "Unknown spread schema \(version)"
            )
        }
    }
}

enum MarkResult: Sendable, Equatable {
    case accepted(SpreadFold)
    case refusedEarly(EarlyMark)
    case refusedEcho(EchoMark)
    case refusedBlank
    case refusedEmpty
}

enum PeelResult: Sendable, Equatable {
    case peeled(SpreadFold)
    case refused
}
