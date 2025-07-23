//
//  Created by Artem Novichkov on 07.07.2025.
//

import SwiftUI
 
struct ImageContentView: View {
    
    let url: URL
    
    var body: some View {
        if let image = UIImage(contentsOfFile: url.path) {
            ScrollView {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
            }
        }
        else {
            Text("Fail to load image")
        }
    }
}
