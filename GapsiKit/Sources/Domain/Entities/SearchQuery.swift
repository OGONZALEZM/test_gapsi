//
//  SearchQuery.swift
//  gapsi
//
//  Created by Oscar Gonzalez on 6/10/26.
//

import Foundation

public struct SearchQuery: Hashable, Sendable {
    public let value: String

    public init?(_ raw: String) {
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }
        value = trimmed
    }
}
