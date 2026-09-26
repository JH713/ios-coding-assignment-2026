import SwiftUI

struct ProductListView: View {
    @State private var viewModel: ProductListViewModel

    init(viewModel: ProductListViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        content
            .navigationTitle("상품")
            .task { await viewModel.loadIfNeeded() }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .idle, .loading:
            ProgressView()
        case .failed(let error):
            ContentUnavailableView {
                Label("불러오지 못했습니다", systemImage: "exclamationmark.triangle")
            } description: {
                Text(error.localizedDescription)
            } actions: {
                Button("다시 시도") { Task { await viewModel.load() } }
            }
        case .loaded(let products):
            List {
                ForEach(products) { product in
                    ProductRow(
                        product: product,
                        isFavorite: viewModel.isFavorite(product.id),
                        onToggleFavorite: { viewModel.toggleFavorite(product.id) }
                    )
                        .onAppear {
                            if product.id == products.last?.id {
                                Task { await viewModel.loadMore() }
                            }
                        }
                }
                footer
            }
            .listStyle(.plain)
        }
    }

    @ViewBuilder
    private var footer: some View {
        if viewModel.isLoadingMore {
            ProgressView()
                .frame(maxWidth: .infinity)
        } else if viewModel.loadMoreError != nil {
            Button("더 불러오지 못했습니다. 다시 시도") {
                Task { await viewModel.loadMore() }
            }
            .frame(maxWidth: .infinity)
        }
    }
}
