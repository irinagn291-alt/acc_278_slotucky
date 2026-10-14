import SwiftUI

/// Bond sheet. Seat names, frame colors, bondedAt, bond days, and milestone counts.
struct BondSheet: View {
    var session: SpreadSession
    @Environment(\.dismiss) private var dismiss
    @State private var seatA = ""
    @State private var seatB = ""

    var body: some View {
        NavigationStack {
            Group {
                if let recovery = session.recoveryMessage, session.record.bond.isEmpty {
                    EmptySpreadPage(
                        imageName: "rls_EmptyHome",
                        title: "The file could not be read",
                        line: recovery,
                        action: "Try again"
                    ) {
                        Task { await session.retryLoad() }
                    }
                } else if session.record.bond.isEmpty {
                    EmptySpreadPage(
                        imageName: "rls_EmptyHome",
                        title: "Name both people",
                        line: "Two halves. Write the first line.",
                        action: "Start together"
                    ) {
                        session.finishOnboarding(seatAName: "Ada", seatBName: "Ren")
                    }
                } else {
                    populated
                }
            }
            .background(Tone.background.ignoresSafeArea())
            .navigationTitle("Together")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                        .accessibilityLabel("Close")
                }
            }
        }
        .onAppear {
            seatA = session.record.bond.seatAName
            seatB = session.record.bond.seatBName
        }
    }

    private var populated: some View {
        let daysTogether = CountText.whole(session.store.bondDaySpan())
        let leftName = session.record.bond.seatAName
        let rightName = session.record.bond.seatBName
        let counts = session.store.milestoneCounts()
        let started = session.record.bond.bondedAt.map { CountText.moment($0) }
        return ScrollView {
            VStack(alignment: .leading, spacing: Space.s3) {
                VStack(alignment: .leading, spacing: Space.s2) {
                    Text("\(leftName) and \(rightName)")
                        .font(TypeScale.display())
                        .foregroundStyle(Tone.ink)
                        .fixedSize(horizontal: false, vertical: true)
                    Text("\(daysTogether) days together")
                        .font(TypeScale.title)
                        .foregroundStyle(Tone.accent)
                        .fixedSize(horizontal: false, vertical: true)
                    if let started {
                        Text("Started \(started)")
                            .font(TypeScale.body)
                            .foregroundStyle(Tone.ink)
                    }
                    Text("Save a name change, or close to return to tonight.")
                        .font(TypeScale.body)
                        .foregroundStyle(Tone.muted)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(Space.s3)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Tone.surface, in: RoundedRectangle(cornerRadius: Radius.card, style: .continuous))

                VStack(alignment: .leading, spacing: Space.s2) {
                    Text("Names")
                        .font(TypeScale.headline)
                        .foregroundStyle(Tone.ink)
                    Text(leftName)
                        .font(TypeScale.title)
                        .foregroundStyle(Tone.ink)
                    TextField("First name", text: $seatA)
                        .font(TypeScale.body)
                        .padding(Space.s2)
                        .background(Tone.background, in: RoundedRectangle(cornerRadius: Radius.chip, style: .continuous))
                    Text(rightName)
                        .font(TypeScale.title)
                        .foregroundStyle(Tone.ink)
                    TextField("Reply name", text: $seatB)
                        .font(TypeScale.body)
                        .padding(Space.s2)
                        .background(Tone.background, in: RoundedRectangle(cornerRadius: Radius.chip, style: .continuous))
                    Button("Save names") {
                        session.rename(seatAName: seatA, seatBName: seatB)
                    }
                    .buttonStyle(SpreadPressStyle(kind: .primary))
                    colorRow(
                        title: "First color",
                        current: session.record.bond.seatAColor
                    ) { token in
                        session.paint(seatAColor: token, seatBColor: session.record.bond.seatBColor)
                    }
                    colorRow(
                        title: "Reply color",
                        current: session.record.bond.seatBColor
                    ) { token in
                        session.paint(seatAColor: session.record.bond.seatAColor, seatBColor: token)
                    }
                }
                .padding(Space.s2)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Tone.surface, in: RoundedRectangle(cornerRadius: Radius.card, style: .continuous))

                VStack(alignment: .leading, spacing: Space.s2) {
                    Text("Nights kept")
                        .font(TypeScale.headline)
                        .foregroundStyle(Tone.ink)
                    Text("Stitched spreads that have lasted this long.")
                        .font(TypeScale.body)
                        .foregroundStyle(Tone.muted)
                        .fixedSize(horizontal: false, vertical: true)
                    ForEach(BondDays.milestones, id: \.self) { mark in
                        let days = CountText.whole(mark)
                        let tally = CountText.whole(counts[mark] ?? 0)
                        HStack(alignment: .firstTextBaseline) {
                            Text("\(days) days")
                                .font(TypeScale.body)
                                .foregroundStyle(Tone.ink)
                            Spacer(minLength: Space.s2)
                            Text("\(tally) nights")
                                .font(TypeScale.headline)
                                .foregroundStyle(Tone.accent)
                        }
                        .frame(minHeight: Measure.hit)
                    }
                }
                .padding(Space.s2)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Tone.surface, in: RoundedRectangle(cornerRadius: Radius.card, style: .continuous))
            }
            .padding(Space.s2)
        }
    }

    private func colorRow(title: String, current: String, choose: @escaping (String) -> Void) -> some View {
        VStack(alignment: .leading, spacing: Space.s1) {
            Text(title)
                .font(TypeScale.caption)
                .foregroundStyle(Tone.muted)
            HStack(spacing: Space.s1) {
                colorButton("Warm", token: "accent", current: current, choose: choose)
                colorButton("Paper", token: "ink", current: current, choose: choose)
            }
        }
    }

    private func colorButton(_ title: String, token: String, current: String, choose: @escaping (String) -> Void) -> some View {
        Button(title) { choose(token) }
            .buttonStyle(SpreadPressStyle(kind: current == token ? .selected : .quiet))
            .accessibilityLabel("\(title), \(current == token ? "selected" : "not selected")")
    }
}
