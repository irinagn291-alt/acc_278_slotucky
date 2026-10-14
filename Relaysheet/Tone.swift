import SwiftUI

/// Colour, type, space, radius, and motion. Views reach tokens only through here.
enum Tone {
    static var background: Color { DesignTokens.bg }
    static var surface: Color { DesignTokens.surface }
    static var ink: Color { DesignTokens.ink }
    static var accent: Color { DesignTokens.accent }
    static var muted: Color { DesignTokens.muted }

    static func seat(_ token: String) -> Color {
        token == "ink" ? ink : accent
    }
}

enum TypeScale {
    static func display() -> Font {
        .custom("HoeflerText-Regular", size: 28, relativeTo: .title)
    }

    static var title: Font { .system(.title2, design: .default) }
    static var headline: Font { .system(.headline, design: .default) }
    static var body: Font { .system(.body, design: .default) }
    static var caption: Font { .system(.subheadline, design: .default) }
    static var micro: Font { .system(.caption, design: .default) }
}

enum Space {
    static let unit: CGFloat = 8
    static let s1: CGFloat = 8
    static let s2: CGFloat = 16
    static let s3: CGFloat = 24
    static let s4: CGFloat = 32
    static let s5: CGFloat = 40
    static let s6: CGFloat = 48
    static let s8: CGFloat = 64
    static let s10: CGFloat = 80
    static let rail: CGFloat = 112
    static let frame: CGFloat = 96
    static let canvas: CGFloat = 128
    static let art: CGFloat = 160
}

enum Radius {
    static let card: CGFloat = 20
    static let chip: CGFloat = 12
}

enum Measure {
    static let hit: CGFloat = 44
    static let stroke: CGFloat = 2
}

enum Motion {
    static let step: Double = 0.05
    static let cap: Double = 0.36
    static let fade: Double = 0.28

    static func delay(index: Int) -> Double {
        min(cap, step * Double(index))
    }
}

enum CountText {
    private static let integer: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter
    }()

    static func whole(_ value: Int) -> String {
        integer.string(from: NSNumber(value: value)) ?? "0"
    }

    static func day(_ daykey: Int) -> String {
        guard let date = Daykey.date(from: daykey) else { return whole(daykey) }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }

    static func moment(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}
