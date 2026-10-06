//
//  SearchProductsUseCase.swift
//  gapsi
//
//  Created by Oscar Gonzalez on 6/10/26.
//

import Foundation

public struct SearchProductsUseCase: Sendable {
    private let repository: any ProductRepository

    public init(repository: any ProductRepository) {
        self.repository = repository
    }

    public func execute(_ query: SearchQuery, page: Int) async throws -> ProductPage {
        try await repository.search(query, page: page)
    }
}
