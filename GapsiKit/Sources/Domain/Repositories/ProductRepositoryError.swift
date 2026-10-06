//
//  ProductRepositoryError.swift
//  gapsi
//
//  Created by Oscar Gonzalez on 6/10/26.
//

import Foundation

public enum ProductRepositoryError: Error, Equatable, Sendable {
    case connectivity
    case unauthorized
    case rateLimited
    case server
    case invalidData
}
