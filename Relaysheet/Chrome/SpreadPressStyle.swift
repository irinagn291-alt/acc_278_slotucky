import SwiftUI

/// One button style for the spread. Primary is filled and bordered. Peel uses the destructive kind.
struct SpreadPressStyle: ButtonStyle {
    enum Kind {
        case primary
        case destructive
        case selected
        case error
        case quiet
    }

    var kind: Kind = .primary
    var loading: Bool = false
    var compact: Bool = false

    func makeBody(configuration: Configuration) -> some View {
        SpreadPressBody(configuration: configuration, kind: kind, loading: loading, compact: compact)
    }
}

private struct SpreadPressBody: View {
    let configuration: ButtonStyleConfiguration
    var kind: SpreadPressStyle.Kind
    var loading: Bool
    var compact: Bool
    @Environment(\.isEnabled) private var isEnabled

    var body: some View {
        HStack(spacing: Space.s1) {
            if loading {
                ProgressView()
                    .tint(foreground)
            }
            configuration.label
                .font(TypeScale.headline)
                .multilineTextAlignment(.center)
        }
        .foregroundStyle(foreground)
        .frame(
            minWidth: Measure.hit,
            maxWidth: compact ? Measure.hit : .infinity,
            minHeight: Measure.hit
        )
        .padding(.horizontal, compact ? 0 : Space.s2)
        .background(background, in: RoundedRectangle(cornerRadius: Radius.chip, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: Radius.chip, style: .continuous)
                .stroke(border, lineWidth: Measure.stroke)
        )
        .opacity(configuration.isPressed ? 0.72 : 1)
        .contentShape(RoundedRectangle(cornerRadius: Radius.chip, style: .continuous))
        .accessibilityAddTraits(kind == .selected ? .isSelected : [])
    }

    private var foreground: Color {
        switch kind {
        case .primary:
            return Tone.background
        case .destructive, .quiet, .error, .selected:
            return Tone.ink
        }
    }

    private var background: Color {
        if !isEnabled || loading {
            return Tone.surface
        }
        switch kind {
        case .primary:
            return Tone.accent
        case .selected:
            return Tone.surface
        case .error:
            return Tone.surface
        case .destructive, .quiet:
            return Tone.surface
        }
    }

    private var border: Color {
        if !isEnabled {
            return Tone.muted.opacity(0.45)
        }
        switch kind {
        case .primary:
            return Tone.accent
        case .selected:
            return Tone.accent
        case .error:
            return Tone.ink
        case .destructive:
            return Tone.ink
        case .quiet:
            return Tone.muted
        }
    }
}

struct StaggerIn: ViewModifier {
    var index: Int
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var shown = false

    func body(content: Content) -> some View {
        content
            .opacity(shown ? 1 : 0)
            .offset(y: shown || reduceMotion ? 0 : Space.s1)
            .onAppear {
                let delay = reduceMotion ? 0 : Motion.delay(index: index)
                withAnimation(.easeOut(duration: Motion.fade).delay(delay)) {
                    shown = true
                }
            }
    }
}

extension View {
    func staggerIn(_ index: Int) -> some View {
        modifier(StaggerIn(index: index))
    }
}
