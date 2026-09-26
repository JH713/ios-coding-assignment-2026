import Foundation

nonisolated struct Product: Identifiable, Equatable, Sendable {
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
    let dimensions: Dimensions
    let warrantyInformation: String
    let shippingInformation: String
    let returnPolicy: String
    let reviews: [Review]
    let meta: ProductMeta
    let thumbnailURL: URL?
    let imageURLs: [URL]
}
