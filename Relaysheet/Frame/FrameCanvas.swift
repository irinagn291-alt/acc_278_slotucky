import PencilKit
import SwiftUI

/// Live PencilKit margin. Mounted only on the seat that may Post.
struct FrameCanvas: UIViewRepresentable {
    @Binding var drawingData: Data

    func makeCoordinator() -> Coordinator {
        Coordinator(drawingData: $drawingData)
    }

    func makeUIView(context: Context) -> PKCanvasView {
        let canvas = PKCanvasView()
        canvas.drawingPolicy = .anyInput
        canvas.backgroundColor = .clear
        canvas.isOpaque = false
        canvas.tool = PKInkingTool(.pen, color: UIColor(Tone.ink), width: 3)
        canvas.delegate = context.coordinator
        if let drawing = try? PKDrawing(data: drawingData) {
            canvas.drawing = drawing
        }
        return canvas
    }

    func updateUIView(_ canvas: PKCanvasView, context: Context) {
        context.coordinator.drawingData = $drawingData
        guard !context.coordinator.updating else { return }
        let next = (try? PKDrawing(data: drawingData)) ?? PKDrawing()
        if next.dataRepresentation() != canvas.drawing.dataRepresentation() {
            canvas.drawing = next
        }
    }

    final class Coordinator: NSObject, PKCanvasViewDelegate {
        var drawingData: Binding<Data>
        var updating = false

        init(drawingData: Binding<Data>) {
            self.drawingData = drawingData
        }

        func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
            updating = true
            drawingData.wrappedValue = canvasView.drawing.dataRepresentation()
            updating = false
        }
    }
}

/// Clipped snapshot of a committed photo and markup. Never a second live canvas.
struct FrameSnapshot: View {
    var photo: Data?
    var markup: FrameMarkup?
    var tint: Color

    var body: some View {
        ZStack {
            Image("rls_CardBackdrop")
                .resizable()
                .scaledToFill()
                .accessibilityHidden(true)
            tint.opacity(0.22)
            if let photo, let image = UIImage(data: photo) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            }
            if let markup, let drawing = try? PKDrawing(data: markup.drawingData), !drawing.bounds.isEmpty {
                let image = drawing.image(from: drawing.bounds, scale: 2)
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .padding(Space.s1)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: Space.s8)
        .clipShape(RoundedRectangle(cornerRadius: Radius.chip, style: .continuous))
        .accessibilityHidden(true)
    }
}
