import Foundation

nonisolated struct ProductMeta: Equatable, Sendable {
    let createdAt: Date
    let updatedAt: Date
    let barcode: String
    let qrCodeURL: URL?
}
