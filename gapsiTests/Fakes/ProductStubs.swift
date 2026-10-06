//
//  ProductStubs.swift
//  gapsi
//
//  Created by Oscar Gonzalez on 6/10/26.
//

import Domain
import Foundation

extension Product {
    static func stub(id: String) -> Product {
        Product(
            id: id,
            title: "Product \(id)",
            price: 10,
            currencyCode: "USD",
            thumbnailURL: URL(string: "https://example.com/\(id).jpg")!
        )
    }
}

extension ProductPage {
    static func stub(ids: [String], rawCount: Int? = nil, reportedMaxPage: Int? = nil) -> ProductPage {
        ProductPage(
            products: ids.map(Product.stub),
            rawCount: rawCount ?? ids.count,
            reportedMaxPage: reportedMaxPage
        )
    }
}
