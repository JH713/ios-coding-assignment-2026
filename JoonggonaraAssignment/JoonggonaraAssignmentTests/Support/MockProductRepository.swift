import os
@testable import JoonggonaraAssignment

final class MockProductRepository: ProductRepository {
    struct Request: Equatable {
        let skip: Int
        let limit: Int
    }

    struct NotFound: Error {}

    private struct State {
        var pages: [Int: ProductPage] = [:]
        var error: Error?
        var holdsRequests = false
        var requests: [Request] = []
        var requestedProductIDs: [Int] = []
        var pending: [CheckedContinuation<Void, Never>] = []
    }

    private let state = OSAllocatedUnfairLock(initialState: State())

    var pages: [Int: ProductPage] {
        get { state.withLock { $0.pages } }
        set { state.withLock { $0.pages = newValue } }
    }

    var error: Error? {
        get { state.withLock { $0.error } }
        set { state.withLock { $0.error = newValue } }
    }

    var holdsRequests: Bool {
        get { state.withLock { $0.holdsRequests } }
        set { state.withLock { $0.holdsRequests = newValue } }
    }

    var requests: [Request] {
        state.withLock { $0.requests }
    }

    var requestedProductIDs: [Int] {
        state.withLock { $0.requestedProductIDs }
    }

    func fetchProducts(skip: Int, limit: Int) async throws -> ProductPage {
        await withCheckedContinuation { continuation in
            let resumesImmediately = state.withLock {
                $0.requests.append(Request(skip: skip, limit: limit))
                guard $0.holdsRequests else { return true }
                $0.pending.append(continuation)
                return false
            }
            if resumesImmediately {
                continuation.resume()
            }
        }

        try Task.checkCancellation()

        let result: Result<ProductPage, Error> = state.withLock {
            if let error = $0.error { return .failure(error) }
            guard let page = $0.pages[skip] else { return .failure(NotFound()) }
            return .success(page)
        }
        return try result.get()
    }

    func fetchProduct(id: Int) async throws -> Product {
        await withCheckedContinuation { continuation in
            let resumesImmediately = state.withLock {
                $0.requestedProductIDs.append(id)
                guard $0.holdsRequests else { return true }
                $0.pending.append(continuation)
                return false
            }
            if resumesImmediately {
                continuation.resume()
            }
        }
        try Task.checkCancellation()

        let result: Result<Product, Error> = state.withLock {
            if let error = $0.error { return .failure(error) }
            guard let product = $0.pages.values.flatMap(\.items).first(where: { $0.id == id }) else {
                return .failure(NotFound())
            }
            return .success(product)
        }
        return try result.get()
    }

    func releaseHeldRequests() {
        let continuations = state.withLock {
            $0.holdsRequests = false
            let pending = $0.pending
            $0.pending = []
            return pending
        }
        continuations.forEach { $0.resume() }
    }
}
