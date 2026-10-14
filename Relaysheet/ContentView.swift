import PhotosUI
import SwiftUI

/// Root chrome. Diptych stays up. Bond, Shelf, Order, and Settings arrive as sheets.
struct ContentView: View {
    var session: SpreadSession
    @State private var draftA = ""
    @State private var draftB = "I would say come home. I kept the light on."
    @State private var drawingA = Data()
    @State private var drawingB = Data()
    @State private var photoA: Data?
    @State private var photoB: Data?
    @State private var photoItem: PhotosPickerItem?

    var body: some View {
        Group {
            if !session.didLoad {
                DiptychView(
                    session: session,
                    draftA: $draftA,
                    draftB: $draftB,
                    drawingA: $drawingA,
                    drawingB: $drawingB,
                    photoA: $photoA,
                    photoB: $photoB,
                    photoItem: $photoItem
                )
                .redacted(reason: .placeholder)
                .overlay {
                    if session.showSpinner {
                        ProgressView("Opening the spread")
                            .font(TypeScale.body)
                            .padding(Space.s3)
                            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: Radius.card, style: .continuous))
                    }
                }
            } else if !session.record.onboardingComplete {
                OnboardingGate(session: session)
            } else if session.record.fold == .blank {
                EmptySpreadPage(
                    imageName: "rls_EmptyHome",
                    title: "Start the bond",
                    line: "Two halves. Write the first line.",
                    action: "Start together"
                ) {
                    session.cover = .bond
                }
            } else {
                DiptychView(
                    session: session,
                    draftA: $draftA,
                    draftB: $draftB,
                    drawingA: $drawingA,
                    drawingB: $drawingB,
                    photoA: $photoA,
                    photoB: $photoB,
                    photoItem: $photoItem
                )
            }
        }
        .sheet(item: Bindable(session).cover) { cover in
            switch cover {
            case .bond:
                BondSheet(session: session)
            case .shelf:
                ShelfSheet(session: session)
            case .settings:
                SettingsSheet(session: session)
            case .shutter:
                ShutterSheet(session: session)
            }
        }
        .overlay {
            if let title = session.successTitle {
                VStack(spacing: Space.s2) {
                    Image("rls_SuccessMark")
                        .resizable()
                        .scaledToFit()
                        .frame(width: Space.s8, height: Space.s8)
                        .accessibilityHidden(true)
                    Text(title)
                        .font(TypeScale.headline)
                        .foregroundStyle(Tone.ink)
                }
                .padding(Space.s3)
                .background(.regularMaterial, in: RoundedRectangle(cornerRadius: Radius.card, style: .continuous))
                .allowsHitTesting(false)
                .transition(.opacity)
            }
        }
        .onChange(of: session.successTitle) { _, title in
            guard title != nil else { return }
            Task {
                try? await Task.sleep(nanoseconds: 700_000_000)
                session.successTitle = nil
            }
        }
        .onChange(of: session.record.fold) { _, fold in
            if fold == .idle {
                draftA = ""
                drawingA = Data()
            }
            if fold == .stitched || fold == .postedA {
                drawingB = Data()
            }
        }
    }
}
