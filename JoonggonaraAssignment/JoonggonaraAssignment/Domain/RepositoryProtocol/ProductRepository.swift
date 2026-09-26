nonisolated protocol ProductRepository: Sendable {
    func fetchProducts(skip: Int, limit: Int) async throws -> ProductPage
    func fetchProduct(id: Int) async throws -> Product
}
