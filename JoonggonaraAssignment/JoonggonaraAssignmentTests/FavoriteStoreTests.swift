import Testing
@testable import JoonggonaraAssignment

@MainActor
struct FavoriteStoreTests {
    @Test("초기화 시 저장소의 찜 목록을 불러오고 저장은 하지 않는다")
    func loadsFavoritesOnInit() {
        let repository = InMemoryFavoriteRepository(ids: [1, 2])
        let store = FavoriteStore(repository: repository)
        #expect(store.favoriteIDs == [1, 2])
        #expect(store.isFavorite(1))
        #expect(store.isFavorite(3) == false)
        #expect(repository.savedIDs.isEmpty)
    }

    @Test("찜하지 않은 상품을 토글하면 찜 목록에 추가되고 저장된다")
    func toggleAddsAndSaves() {
        let repository = InMemoryFavoriteRepository()
        let store = FavoriteStore(repository: repository)
        store.toggle(5)
        #expect(store.isFavorite(5))
        #expect(repository.savedIDs == [[5]])
    }

    @Test("찜한 상품을 토글하면 찜 목록에서 제거되고 저장된다")
    func toggleRemovesAndSaves() {
        let repository = InMemoryFavoriteRepository(ids: [5, 6])
        let store = FavoriteStore(repository: repository)
        store.toggle(5)
        #expect(store.isFavorite(5) == false)
        #expect(repository.savedIDs == [[6]])
    }

    @Test("토글할 때마다 전체 찜 목록이 저장된다")
    func savesWholeSetOnEveryToggle() {
        let repository = InMemoryFavoriteRepository()
        let store = FavoriteStore(repository: repository)
        store.toggle(1)
        store.toggle(2)
        store.toggle(1)
        #expect(repository.savedIDs == [[1], [1, 2], [2]])
        #expect(store.favoriteIDs == [2])
    }
}
