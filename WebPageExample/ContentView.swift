//
//  Created by Artem Novichkov on 07.07.2025.
//

import SwiftUI
import WebKit
import UniformTypeIdentifiers

enum ContentType: String, CaseIterable {
    case image = "Image"
    case pdf = "PDF"
    case webArchive = "Web Archive"
}

struct ContentView: View {
    @State private var url: URL = URL(string: "https://www.artemnovichkov.com")!
    @State private var webPage = WebPage()
    @State private var sheet: Sheet?
    @State private var loaded = false
    @State private var contentType: ContentType = .image

    var body: some View {
        content
            .toolbar {
                ToolbarSpacer(placement: .bottomBar)
                ToolbarItem(placement: .bottomBar) {
                    Picker("Content Type", selection: $contentType) {
                        ForEach(ContentType.allCases, id: \.self) { contentType in
                            Text(contentType.rawValue)
                                .tag(contentType)
                        }
                    }
                    .tint(.primary)
                    .fixedSize()
                }
                ToolbarItem(placement: .bottomBar) {
                    Button("Save", systemImage: "square.and.arrow.down") {
                        save()
                    }
                    .disabled(!loaded)
                }
            }
            .sheet(item: $sheet) { $0 }
            .onAppear {
                let request = URLRequest(url: url)
                Task {
                    for try await event in webPage.load(request) {
                        if event == .committed {
                            loaded = true
                        }
                    }
                }
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

    private func save() {
        Task {
            do {
                let data = try await webPage.exported(as: contentType.type)
                let fileManager = FileManager.default
                let url = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
                    .appendingPathComponent("data")
                    .appendingPathExtension(contentType.pathExtension)
                fileManager.createFile(atPath: url.path(), contents: data)
                switch contentType {
                case .image:
                    sheet = .image(url)
                case .pdf:
                    sheet = .pdf(url)
                case .webArchive:
                    sheet = .webArchive(url)
                }
            }
            catch {
                print("Error saving content: \(error)")
            }
        }
    }
}

private extension ContentType {

    var type: UTType {
        switch self {
        case .image: .image
        case .pdf: .pdf
        case .webArchive: .webArchive
        }
    }

    var pathExtension: String {
        if let preferredFilenameExtension = type.preferredFilenameExtension {
            return preferredFilenameExtension
        }
        return switch self {
        case .image: "png"
        case .pdf: "pdf"
        case .webArchive: "webarchive"
        }
    }
}

#Preview {
    ContentView()
}
