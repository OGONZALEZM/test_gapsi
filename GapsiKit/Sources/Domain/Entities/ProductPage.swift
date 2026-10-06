//
//  ProductPage.swift
//  gapsi
//
//  Created by Oscar Gonzalez on 6/10/26.
//

import Foundation

public struct ProductPage: Equatable, Sendable {
    public let products: [Product]
    public let rawCount: Int
    public let reportedMaxPage: Int?

    public init(products: [Product], rawCount: Int, reportedMaxPage: Int?) {
        self.products = products
        self.rawCount = rawCount
        self.reportedMaxPage = reportedMaxPage
    }
}
