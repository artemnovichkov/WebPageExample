//
//  Created by Artem Novichkov on 07.07.2025.
//

import SwiftUI
import WebKit

enum ContentType: String, CaseIterable {
    case snapshot = "Snapshot"
    case pdf = "PDF"
    case webarchive = "Web Archive"
}

struct ContentView: View {
    @State private var url: URL = URL(string: "https://www.artemnovichkov.com")!
    @State private var webPage = WebPage()
    @State private var sheet: Sheet?
    @State private var contentType: ContentType = .snapshot

    var body: some View {
        content
            .safeAreaInset(edge: .bottom) {
                HStack {
                    Picker("Content Type", selection: $contentType) {
                        ForEach(ContentType.allCases, id: \.self) { contentType in
                            Text(contentType.rawValue)
                                .tag(contentType.rawValue)
                        }
                    }
                    Spacer()
                    Button("Save") {
                        save()
                    }
                }
                .padding()
                .disabled(disabled)
            }
            .sheet(item: $sheet) { $0 }
            .onAppear {
                let request = URLRequest(url: url)
                webPage.load(request)
            }
            .onDisappear {
                webPage.stopLoading()
            }
    }

    private var content: some View {
        ZStack {
            Color.white
            if webPage.isLoading {
                ProgressView("Loading", value: webPage.estimatedProgress)
                    .padding()
            } else {
                WebView(url: url)
            }
        }
    }

    private var disabled: Bool {
        switch webPage.currentNavigationEvent?.kind {
        case .finished:
            false
        default:
            true
        }
    }

    private func save() {
        Task {
            do {
                switch contentType {
                case .snapshot:
                    if let image = try await webPage.snapshot() {
                        let renderer = ImageRenderer(content: image)
                        renderer.scale = 2
                        if let uiImage = renderer.uiImage, let data = uiImage.pngData() {
                            let url = save(data, for: contentType)
                            sheet = .snapshot(url)
                        }
                    }
                case .pdf:
                    let data = try await webPage.pdf()
                    let url = save(data, for: contentType)
                    sheet = .pdf(url)
                case .webarchive:
                    let data = try await webPage.webArchiveData()
                    let url = save(data, for: contentType)
                    sheet = .webarchive(url)
                }
            }
            catch {
                print("Error saving content: \(error)")
            }
        }
    }

    private func save(_ data: Data, for contentType: ContentType) -> URL {
        let fileManager = FileManager.default
        let pathExtension = switch contentType {
        case .snapshot:
            "png"
        case .pdf:
            "pdf"
        case .webarchive:
            "webarchive"
        }
        let url = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("data")
            .appendingPathExtension(pathExtension)
        fileManager.createFile(atPath: url.path(), contents: data)
        return url
    }
}

#Preview {
    ContentView()
}
