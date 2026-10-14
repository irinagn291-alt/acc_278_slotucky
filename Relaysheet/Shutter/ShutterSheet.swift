import SwiftUI

/// Twist screen. Post on Seat A, then Seat B, then the spread stitches.
struct ShutterSheet: View {
    var session: SpreadSession
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: Space.s3) {
                    Image("rls_TwistHero")
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity)
                        .frame(height: Space.art)
                        .accessibilityHidden(true)
                    Text("Post the first half, then the reply.")
                        .font(TypeScale.title)
                        .foregroundStyle(Tone.ink)
                        .fixedSize(horizontal: false, vertical: true)
                    Text(statusLine)
                        .font(TypeScale.body)
                        .foregroundStyle(Tone.muted)
                        .fixedSize(horizontal: false, vertical: true)
                    VStack(alignment: .leading, spacing: Space.s2) {
                        step("Waiting", "The first half is written alone. The reply stays closed.")
                        step("Posted", "After that post, the reply and the answer both show.")
                        step("Stitched", "The reply is posted, and the night is filed.")
                    }
                    .padding(Space.s2)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(.regularMaterial, in: RoundedRectangle(cornerRadius: Radius.card, style: .continuous))
                    Text("A one-sided night stays on the spread until both halves land.")
                        .font(TypeScale.body)
                        .foregroundStyle(Tone.ink)
                    Button("Back to the spread") { dismiss() }
                        .buttonStyle(SpreadPressStyle(kind: .primary))
                }
                .padding(Space.s2)
            }
            .background(Tone.background.ignoresSafeArea())
            .navigationTitle("Posting")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
        }
    }

    private var statusLine: String {
        switch session.record.fold {
        case .blank:
            return "Name both people, then write the first half."
        case .idle:
            return "Tonight is waiting on the first half."
        case .postedA:
            return "The first half is posted. The reply can be written now."
        case .stitched:
            return "Tonight is stitched."
        }
    }

    private func step(_ word: String, _ line: String) -> some View {
        VStack(alignment: .leading, spacing: Space.s1) {
            Text(word)
                .font(TypeScale.headline)
                .foregroundStyle(Tone.accent)
            Text(line)
                .font(TypeScale.body)
                .foregroundStyle(Tone.ink)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}
