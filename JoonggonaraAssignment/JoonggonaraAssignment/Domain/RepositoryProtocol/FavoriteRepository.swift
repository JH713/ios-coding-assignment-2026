nonisolated protocol FavoriteRepository {
    func loadFavoriteIDs() -> Set<Int>
    func saveFavoriteIDs(_ ids: Set<Int>)
}
