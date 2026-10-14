import CoreTransferable
import Foundation
import UniformTypeIdentifiers

/// PhotosPicker payload. No camera session and no camera usage string.
struct FramePhoto: Transferable {
    let data: Data

    static var transferRepresentation: some TransferRepresentation {
        DataRepresentation(importedContentType: .image) { data in
            FramePhoto(data: data)
        }
    }
}
