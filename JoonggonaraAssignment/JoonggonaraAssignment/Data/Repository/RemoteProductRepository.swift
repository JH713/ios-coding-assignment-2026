nonisolated struct RemoteProductRepository: ProductRepository {
    private let client: APIClient

    init(client: APIClient = APIClient()) {
        self.client = client
    }

    func fetchProducts(skip: Int, limit: Int) async throws -> ProductPage {
        let request = try ProductEndpoint.products(skip: skip, limit: limit).makeRequest()
        let response: ProductListResponseDTO = try await client.request(request)
        return response.toDomain()
    }

    func fetchProduct(id: Int) async throws -> Product {
        let request = try ProductEndpoint.product(id: id).makeRequest()
        let dto: ProductDTO = try await client.request(request)
        return dto.toDomain()
    }
}
