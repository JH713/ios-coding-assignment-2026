import Foundation
@testable import JoonggonaraAssignment

extension Product {
    static func stub(id: Int, title: String = "Product", price: Double = 9.99) -> Product {
        Product(
            id: id,
            title: title,
            description: "",
            category: "",
            brand: nil,
            sku: "",
            tags: [],
            price: price,
            discountPercentage: 0,
            rating: 0,
            stock: 0,
            availabilityStatus: "",
            minimumOrderQuantity: 1,
            weight: 0,
            dimensions: Dimensions(width: 0, height: 0, depth: 0),
            warrantyInformation: "",
            shippingInformation: "",
            returnPolicy: "",
            reviews: [],
            meta: ProductMeta(createdAt: .distantPast, updatedAt: .distantPast, barcode: "", qrCodeURL: nil),
            thumbnailURL: nil,
            imageURLs: []
        )
    }
}
