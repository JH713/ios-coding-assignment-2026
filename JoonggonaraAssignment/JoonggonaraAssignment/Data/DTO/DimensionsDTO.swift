nonisolated struct DimensionsDTO: Decodable, Sendable {
    let width: Double
    let height: Double
    let depth: Double
}

nonisolated extension DimensionsDTO {
    func toDomain() -> Dimensions {
        Dimensions(width: width, height: height, depth: depth)
    }
}
