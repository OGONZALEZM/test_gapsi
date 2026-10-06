//
//  SearchHistory.swift
//  gapsi
//
//  Created by Oscar Gonzalez on 6/10/26.
//

import Foundation

public struct SearchHistory: Equatable, Sendable {
    public private(set) var terms: [String]
    public let limit: Int

    public init(terms: [String], limit: Int = 20) {
        precondition(limit > 0, "SearchHistory limit must be positive")
        self.terms = Array(terms.prefix(limit))
        self.limit = limit
    }

    public mutating func record(_ query: SearchQuery) {
        remove(query.value)
        terms.insert(query.value, at: 0)
        if terms.count > limit {
            terms.removeLast(terms.count - limit)
        }
    }

    public mutating func remove(_ term: String) {
        terms.removeAll { $0.caseInsensitiveCompare(term) == .orderedSame }
    }
}
