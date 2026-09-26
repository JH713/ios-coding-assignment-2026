import Foundation

nonisolated enum APIError: Error {
    case invalidURL
    case transport(URLError)
    case invalidResponse
    case httpStatus(Int)
    case decoding(Error)
}
