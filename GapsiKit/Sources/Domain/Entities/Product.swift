//
//  Foundation.swift
//  gapsi
//
//  Created by Oscar Gonzalez on 6/10/26.
//

import Foundation

public struct Product: Identifiable, Hashable, Sendable {
    public let id: String
    public let title: String
    public let price: Decimal
    public let currencyCode: String
    public let thumbnailURL: URL

    public init(id: String, title: String, price: Decimal, currencyCode: String, thumbnailURL: URL) {
        self.id = id
        self.title = title
        self.price = price
        self.currencyCode = currencyCode
        self.thumbnailURL = thumbnailURL
    }
}
