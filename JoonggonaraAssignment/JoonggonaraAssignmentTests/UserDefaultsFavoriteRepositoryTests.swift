import Foundation
import Testing
@testable import JoonggonaraAssignment

final class UserDefaultsFavoriteRepositoryTests {
    private let suiteName = "test.favorites.\(UUID().uuidString)"
    private let userDefaults: UserDefaults
    private let repository: UserDefaultsFavoriteRepository

    init() throws {
        userDefaults = try #require(UserDefaults(suiteName: suiteName))
        repository = UserDefaultsFavoriteRepository(userDefaults: userDefaults)
    }

    deinit {
        UserDefaults(suiteName: suiteName)?.removePersistentDomain(forName: suiteName)
    }

    @Test("저장한 적이 없으면 빈 집합을 돌려준다")
    func loadsEmptyWhenNothingSaved() {
        #expect(repository.loadFavoriteIDs().isEmpty)
    }

    @Test("저장한 ID 집합을 그대로 읽어온다")
    func roundTrips() {
        repository.saveFavoriteIDs([3, 1, 2])
        #expect(repository.loadFavoriteIDs() == [1, 2, 3])
    }

    @Test("다시 저장하면 이전 값을 덮어쓴다")
    func overwritesPreviousValue() {
        repository.saveFavoriteIDs([1, 2])
        repository.saveFavoriteIDs([9])
        #expect(repository.loadFavoriteIDs() == [9])
    }

    @Test("빈 집합을 저장하면 빈 집합을 읽어온다")
    func savesEmptySet() {
        repository.saveFavoriteIDs([1])
        repository.saveFavoriteIDs([])
        #expect(repository.loadFavoriteIDs().isEmpty)
    }

    @Test("키에 다른 타입의 값이 있으면 빈 집합을 돌려준다")
    func loadsEmptyWhenStoredValueHasWrongType() {
        userDefaults.set("not an array", forKey: "favoriteProductIDs")
        #expect(repository.loadFavoriteIDs().isEmpty)
    }
}
