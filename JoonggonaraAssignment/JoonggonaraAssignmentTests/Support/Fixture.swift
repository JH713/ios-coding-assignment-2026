import Foundation

enum Fixture {
    enum Error: Swift.Error {
        case notFound(String)
    }

    static func data(_ name: String) throws -> Data {
        guard let url = Bundle(for: BundleLocator.self).url(forResource: name, withExtension: "json") else {
            throw Error.notFound(name)
        }
        return try Data(contentsOf: url)
    }

    private final class BundleLocator {}
}
