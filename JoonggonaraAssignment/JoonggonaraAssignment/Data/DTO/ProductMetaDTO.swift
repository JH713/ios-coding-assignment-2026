import Foundation

nonisolated struct ProductMetaDTO: Decodable, Sendable {
    let createdAt: Date
    let updatedAt: Date
    let barcode: String
    let qrCode: String
}

nonisolated extension ProductMetaDTO {
    func toDomain() -> ProductMeta {
        ProductMeta(
            createdAt: createdAt,
            updatedAt: updatedAt,
            barcode: barcode,
            qrCodeURL: URL(string: qrCode)
        )
    }
}
