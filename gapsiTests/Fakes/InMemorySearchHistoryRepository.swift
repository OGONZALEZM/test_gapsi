//
//  InMemorySearchHistoryRepository.swift
//  gapsi
//
//  Created by Oscar Gonzalez on 6/10/26.
//

import Domain
import os

final class InMemorySearchHistoryRepository: SearchHistoryRepository {
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
