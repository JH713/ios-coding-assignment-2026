nonisolated struct ProductPage: Equatable, Sendable {
    let items: [Product]
    let total: Int
    let skip: Int
    let limit: Int
}
