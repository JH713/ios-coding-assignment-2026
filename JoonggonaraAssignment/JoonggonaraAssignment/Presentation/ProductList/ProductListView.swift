import SwiftUI

struct ProductListView: View {
    @State private var viewModel: ProductListViewModel
    @State private var scrolledID: Int?

    init(viewModel: ProductListViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        content
            .navigationTitle("상품")
            .toolbar {
                Button {
                    viewModel.toggleLayout()
                } label: {
                    Image(systemName: viewModel.layout == .list ? "square.grid.2x2" : "list.bullet")
                }
                .accessibilityLabel(viewModel.layout == .list ? "2열로 보기" : "1열로 보기")
            }
            .task { await viewModel.loadIfNeeded() }
            .navigationDestination(for: Int.self) { productID in
                ProductDetailView(viewModel: viewModel.detailViewModel(for: productID))
            }
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
            ScrollView {
                switch viewModel.layout {
                case .list:
                    listContent(products)
                case .grid:
                    gridContent(products)
                }
                footer
            }
            .contentMargins(.horizontal, 16, for: .scrollContent)
            .scrollPosition(id: $scrolledID, anchor: .top)
        }
    }

    private func listContent(_ products: [Product]) -> some View {
        LazyVStack(spacing: 0) {
            ForEach(products) { product in
                NavigationLink(value: product.id) {
                    ProductRow(
                        product: product,
                        isFavorite: viewModel.isFavorite(product.id),
                        onToggleFavorite: { viewModel.toggleFavorite(product.id) }
                    )
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .onAppear { Task { await viewModel.loadMoreIfNeeded(after: product) } }
                Divider()
            }
        }
        .scrollTargetLayout()
    }

    private func gridContent(_ products: [Product]) -> some View {
        LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)], spacing: 16) {
            ForEach(products) { product in
                NavigationLink(value: product.id) {
                    ProductGridCell(
                        product: product,
                        isFavorite: viewModel.isFavorite(product.id),
                        onToggleFavorite: { viewModel.toggleFavorite(product.id) }
                    )
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .onAppear { Task { await viewModel.loadMoreIfNeeded(after: product) } }
            }
        }
        .scrollTargetLayout()
    }

    @ViewBuilder
    private var footer: some View {
        if viewModel.isLoadingMore {
            ProgressView()
                .frame(maxWidth: .infinity)
                .padding()
        } else if viewModel.loadMoreError != nil {
            Button("더 불러오지 못했습니다. 다시 시도") {
                Task { await viewModel.loadMore() }
            }
            .frame(maxWidth: .infinity)
            .padding()
        }
    }
}
