import SwiftUI

struct ProductGridCell: View {
    let product: Product
    let isFavorite: Bool
    let onToggleFavorite: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Color.clear
                .aspectRatio(1, contentMode: .fit)
                .overlay {
                    RemoteImage(url: product.thumbnailURL)
                }
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .overlay(alignment: .topTrailing) {
                    FavoriteButton(isFavorite: isFavorite, action: onToggleFavorite)
                        .padding(8)
                }

            Text(product.title)
                .font(.subheadline)
                .lineLimit(2)
            Text(product.price, format: .currency(code: "USD"))
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }
}
