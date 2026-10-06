//
//  ProductRepository.swift
//  gapsi
//
//  Created by Oscar Gonzalez on 6/10/26.
//

import Foundation

public protocol ProductRepository: Sendable {
    func search(_ query: SearchQuery, page: Int) async throws -> ProductPage
}
