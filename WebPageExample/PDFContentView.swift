//
//  Created by Artem Novichkov on 07.07.2025.
//

import SwiftUI
import PDFKit

struct PDFContentView: UIViewRepresentable {

    let url: URL

    func makeUIView(context: Context) -> PDFView {
        let view = PDFView()
        view.autoScales = true
        view.document = PDFDocument(url: url)
        return view
    }

    func updateUIView(_ pdfView: PDFView, context: Context) {
    }
}
