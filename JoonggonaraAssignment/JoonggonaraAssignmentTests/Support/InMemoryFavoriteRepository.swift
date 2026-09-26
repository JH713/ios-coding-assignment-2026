@testable import JoonggonaraAssignment

final class InMemoryFavoriteRepository: FavoriteRepository {
    private(set) var savedIDs: [Set<Int>] = []
    private var ids: Set<Int>

    init(ids: Set<Int> = []) {
        self.ids = ids
    }

    func loadFavoriteIDs() -> Set<Int> {
        ids
    }

    func saveFavoriteIDs(_ ids: Set<Int>) {
        self.ids = ids
        savedIDs.append(ids)
    }
}
