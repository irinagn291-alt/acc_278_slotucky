import PhotosUI
import SwiftUI
import UIKit

/// Home. Two seat panes, a center rule, and the filmstrip. Post fuses on the open seat.
struct DiptychView: View {
    var session: SpreadSession
    @Binding var draftA: String
    @Binding var draftB: String
    @Binding var drawingA: Data
    @Binding var drawingB: Data
    @Binding var photoA: Data?
    @Binding var photoB: Data?
    @Binding var photoItem: PhotosPickerItem?
    @Environment(\.horizontalSizeClass) private var sizeClass

    var body: some View {
        NavigationStack {
            GeometryReader { geo in
                ScrollView {
                    VStack(alignment: .leading, spacing: Space.s2) {
                        Image("rls_HeaderDecor")
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: .infinity)
                            .frame(height: Space.s4)
                            .clipped()
                            .accessibilityHidden(true)
                        chrome
                        if let notice = session.notice {
                            Text(notice)
                                .font(TypeScale.body)
                                .foregroundStyle(Tone.ink)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(Space.s2)
                                .background(.thinMaterial, in: RoundedRectangle(cornerRadius: Radius.card, style: .continuous))
                                .accessibilityLabel(notice)
                        }
                        if let recovery = session.recoveryMessage {
                            VStack(alignment: .leading, spacing: Space.s2) {
                                Text("The spread could not be read.")
                                    .font(TypeScale.headline)
                                    .foregroundStyle(Tone.ink)
                                Text(recovery)
                                    .font(TypeScale.body)
                                    .foregroundStyle(Tone.muted)
                                Button("Try again") {
                                    Task { await session.retryLoad() }
                                }
                                .buttonStyle(SpreadPressStyle(kind: .primary))
                            }
                            .padding(Space.s2)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: Radius.card, style: .continuous))
                        }
                        if sizeClass == .regular {
                            HStack(alignment: .top, spacing: Space.s2) {
                                panes
                                    .frame(minHeight: geo.size.height - Space.s10)
                                FilmstripRail(entries: session.shelf.entries, selected: session.focusedDaykey) { daykey in
                                    session.focusedDaykey = daykey
                                }
                                .frame(width: Space.art + Space.s4, height: geo.size.height - Space.s10)
                            }
                        } else {
                            panes
                            FilmstripRail(
                                entries: session.shelf.entries,
                                selected: session.focusedDaykey,
                                scrollsInternally: false
                            ) { daykey in
                                session.focusedDaykey = daykey
                            }
                        }
                    }
                    .padding(Space.s2)
                    .frame(maxWidth: .infinity, minHeight: geo.size.height, alignment: .top)
                }
                .scrollDismissesKeyboard(.interactively)
            }
            .background(Tone.background.ignoresSafeArea())
            .toolbar(.hidden, for: .navigationBar)
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") { resignKeyboard() }
                        .accessibilityLabel("Done")
                }
            }
            .simultaneousGesture(TapGesture().onEnded { resignKeyboard() })
        }
        .onChange(of: photoItem) { _, item in
            guard let item else { return }
            Task {
                if let photo = try? await item.loadTransferable(type: FramePhoto.self) {
                    if session.activeSeat == .b {
                        photoB = photo.data
                    } else {
                        photoA = photo.data
                    }
                }
            }
        }
    }

    private var jobTitle: String {
        if session.focusedDaykey != nil {
            return "A filed night"
        }
        switch session.record.fold {
        case .postedA:
            return "Post the reply."
        case .idle:
            return "Write the first half."
        case .stitched:
            return "Tonight is filed."
        case .blank:
            return "Name both people."
        }
    }

    private var jobLine: String {
        let left = session.record.bond.seatAName
        let right = session.record.bond.seatBName
        if session.focusedDaykey != nil {
            return "Back to tonight when you want the open half."
        }
        switch session.record.fold {
        case .postedA:
            return "\(left) posted. \(right) answers next."
        case .idle:
            return "\(left) writes first. \(right) stays closed until that post."
        case .stitched:
            return "Both halves are filed. A new night starts after midnight."
        case .blank:
            return "Two halves. Write the first line."
        }
    }

    private func resignKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }

    private var chrome: some View {
        VStack(alignment: .leading, spacing: Space.s1) {
            HStack(alignment: .center, spacing: Space.s1) {
                Text("Slotucky")
                    .font(TypeScale.micro)
                    .foregroundStyle(Tone.muted)
                    .lineLimit(1)
                Spacer(minLength: Space.s1)
                chromeButton("Days together", system: "person.2") { session.cover = .bond }
                chromeButton("Filed nights", system: "rectangle.split.2x1") { session.cover = .shelf }
                chromeButton("How posting works", system: "rectangle.lefthalf.filled") { session.cover = .shutter }
                chromeButton("Settings", system: "gearshape") { session.cover = .settings }
            }
            Text(jobTitle)
                .font(TypeScale.title)
                .foregroundStyle(Tone.ink)
                .fixedSize(horizontal: false, vertical: true)
            Text(jobLine)
                .font(TypeScale.body)
                .foregroundStyle(Tone.ink)
                .fixedSize(horizontal: false, vertical: true)
            if session.focusedDaykey != nil {
                Button("Back to tonight") {
                    session.focusedDaykey = nil
                }
                .buttonStyle(SpreadPressStyle(kind: .quiet))
            } else if session.record.fold == .postedA {
                Button("Peel") { session.peel() }
                    .buttonStyle(SpreadPressStyle(kind: .destructive))
                    .accessibilityLabel("Peel the last post")
            }
        }
    }

    private func chromeButton(_ title: String, system: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: system)
                .font(TypeScale.headline)
                .frame(width: Measure.hit, height: Measure.hit)
                .contentShape(Rectangle())
        }
        .accessibilityLabel(title)
        .buttonStyle(SpreadPressStyle(kind: .quiet, compact: true))
    }

    private var panes: some View {
        HStack(alignment: .top, spacing: 0) {
            leftPane
                .frame(maxWidth: openSeat == .b ? Space.rail + Space.s2 : .infinity)
            Rectangle()
                .fill(Tone.muted)
                .frame(width: Space.unit)
                .accessibilityHidden(true)
            rightPane
                .frame(maxWidth: openSeat == .a ? Space.rail + Space.s2 : .infinity)
        }
        .frame(maxWidth: .infinity, alignment: .top)
    }

    private var openSeat: Seat? {
        focused == nil ? session.activeSeat : nil
    }

    private var prompt: Prompt {
        let key = session.focusedDaykey ?? session.record.liveDaykey
        return PromptDeck.prompt(for: key)
    }

    private var focused: PairEntry? {
        guard let daykey = session.focusedDaykey else { return nil }
        return session.shelf.entry(daykey: daykey)
    }

    private var leftPane: some View {
        let fold = session.record.fold
        let lookingBack = focused != nil
        let composer = !lookingBack && fold == .idle
        let text = focused?.markA.text ?? (composer ? nil : session.record.postA?.text)
        let status = lookingBack || fold == .postedA || fold == .stitched ? "Posted" : (fold == .idle ? "Waiting" : "Waiting")
        return SeatPane(
            title: session.record.bond.seatAName.isEmpty ? "First half" : session.record.bond.seatAName,
            status: status,
            tint: Tone.seat(session.record.bond.seatAColor),
            prompt: composer || lookingBack ? prompt.partA : nil,
            committed: text,
            markup: lookingBack ? focused?.markA.frameMarkup : session.record.postA?.frameMarkup,
            photo: lookingBack ? nil : photoA,
            shuttered: false,
            composer: composer,
            serifPrompt: composer,
            error: session.notice != nil && fold == .idle,
            draft: $draftA,
            drawing: $drawingA,
            photoItem: $photoItem,
            canPost: true,
            posting: session.posting,
            onPost: { session.post(text: draftA, drawing: drawingA) }
        )
    }

    private var rightPane: some View {
        let fold = session.record.fold
        let lookingBack = focused != nil
        let shuttered = !lookingBack && fold == .idle
        let composer = !lookingBack && fold == .postedA
        let text = focused?.markB.text ?? session.record.postB?.text
        let status: String = {
            if lookingBack || fold == .stitched { return "Stitched" }
            if fold == .postedA { return "Waiting" }
            return "Waiting"
        }()
        return SeatPane(
            title: session.record.bond.seatBName.isEmpty ? "Reply" : session.record.bond.seatBName,
            status: status,
            tint: Tone.seat(session.record.bond.seatBColor),
            prompt: shuttered ? nil : prompt.partB,
            committed: composer ? nil : text,
            markup: lookingBack ? focused?.markB.frameMarkup : session.record.postB?.frameMarkup,
            photo: lookingBack ? nil : photoB,
            shuttered: shuttered,
            composer: composer,
            serifPrompt: composer,
            error: session.notice != nil && (fold == .idle || fold == .postedA),
            draft: $draftB,
            drawing: $drawingB,
            photoItem: $photoItem,
            canPost: true,
            posting: session.posting,
            onPost: { session.post(text: draftB, drawing: drawingB) }
        )
    }
}
