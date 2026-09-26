nonisolated struct ProductListResponseDTO: Decodable, Sendable {
    let products: [ProductDTO]
    let total: Int
    let skip: Int
    let limit: Int
}

nonisolated extension ProductListResponseDTO {
    func toDomain() -> ProductPage {
        ProductPage(
            items: products.map { $0.toDomain() },
            total: total,
            skip: skip,
            limit: limit
        )
    }
}
