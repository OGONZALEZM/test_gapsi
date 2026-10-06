//
//  UserDefaultsSearchHistoryRepositoryTests.swift
//  gapsi
//
//  Created by Oscar Gonzalez on 6/10/26.
//

import Foundation
import Testing
@testable import DataLayer

struct UserDefaultsSearchHistoryRepositoryTests {
    @Test func isEmptyByDefault() throws {
        try withTemporaryRepository { repository, _ in
            #expect(repository.load().isEmpty)
        }
    }

    @Test func savesAndLoadsTermsAsIs() throws {
        try withTemporaryRepository { repository, suiteName in
            repository.save(["switch", "Zelda", "switch"])

            let reloaded = try #require(UserDefaultsSearchHistoryRepository(suiteName: suiteName))
            #expect(reloaded.load() == ["switch", "Zelda", "switch"])
        }
    }

    @Test func persistsInsideItsSuite() throws {
        try withTemporaryRepository { repository, suiteName in
            repository.save(["zelda"])

            let stored = UserDefaults(suiteName: suiteName)?.stringArray(forKey: UserDefaultsSearchHistoryRepository.key)
            #expect(stored == ["zelda"])
        }
    }

    @Test func rejectsInvalidSuiteName() {
        #expect(UserDefaultsSearchHistoryRepository(suiteName: UserDefaults.globalDomain) == nil)
    }

    private func withTemporaryRepository(
        _ body: (UserDefaultsSearchHistoryRepository, String) throws -> Void
    ) throws {
        let suiteName = "UserDefaultsSearchHistoryRepositoryTests.\(UUID().uuidString)"
        defer { UserDefaults(suiteName: suiteName)?.removePersistentDomain(forName: suiteName) }
        try body(try #require(UserDefaultsSearchHistoryRepository(suiteName: suiteName)), suiteName)
    }
}
