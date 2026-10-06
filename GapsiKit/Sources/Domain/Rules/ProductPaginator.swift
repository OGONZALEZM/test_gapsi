//
//  ProductPaginator.swift
//  gapsi
//
//  Created by Oscar Gonzalez on 6/10/26.
//

import Foundation

public struct ProductPaginator: Equatable, Sendable {
    public private(set) var nextPage = 1
    public private(set) var hasMore = true
    private var maxPage: Int?
    private var seenIDs: Set<String> = []

    public init() {}

    public mutating func consume(_ page: ProductPage, pageNumber: Int) -> [Product] {
        guard hasMore, pageNumber == nextPage else { return [] }

        if pageNumber == 1 {
            maxPage = page.reportedMaxPage
        }
        hasMore = page.rawCount > 0 && (maxPage.map { pageNumber < $0 } ?? true)
        nextPage += 1

        return page.products.filter { seenIDs.insert($0.id).inserted }
    }
}
