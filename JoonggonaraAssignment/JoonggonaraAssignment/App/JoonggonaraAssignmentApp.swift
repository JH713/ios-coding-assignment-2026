import SwiftUI

@main
struct JoonggonaraAssignmentApp: App {
    @State private var favoriteStore = FavoriteStore(repository: UserDefaultsFavoriteRepository())
    private let productRepository = RemoteProductRepository()

    var body: some Scene {
        WindowGroup {
            NavigationStack {
                ProductListView(
                    viewModel: ProductListViewModel(
                        repository: productRepository,
                        favoriteStore: favoriteStore
                    )
                )
            }
        }
    }
}
