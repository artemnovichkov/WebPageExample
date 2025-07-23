//
//  Created by Artem Novichkov on 07.07.2025.
//

import SwiftUI

enum Sheet: View, Identifiable {
    
    case image(URL)
    case pdf(URL)
    case webArchive(URL)

    var id: String {
        switch self {
        case .image:
            "image"
        case .pdf:
            "pdf"
        case .webArchive:
            "webArchive"
        }
    }
    
    var body: some View {
        switch self {
        case .image(let url):
            ImageContentView(url: url)
        case .pdf(let url):
            PDFContentView(url: url)
        case .webArchive(let url):
            WebArchiveView(url: url)
        }
    }
}
