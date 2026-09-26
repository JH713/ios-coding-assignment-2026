import SwiftUI

struct ProductImageCarousel: View {
    let urls: [URL]

    var body: some View {
        TabView {
            ForEach(urls, id: \.self) { url in
                RemoteImage(url: url, contentMode: .fit)
            }
        }
        .tabViewStyle(.page)
        .frame(height: 280)
    }
}
