import SwiftUI

/// Settings sheet. Onboarding again, confirmed reset, PDF export, and the contact link.
struct SettingsSheet: View {
    var session: SpreadSession
    @Environment(\.dismiss) private var dismiss
    @State private var confirmReset = false
    @State private var exportURL: URL?
    @State private var exportFailed = false

    var body: some View {
        NavigationStack {
            Group {
                if session.recoveryMessage != nil && session.shelf.entries.isEmpty && session.record.bond.isEmpty {
                    EmptySpreadPage(
                        imageName: "rls_EmptyList",
                        title: "Settings could not read the spread",
                        line: session.recoveryMessage ?? "Try again.",
                        action: "Try again"
                    ) {
                        Task { await session.retryLoad() }
                    }
                } else if session.shelf.entries.isEmpty {
                    VStack(spacing: 0) {
                        EmptySpreadPage(
                            imageName: "rls_EmptyList",
                            title: "No spreads to export",
                            line: "Two halves. Write the first line.",
                            action: "Back to the spread"
                        ) {
                            dismiss()
                        }
                        links
                            .padding(Space.s2)
                    }
                } else {
                    populated
                }
            }
            .background(Tone.background.ignoresSafeArea())
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                        .accessibilityLabel("Close settings")
                }
            }
            .confirmationDialog(
                "Reset all data",
                isPresented: $confirmReset,
                titleVisibility: .visible
            ) {
                Button("Reset all data", role: .destructive) {
                    Task { await session.resetAllData() }
                }
                Button("Keep the spreads", role: .cancel) {}
            } message: {
                Text("Stitched spreads on this device are removed.")
            }
        }
    }

    private var populated: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Space.s3) {
                VStack(alignment: .leading, spacing: Space.s2) {
                    Text("Export")
                        .font(TypeScale.headline)
                        .foregroundStyle(Tone.ink)
                    let ready = CountText.whole(session.shelf.entries.count)
                    Text("\(ready) stitched spreads are ready as a PDF.")
                        .font(TypeScale.body)
                        .foregroundStyle(Tone.muted)
                    Button("Export PDF") {
                        do {
                            exportURL = try SpreadPDF.write(entries: session.shelf.entries)
                            exportFailed = false
                        } catch {
                            exportFailed = true
                        }
                    }
                    .buttonStyle(SpreadPressStyle(kind: .primary))
                    if exportFailed {
                        Text("The PDF could not be written. Try again.")
                            .font(TypeScale.body)
                            .foregroundStyle(Tone.ink)
                    }
                    if let exportURL {
                        ShareLink(item: exportURL) {
                            Text("Share PDF")
                                .frame(maxWidth: .infinity, minHeight: Measure.hit)
                                .contentShape(Rectangle())
                        }
                        .buttonStyle(SpreadPressStyle(kind: .quiet))
                    }
                }
                .padding(Space.s2)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(.regularMaterial, in: RoundedRectangle(cornerRadius: Radius.card, style: .continuous))
                links
            }
            .padding(Space.s2)
        }
    }

    private var links: some View {
        VStack(alignment: .leading, spacing: Space.s2) {
            Button("Show the introduction again") {
                session.reopenOnboarding()
            }
            .buttonStyle(SpreadPressStyle(kind: .quiet))
            Button("Reset all data") {
                confirmReset = true
            }
            .buttonStyle(SpreadPressStyle(kind: .destructive))
            if let url = URL(string: "https://relaysheet-spread.pro/contact-us") {
                Link(destination: url) {
                    Text("Contact")
                        .frame(maxWidth: .infinity, minHeight: Measure.hit)
                        .contentShape(Rectangle())
                }
                .buttonStyle(SpreadPressStyle(kind: .quiet))
                .accessibilityLabel("Contact")
            }
        }
        .padding(Space.s2)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: Radius.card, style: .continuous))
    }
}
