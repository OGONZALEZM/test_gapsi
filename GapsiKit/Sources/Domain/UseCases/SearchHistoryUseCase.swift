//
//  SearchHistoryUseCase.swift
//  gapsi
//
//  Created by Oscar Gonzalez on 6/10/26.
//

import Foundation

public struct SearchHistoryUseCase: Sendable {
    private let repository: any SearchHistoryRepository
    private let limit: Int

    public init(repository: any SearchHistoryRepository, limit: Int = 20) {
        self.repository = repository
        self.limit = limit
    }

    public func terms() -> [String] {
        SearchHistory(terms: repository.load(), limit: limit).terms
    }

    public func record(_ query: SearchQuery) -> [String] {
        mutate { $0.record(query) }
    }

    public func remove(_ term: String) -> [String] {
        mutate { $0.remove(term) }
    }

    private func mutate(_ change: (inout SearchHistory) -> Void) -> [String] {
        var history = SearchHistory(terms: repository.load(), limit: limit)
        change(&history)
        repository.save(history.terms)
        return history.terms
    }
}
