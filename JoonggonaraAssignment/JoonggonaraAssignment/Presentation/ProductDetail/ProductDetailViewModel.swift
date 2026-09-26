import Observation

@Observable
final class ProductDetailViewModel {
    let productID: Int
    private(set) var state: LoadState<Product> = .idle
    private let repository: any ProductRepository
    private let favoriteStore: FavoriteStore

    init(productID: Int, repository: any ProductRepository, favoriteStore: FavoriteStore) {
        self.productID = productID
        self.repository = repository
        self.favoriteStore = favoriteStore
    }

    var isFavorite: Bool {
        favoriteStore.isFavorite(productID)
    }

    func toggleFavorite() {
        favoriteStore.toggle(productID)
    }

    func loadIfNeeded() async {
        guard case .idle = state else { return }
        await load()
    }

    func load() async {
        state = .loading
        do {
            state = .loaded(try await repository.fetchProduct(id: productID))
        } catch {
            if Task.isCancelled {
                state = .idle
                return
            }
            state = .failed(error)
        }
    }
}
