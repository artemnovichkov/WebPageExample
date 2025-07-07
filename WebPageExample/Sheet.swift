//
//  Created by Artem Novichkov on 07.07.2025.
//

import SwiftUI

enum Sheet: View, Identifiable {
    
    case webarchive(URL)
    case pdf(URL)
    case snapshot(URL)

    var id: String {
        switch self {
        case .webarchive:
            "webarchive"
        case .pdf:
            "pdf"
        case .snapshot:
            "snapshot"
        }
    }
    
    var body: some View {
        switch self {
        case .webarchive(let url):
            WebArchiveView(url: url)
        case .pdf(let url):
            PDFContentView(url: url)
        case .snapshot(let url):
            SnapshotContentView(url: url)
        }
    }
}
