import SwiftUI

struct ProductRow: View {
    let product: Product
    let isFavorite: Bool
    let onToggleFavorite: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            RemoteImage(url: product.thumbnailURL)
                .frame(width: 72, height: 72)
            .clipShape(RoundedRectangle(cornerRadius: 8))

            VStack(alignment: .leading, spacing: 4) {
                Text(product.title)
                    .font(.body)
                    .lineLimit(2)
                Text(product.price, format: .currency(code: "USD"))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Spacer(minLength: 0)

            FavoriteButton(isFavorite: isFavorite, action: onToggleFavorite)
        }
        .padding(.vertical, 12)
    }
}
