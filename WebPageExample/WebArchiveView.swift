//
//  Created by Artem Novichkov on 07.07.2025.
//

import SwiftUI
import WebKit

struct WebArchiveView: View {
    
    let url: URL
    @State private var webPage: WebPage = .init()
    
    var body: some View {
        WebView(webPage)
            .onAppear {
                guard let data = FileManager.default.contents(atPath: url.path()) else {
                    print("Failed to load web archive data from \(url.path())")
                    return
                }
                let baseURL = URL(string: "about:blank")!
                webPage.load(data, mimeType: "application/x-webarchive", characterEncoding: .utf8, baseURL: baseURL)
            }
    }
}
