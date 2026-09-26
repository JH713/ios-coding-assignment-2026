import Testing
@testable import JoonggonaraAssignment

@MainActor
struct ProductDetailViewModelTests {
    struct SomeError: Error {}

    private let repository = MockProductRepository()
    private let favoriteStore = FavoriteStore(repository: MockFavoriteRepository())

    private func makeViewModel(productID: Int = 1) -> ProductDetailViewModel {
        ProductDetailViewModel(productID: productID, repository: repository, favoriteStore: favoriteStore)
    }

    @Test("진입 시 상세 API로 상품을 불러온다")
    func loadsProduct() async {
        repository.pages[0] = ProductPage(items: [.stub(id: 1, title: "Detail")], total: 1, skip: 0, limit: 1)
        let viewModel = makeViewModel()
        await viewModel.loadIfNeeded()
        guard case .loaded(let product) = viewModel.state else {
            Issue.record("loaded 상태가 아님")
            return
        }
        #expect(product.title == "Detail")
        #expect(repository.requestedProductIDs == [1])
    }

    @Test("이미 로드된 상태에서 loadIfNeeded는 다시 요청하지 않는다")
    func loadIfNeededSkipsWhenLoaded() async {
        repository.pages[0] = ProductPage(items: [.stub(id: 1)], total: 1, skip: 0, limit: 1)
        let viewModel = makeViewModel()
        await viewModel.loadIfNeeded()
        await viewModel.loadIfNeeded()
        #expect(repository.requestedProductIDs == [1])
        guard case .loaded = viewModel.state else {
            Issue.record("loaded 상태가 유지되지 않음")
            return
        }
    }

    @Test("요청이 실패하면 failed 상태가 된다")
    func loadFailure() async {
        repository.error = SomeError()
        let viewModel = makeViewModel()
        await viewModel.load()
        #expect(repository.requestedProductIDs == [1])
        guard case .failed = viewModel.state else {
            Issue.record("failed 상태가 아님")
            return
        }
    }

    @Test("찜 토글은 목록 ViewModel과 같은 FavoriteStore에 반영된다")
    func favoriteTogglesSharedStore() {
        let listViewModel = ProductListViewModel(repository: repository, favoriteStore: favoriteStore)
        let detailViewModel = listViewModel.detailViewModel(for: 7)
        #expect(listViewModel.isFavorite(7) == false)
        detailViewModel.toggleFavorite()
        #expect(detailViewModel.isFavorite)
        #expect(listViewModel.isFavorite(7))
    }
}
