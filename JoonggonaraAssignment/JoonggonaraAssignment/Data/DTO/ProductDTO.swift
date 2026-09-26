import Foundation

nonisolated struct ProductDTO: Decodable, Sendable {
    let id: Int
    let title: String
    let description: String
    let category: String
    let brand: String?
    let sku: String
    let tags: [String]
    let price: Double
    let discountPercentage: Double
    let rating: Double
    let stock: Int
    let availabilityStatus: String
    let minimumOrderQuantity: Int
    let weight: Int
    let dimensions: DimensionsDTO
    let warrantyInformation: String
    let shippingInformation: String
    let returnPolicy: String
    let reviews: [ReviewDTO]
    let meta: ProductMetaDTO
    let thumbnail: String
    let images: [String]
}

nonisolated extension ProductDTO {
    func toDomain() -> Product {
        Product(
            id: id,
            title: title,
            description: description,
            category: category,
            brand: brand,
            sku: sku,
            tags: tags,
            price: price,
            discountPercentage: discountPercentage,
            rating: rating,
            stock: stock,
            availabilityStatus: availabilityStatus,
            minimumOrderQuantity: minimumOrderQuantity,
            weight: weight,
            dimensions: dimensions.toDomain(),
            warrantyInformation: warrantyInformation,
            shippingInformation: shippingInformation,
            returnPolicy: returnPolicy,
            reviews: reviews.map { $0.toDomain() },
            meta: meta.toDomain(),
            thumbnailURL: URL(string: thumbnail),
            imageURLs: images.compactMap(URL.init(string:))
        )
    }
}
