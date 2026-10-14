import SwiftUI
import UIKit

/// PDF of stitched spreads. UIGraphicsPDFRenderer only. No network.
enum SpreadPDF {
    static func write(entries: [PairEntry]) throws -> URL {
        let page = CGRect(x: 0, y: 0, width: 612, height: 792)
        let renderer = UIGraphicsPDFRenderer(bounds: page)
        let data = renderer.pdfData { context in
            let body = UIFont.preferredFont(forTextStyle: .body)
            let title = UIFont.preferredFont(forTextStyle: .title2)
            let ink = UIColor(Tone.background)
            for entry in entries {
                context.beginPage()
                let head = CountText.day(entry.daykey) as NSString
                head.draw(at: CGPoint(x: 48, y: 48), withAttributes: [
                    .font: title,
                    .foregroundColor: ink
                ])
                let copy = "\(entry.markA.text)\n\n\(entry.markB.text)" as NSString
                copy.draw(
                    in: CGRect(x: 48, y: 96, width: 516, height: 640),
                    withAttributes: [
                        .font: body,
                        .foregroundColor: ink
                    ]
                )
            }
        }
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("relaysheet-spreads.pdf")
        try data.write(to: url, options: .atomic)
        return url
    }
}
