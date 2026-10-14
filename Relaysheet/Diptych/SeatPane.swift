import PhotosUI
import SwiftUI

/// One half of the diptych. The open seat holds the prompt, the field, and Post.
struct SeatPane: View {
    var title: String
    var status: String
    var tint: Color
    var prompt: String?
    var committed: String?
    var markup: FrameMarkup?
    var photo: Data?
    var shuttered: Bool
    var composer: Bool
    var serifPrompt: Bool = false
    var error: Bool
    @Binding var draft: String
    @Binding var drawing: Data
    @Binding var photoItem: PhotosPickerItem?
    var canPost: Bool
    var posting: Bool
    var onPost: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: Space.s2) {
            HStack(alignment: .firstTextBaseline) {
                Text(title)
                    .font(TypeScale.headline)
                    .foregroundStyle(Tone.ink)
                    .lineLimit(1)
                Spacer(minLength: Space.s1)
                Text(status)
                    .font(TypeScale.micro)
                    .foregroundStyle(Tone.ink)
                    .padding(.horizontal, Space.s1)
                    .padding(.vertical, Space.s1)
                    .background(tint.opacity(0.35), in: Capsule())
                    .accessibilityLabel(status)
            }
            if let prompt, !shuttered {
                Text(prompt)
                    .font(serifPrompt ? TypeScale.display() : TypeScale.headline)
                    .foregroundStyle(Tone.ink)
                    .fixedSize(horizontal: false, vertical: true)
            }
            if shuttered {
                Image("rls_TwistHero")
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity)
                    .frame(maxHeight: Space.art)
                    .accessibilityHidden(true)
                Text("Closed until the first half is posted.")
                    .font(TypeScale.body)
                    .foregroundStyle(Tone.muted)
                    .fixedSize(horizontal: false, vertical: true)
            }
            if let committed, !composer {
                FrameSnapshot(photo: photo, markup: markup, tint: tint)
                Text(committed)
                    .font(TypeScale.body)
                    .foregroundStyle(Tone.ink)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .fixedSize(horizontal: false, vertical: true)
            }
            if composer {
                FrameSnapshot(photo: photo, markup: nil, tint: tint)
                FrameCanvas(drawingData: $drawing)
                    .frame(height: Space.s10)
                    .background(Tone.surface, in: RoundedRectangle(cornerRadius: Radius.chip, style: .continuous))
                    .clipShape(RoundedRectangle(cornerRadius: Radius.chip, style: .continuous))
                PhotosPicker(selection: $photoItem, matching: .images) {
                    Label("Add frame photo", systemImage: "photo")
                        .font(TypeScale.caption)
                        .foregroundStyle(Tone.ink)
                        .frame(maxWidth: .infinity, minHeight: Measure.hit)
                        .contentShape(Rectangle())
                }
                .accessibilityLabel("Add frame photo")
                TextField("Write this half", text: $draft, axis: .vertical)
                    .font(TypeScale.body)
                    .foregroundStyle(Tone.ink)
                    .lineLimit(3...6)
                    .padding(Space.s2)
                    .background(Tone.surface, in: RoundedRectangle(cornerRadius: Radius.chip, style: .continuous))
                Button(action: onPost) {
                    HStack(spacing: Space.s1) {
                        Image("rls_ControlFace")
                            .resizable()
                            .scaledToFit()
                            .frame(width: Space.s4, height: Space.s4)
                            .accessibilityHidden(true)
                        Text("Post")
                    }
                }
                .buttonStyle(SpreadPressStyle(kind: error ? .error : .primary, loading: posting))
                .disabled(!canPost || posting)
            }
            Spacer(minLength: 0)
        }
        .padding(Space.s2)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: Radius.card, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: Radius.card, style: .continuous)
                .stroke(composer ? Tone.accent : tint.opacity(0.7), lineWidth: Measure.stroke)
        )
    }
}
