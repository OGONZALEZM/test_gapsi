//
//  SearchHistoryRepository.swift
//  gapsi
//
//  Created by Oscar Gonzalez on 6/10/26.
//

import Foundation

public protocol SearchHistoryRepository: Sendable {
    func load() -> [String]
    func save(_ terms: [String])
}
