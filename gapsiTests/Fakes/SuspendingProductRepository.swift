//
//  SuspendingProductRepository.swift
//  gapsi
//
//  Created by Oscar Gonzalez on 6/10/26.
//

import Domain
import os

final class SuspendingProductRepository: ProductRepository {
    private struct State {
        var suspended: [String: CheckedContinuation<ProductPage, any Error>] = [:]
        var arrivalWaiters: [String: CheckedContinuation<Void, Never>] = [:]
    }

    private let suspendedQuery: String
    private let suspendedPage: Int
    private let immediatePage: ProductPage
    private let state = OSAllocatedUnfairLock(initialState: State())

    init(suspending suspendedQuery: String, onPage suspendedPage: Int = 1, otherwiseReturn immediatePage: ProductPage) {
        self.suspendedQuery = suspendedQuery
        self.suspendedPage = suspendedPage
        self.immediatePage = immediatePage
    }

    func search(_ query: SearchQuery, page: Int) async throws -> ProductPage {
        guard query.value == suspendedQuery, page == suspendedPage else { return immediatePage }

        return try await withCheckedThrowingContinuation { continuation in
            let waiter = state.withLock { state in
                state.suspended[query.value] = continuation
                return state.arrivalWaiters.removeValue(forKey: query.value)
            }
            waiter?.resume()
        }
    }

    func waitUntilSuspended() async {
        await withCheckedContinuation { waiter in
            let alreadySuspended = state.withLock { state in
                guard state.suspended[suspendedQuery] == nil else { return true }
                state.arrivalWaiters[suspendedQuery] = waiter
                return false
            }
            if alreadySuspended { waiter.resume() }
        }
    }

    func resume(returning page: ProductPage) {
        let continuation = state.withLock { $0.suspended.removeValue(forKey: suspendedQuery) }
        continuation?.resume(returning: page)
    }
}
