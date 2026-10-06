//
//  StubProductRepository.swift
//  gapsi
//
//  Created by Oscar Gonzalez on 6/10/26.
//

import Domain
import Foundation
import os

final class StubProductRepository: ProductRepository {
    private struct State {
        var outcomes: [Result<ProductPage, ProductRepositoryError>]
        var requests: [(query: SearchQuery, page: Int)] = []
    }

    private let state: OSAllocatedUnfairLock<State>

    init(_ outcomes: Result<ProductPage, ProductRepositoryError>...) {
        state = OSAllocatedUnfairLock(initialState: State(outcomes: outcomes))
    }

    var receivedQueries: [SearchQuery] {
        state.withLock { $0.requests.map(\.query) }
    }

    var receivedPages: [Int] {
        state.withLock { $0.requests.map(\.page) }
    }

    func search(_ query: SearchQuery, page: Int) async throws -> ProductPage {
        let outcome = state.withLock { state in
            state.requests.append((query, page))
            return state.outcomes.isEmpty ? .failure(.invalidData) : state.outcomes.removeFirst()
        }
        return try outcome.get()
    }
}
