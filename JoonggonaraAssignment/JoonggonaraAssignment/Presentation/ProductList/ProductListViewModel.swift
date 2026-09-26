import Observation

@Observable
final class ProductListViewModel {
    private(set) var state: LoadState<[Product]> = .idle
    private(set) var isLoadingMore = false
    private(set) var loadMoreError: Error?
    private(set) var layout: ProductListLayout = .list

    private let repository: any ProductRepository
    private let favoriteStore: FavoriteStore
    private let pageSize: Int
    private var total = 0

    init(repository: any ProductRepository, favoriteStore: FavoriteStore, pageSize: Int = 30) {
        self.repository = repository
        self.favoriteStore = favoriteStore
        self.pageSize = pageSize
    }

    func detailViewModel(for productID: Int) -> ProductDetailViewModel {
        ProductDetailViewModel(productID: productID, repository: repository, favoriteStore: favoriteStore)
    }

    func toggleLayout() {
        layout = layout == .list ? .grid : .list
    }

    func isFavorite(_ id: Int) -> Bool {
        favoriteStore.isFavorite(id)
    }

    func toggleFavorite(_ id: Int) {
        favoriteStore.toggle(id)
    }

    private var hasMore: Bool {
        guard case .loaded(let items) = state else { return false }
        return items.count < total
    }

    func loadIfNeeded() async {
        guard case .idle = state else { return }
        await load()
    }

    func load() async {
        state = .loading
        loadMoreError = nil
        do {
            let page = try await repository.fetchProducts(skip: 0, limit: pageSize)
            total = page.total
            state = .loaded(page.items)
        } catch {
            if Task.isCancelled {
                state = .idle
                return
            }
            state = .failed(error)
        }
    }

    func loadMoreIfNeeded(after product: Product) async {
        guard case .loaded(let items) = state, product.id == items.last?.id else { return }
        await loadMore()
    }

    func loadMore() async {
        guard case .loaded(let items) = state, hasMore, !isLoadingMore else { return }
        isLoadingMore = true
        loadMoreError = nil
        defer { isLoadingMore = false }
        do {
            let page = try await repository.fetchProducts(skip: items.count, limit: pageSize)
            guard case .loaded(let current) = state, current.count == items.count else { return }
            total = page.total
            state = .loaded(current + page.items)
        } catch {
            guard !Task.isCancelled else { return }
            loadMoreError = error
        }
    }
}
