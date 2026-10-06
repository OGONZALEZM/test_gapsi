//
//  SearchHistoryUseCaseTests.swift
//  gapsi
//
//  Created by Oscar Gonzalez on 6/10/26.
//

import os
import Testing
@testable import Domain

struct SearchHistoryUseCaseTests {
    @Test func recordPersistsResultingList() {
        let repository = InMemorySearchHistoryRepository(terms: ["tv", "laptop"])
        let useCase = SearchHistoryUseCase(repository: repository)

        let terms = useCase.record(SearchQuery("Laptop")!)

        #expect(terms == ["Laptop", "tv"])
        #expect(repository.load() == terms)
    }

    @Test func removePersistsResultingList() {
        let repository = InMemorySearchHistoryRepository(terms: ["tv", "laptop"])
        let useCase = SearchHistoryUseCase(repository: repository)

        let terms = useCase.remove("TV")

        #expect(terms == ["laptop"])
        #expect(repository.load() == terms)
    }
}

private final class InMemorySearchHistoryRepository: SearchHistoryRepository {
    private let storage: OSAllocatedUnfairLock<[String]>

    init(terms: [String] = []) {
        storage = OSAllocatedUnfairLock(initialState: terms)
    }

    func load() -> [String] {
        storage.withLock { $0 }
    }

    func save(_ terms: [String]) {
        storage.withLock { $0 = terms }
    }
}
