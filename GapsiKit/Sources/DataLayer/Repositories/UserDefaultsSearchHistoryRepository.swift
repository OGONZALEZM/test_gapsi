//
//  UserDefaultsSearchHistoryRepository.swift
//  gapsi
//
//  Created by Oscar Gonzalez on 6/10/26.
//

import Domain
import Foundation

public struct UserDefaultsSearchHistoryRepository: SearchHistoryRepository {
    static let key = "searchHistory.terms"

    private let suiteName: String?

    public init() {
        suiteName = nil
    }

    public init?(suiteName: String) {
        guard UserDefaults(suiteName: suiteName) != nil else { return nil }
        self.suiteName = suiteName
    }

    private var defaults: UserDefaults {
        guard let suiteName else { return .standard }
        return UserDefaults(suiteName: suiteName)!
    }

    public func load() -> [String] {
        defaults.stringArray(forKey: Self.key) ?? []
    }

    public func save(_ terms: [String]) {
        defaults.set(terms, forKey: Self.key)
    }
}
