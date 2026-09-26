import Foundation

nonisolated struct ReviewDTO: Decodable, Sendable {
    let rating: Int
    let comment: String
    let date: Date
    let reviewerName: String
    let reviewerEmail: String
}

nonisolated extension ReviewDTO {
    func toDomain() -> Review {
        Review(
            rating: rating,
            comment: comment,
            date: date,
            reviewerName: reviewerName,
            reviewerEmail: reviewerEmail
        )
    }
}
