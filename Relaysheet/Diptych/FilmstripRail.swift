import SwiftUI

/// Vertical timeline of stitched PairEntry frames, newest first.
struct FilmstripRail: View {
    var entries: [PairEntry]
    var selected: Int?
    var scrollsInternally: Bool = true
    var onSelect: (Int) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: Space.s1) {
            Text("Nights")
                .font(TypeScale.caption)
                .foregroundStyle(Tone.muted)
            if entries.isEmpty {
                Text("Filed nights show up here.")
                    .font(TypeScale.body)
                    .foregroundStyle(Tone.ink)
                    .frame(maxWidth: .infinity, minHeight: Measure.hit, alignment: .leading)
            } else if scrollsInternally {
                ScrollView { cells }
            } else {
                cells
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }

    private var cells: some View {
        LazyVStack(spacing: Space.s1) {
            ForEach(Array(entries.enumerated()), id: \.element.id) { index, entry in
                let when = CountText.day(entry.daykey)
                Button {
                    onSelect(entry.daykey)
                } label: {
                    FilmstripCell(entry: entry, selected: selected == entry.daykey)
                }
                .buttonStyle(SpreadPressStyle(kind: selected == entry.daykey ? .selected : .quiet))
                .staggerIn(index)
                .accessibilityLabel("Open night \(when)")
            }
        }
    }
}

private struct FilmstripCell: View {
    var entry: PairEntry
    var selected: Bool

    var body: some View {
        HStack(spacing: Space.s2) {
            ZStack {
                Tone.surface
                Text(CountText.whole(entry.daykey % 100))
                    .font(TypeScale.headline)
                    .foregroundStyle(Tone.accent)
            }
            .frame(width: Space.s8, height: Space.s8)
            .clipShape(RoundedRectangle(cornerRadius: Radius.chip, style: .continuous))
            VStack(alignment: .leading, spacing: Space.s1) {
                Text(CountText.day(entry.daykey))
                    .font(TypeScale.caption)
                    .foregroundStyle(Tone.ink)
                    .lineLimit(1)
                Text(entry.markA.text)
                    .font(TypeScale.micro)
                    .foregroundStyle(Tone.muted)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
            }
            Spacer(minLength: 0)
            if selected {
                Text("Selected")
                    .font(TypeScale.micro)
                    .foregroundStyle(Tone.accent)
            }
        }
        .frame(maxWidth: .infinity, minHeight: Measure.hit, alignment: .leading)
        .contentShape(Rectangle())
    }
}
