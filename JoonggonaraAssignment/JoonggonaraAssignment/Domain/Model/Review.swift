import Foundation

nonisolated struct Review: Equatable, Sendable {
    let rating: Int
    let comment: String
    let date: Date
    let reviewerName: String
    let reviewerEmail: String
}
