import SwiftUI

struct ProductImageCarousel: View {
    let urls: [URL]

    var body: some View {
        TabView {
            ForEach(urls, id: \.self) { url in
                AsyncImage(url: url) { image in
                    image.resizable().scaledToFit()
                } placeholder: {
                    ProgressView()
                }
            }
        }
        .tabViewStyle(.page)
        .frame(height: 280)
    }
}
