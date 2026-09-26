import Foundation

nonisolated enum ProductEndpoint {
    case products(skip: Int, limit: Int)
    case product(id: Int)

    private static let baseURL = URL(string: "https://dummyjson.com")!

    func makeRequest() throws -> URLRequest {
        guard var components = URLComponents(url: Self.baseURL, resolvingAgainstBaseURL: false) else {
            throw APIError.invalidURL
        }
        switch self {
        case .products(let skip, let limit):
            components.path = "/products"
            components.queryItems = [
                URLQueryItem(name: "skip", value: String(skip)),
                URLQueryItem(name: "limit", value: String(limit)),
            ]
        case .product(let id):
            components.path = "/products/\(id)"
        }
        guard let url = components.url else { throw APIError.invalidURL }
        return URLRequest(url: url)
    }
}
