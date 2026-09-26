import Testing
@testable import JoonggonaraAssignment

@MainActor
struct ProductListViewModelTests {
    struct SomeError: Error {}

    private let repository = MockProductRepository()
    private let favoriteStore = FavoriteStore(repository: MockFavoriteRepository())

    private func makeViewModel(pageSize: Int = 3) -> ProductListViewModel {
        ProductListViewModel(repository: repository, favoriteStore: favoriteStore, pageSize: pageSize)
    }

    private func givenTwoPages() {
        repository.pages[0] = ProductPage(items: [.stub(id: 1), .stub(id: 2), .stub(id: 3)], total: 5, skip: 0, limit: 3)
        repository.pages[3] = ProductPage(items: [.stub(id: 4), .stub(id: 5)], total: 5, skip: 3, limit: 2)
    }

    private func loadedIDs(_ viewModel: ProductListViewModel) -> [Int]? {
        guard case .loaded(let items) = viewModel.state else { return nil }
        return items.map(\.id)
    }

    @Test("첫 페이지를 불러오면 loaded 상태가 된다")
    func loadsFirstPage() async {
        givenTwoPages()
        let viewModel = makeViewModel()
        await viewModel.load()
        #expect(loadedIDs(viewModel) == [1, 2, 3])
        #expect(repository.requests == [.init(skip: 0, limit: 3)])
    }

    @Test("이미 로드된 상태에서 loadIfNeeded는 요청하지 않는다")
    func loadIfNeededSkipsWhenLoaded() async {
        givenTwoPages()
        let viewModel = makeViewModel()
        await viewModel.loadIfNeeded()
        await viewModel.loadIfNeeded()
        #expect(repository.requests == [.init(skip: 0, limit: 3)])
    }

    @Test("첫 페이지 요청을 취소하면 idle로 복구되고 다시 불러올 수 있다")
    func reloadsAfterCancellation() async {
        givenTwoPages()
        let viewModel = makeViewModel()
        repository.holdsRequests = true

        let inFlight = Task { await viewModel.loadIfNeeded() }
        while repository.requests.isEmpty { await Task.yield() }
        inFlight.cancel()
        repository.releaseHeldRequests()
        await inFlight.value

        guard case .idle = viewModel.state else {
            Issue.record("취소 후 idle 상태로 복구되지 않음")
            return
        }

        await viewModel.loadIfNeeded()
        #expect(loadedIDs(viewModel) == [1, 2, 3])
        #expect(repository.requests == [.init(skip: 0, limit: 3), .init(skip: 0, limit: 3)])
    }

    @Test("첫 페이지 요청이 실패하면 failed 상태가 된다")
    func loadFailure() async {
        repository.error = SomeError()
        let viewModel = makeViewModel()
        await viewModel.load()
        guard case .failed = viewModel.state else {
            Issue.record("failed 상태가 아님")
            return
        }
    }

    @Test("다음 페이지를 불러오면 목록에 누적된다")
    func loadMoreAppends() async {
        givenTwoPages()
        let viewModel = makeViewModel()
        await viewModel.load()
        await viewModel.loadMore()
        #expect(loadedIDs(viewModel) == [1, 2, 3, 4, 5])
        #expect(repository.requests == [.init(skip: 0, limit: 3), .init(skip: 3, limit: 3)])
    }

    @Test("마지막 상품이 나타났을 때만 다음 페이지를 요청한다")
    func loadMoreIfNeededOnlyAfterLastItem() async {
        givenTwoPages()
        let viewModel = makeViewModel()
        await viewModel.load()
        await viewModel.loadMoreIfNeeded(after: .stub(id: 2))
        #expect(repository.requests.count == 1)
        await viewModel.loadMoreIfNeeded(after: .stub(id: 3))
        #expect(repository.requests.count == 2)
        #expect(loadedIDs(viewModel) == [1, 2, 3, 4, 5])
    }

    @Test("마지막 페이지에서는 더 요청하지 않는다")
    func loadMoreStopsAtLastPage() async {
        givenTwoPages()
        let viewModel = makeViewModel()
        await viewModel.load()
        await viewModel.loadMore()
        await viewModel.loadMore()
        #expect(repository.requests == [.init(skip: 0, limit: 3), .init(skip: 3, limit: 3)])
    }

    @Test("요청 중에 loadMore를 다시 불러도 요청은 한 번이다")
    func loadMoreIgnoresCallsWhileInFlight() async {
        givenTwoPages()
        let viewModel = makeViewModel()
        await viewModel.load()

        repository.holdsRequests = true
        let inFlight = Task { await viewModel.loadMore() }
        while repository.requests.count < 2 { await Task.yield() }
        #expect(viewModel.isLoadingMore)

        await viewModel.loadMore()
        #expect(repository.requests == [.init(skip: 0, limit: 3), .init(skip: 3, limit: 3)])

        repository.releaseHeldRequests()
        await inFlight.value
        #expect(viewModel.isLoadingMore == false)
        #expect(loadedIDs(viewModel) == [1, 2, 3, 4, 5])
    }

    @Test("다음 페이지 요청이 실패하면 기존 목록은 유지되고 loadMoreError가 남는다")
    func loadMoreFailureKeepsItems() async {
        givenTwoPages()
        let viewModel = makeViewModel()
        await viewModel.load()

        repository.error = SomeError()
        await viewModel.loadMore()
        #expect(loadedIDs(viewModel) == [1, 2, 3])
        #expect(viewModel.loadMoreError != nil)

        repository.error = nil
        await viewModel.loadMore()
        #expect(loadedIDs(viewModel) == [1, 2, 3, 4, 5])
        #expect(viewModel.loadMoreError == nil)
    }

    @Test("보기 방식은 list로 시작하고 토글할 때마다 grid와 번갈아 바뀐다")
    func toggleLayoutAlternates() {
        let viewModel = makeViewModel()
        #expect(viewModel.layout == .list)
        viewModel.toggleLayout()
        #expect(viewModel.layout == .grid)
        viewModel.toggleLayout()
        #expect(viewModel.layout == .list)
    }

    @Test("찜 여부와 토글은 FavoriteStore에 위임한다")
    func favoritesDelegateToStore() {
        let viewModel = makeViewModel()
        #expect(viewModel.isFavorite(1) == false)
        viewModel.toggleFavorite(1)
        #expect(viewModel.isFavorite(1))
        #expect(favoriteStore.isFavorite(1))
    }
}
