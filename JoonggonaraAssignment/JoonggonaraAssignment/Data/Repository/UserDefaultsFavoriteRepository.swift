import Foundation

nonisolated struct UserDefaultsFavoriteRepository: FavoriteRepository {
    private let userDefaults: UserDefaults
    private let key: String

    init(userDefaults: UserDefaults = .standard, key: String = "favoriteProductIDs") {
        self.userDefaults = userDefaults
        self.key = key
    }

    func loadFavoriteIDs() -> Set<Int> {
        Set(userDefaults.array(forKey: key) as? [Int] ?? [])
    }

    func saveFavoriteIDs(_ ids: Set<Int>) {
        userDefaults.set(Array(ids), forKey: key)
    }
}
