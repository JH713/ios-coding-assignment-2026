import Observation

@Observable
final class FavoriteStore {
    private(set) var favoriteIDs: Set<Int>
    private let repository: any FavoriteRepository

    init(repository: any FavoriteRepository) {
        self.repository = repository
        self.favoriteIDs = repository.loadFavoriteIDs()
    }

    func isFavorite(_ id: Int) -> Bool {
        favoriteIDs.contains(id)
    }

    func toggle(_ id: Int) {
        if favoriteIDs.contains(id) {
            favoriteIDs.remove(id)
        } else {
            favoriteIDs.insert(id)
        }
        repository.saveFavoriteIDs(favoriteIDs)
    }
}
