import SwiftUI

/// Shelf sheet. Browses stitched PairEntry records and returns one to the diptych.
struct ShelfSheet: View {
    var session: SpreadSession
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Group {
                if let recovery = session.recoveryMessage, session.shelf.entries.isEmpty {
                    EmptySpreadPage(
                        imageName: "rls_EmptyList",
                        title: "The shelf could not open",
                        line: recovery,
                        action: "Try again"
                    ) {
                        Task { await session.retryLoad() }
                    }
                } else if session.shelf.entries.isEmpty {
                    EmptySpreadPage(
                        imageName: "rls_EmptyList",
                        title: "Nothing stitched yet",
                        line: "Two halves. Write the first line.",
                        action: "Back to the spread"
                    ) {
                        dismiss()
                    }
                } else {
                    populated
                }
            }
            .background(Tone.background.ignoresSafeArea())
            .navigationTitle("Nights")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                        .accessibilityLabel("Close shelf")
                }
            }
        }
    }

    private var populated: some View {
        ScrollView {
            LazyVStack(spacing: Space.s2) {
                ForEach(Array(session.shelf.entries.enumerated()), id: \.element.id) { index, entry in
                    let when = CountText.day(entry.daykey)
                    Button {
                        session.focusedDaykey = entry.daykey
                        dismiss()
                    } label: {
                        VStack(alignment: .leading, spacing: Space.s1) {
                            Text(when)
                                .font(TypeScale.headline)
                                .foregroundStyle(Tone.ink)
                            Text(entry.markA.text)
                                .font(TypeScale.body)
                                .foregroundStyle(Tone.ink)
                                .lineLimit(3)
                                .multilineTextAlignment(.leading)
                            Text(entry.markB.text)
                                .font(TypeScale.body)
                                .foregroundStyle(Tone.ink)
                                .lineLimit(3)
                                .multilineTextAlignment(.leading)
                            Text("Open this night")
                                .font(TypeScale.headline)
                                .foregroundStyle(Tone.accent)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .multilineTextAlignment(.leading)
                    }
                    .buttonStyle(SpreadPressStyle(kind: .quiet))
                    .staggerIn(index)
                    .accessibilityLabel("Open night \(when)")
                }
            }
            .padding(Space.s2)
        }
    }
}
