//
//  SearchResponseMapperTests.swift
//  gapsi
//
//  Created by Oscar Gonzalez on 6/10/26.
//

import Foundation
import Testing
@testable import DataLayer
@testable import Domain

struct SearchResponseMapperTests {
    @Test func mapsFirstPageGridProductsOnly() throws {
        let page = try map(fixture: "search_nintendo_p1")

        #expect(page.products.count == 41)
        #expect(page.rawCount == 41)
        #expect(page.reportedMaxPage == 15)
        #expect(page.products.first?.id == "15949610846")
        #expect(page.products.first?.price == 499)
        #expect(page.products.allSatisfy { $0.currencyCode == "USD" })
        #expect(page.products.filter { $0.id == "15949610846" }.count == 2)
    }

    @Test func pricesAreExactDecimals() throws {
        let prices = try map(fixture: "search_nintendo_p1").products.map(\.price)

        #expect(prices.contains(Decimal(string: "189.4")!))
        #expect(prices.contains(Decimal(string: "99.99")!))
    }

    @Test func emptyPageHasNoProducts() throws {
        let page = try map(fixture: "search_nintendo_p15")

        #expect(page.products.isEmpty)
        #expect(page.rawCount == 0)
    }

    @Test func discardsInvalidItemsButCountsThemAsRaw() throws {
        let page = try map(json: response(items: [
            product(id: "valid"),
            product(id: "no-price", price: "null"),
            product(id: "no-name", name: "null"),
            product(id: "blank-name", name: #""  ""#),
            product(id: "bad-image", image: #""not a url""#),
            #"{"__typename": "AdPlaceholder"}"#,
            #"{"__typename": "TileTakeOverProductPlaceholder"}"#,
        ]))

        #expect(page.products.map(\.id) == ["valid"])
        #expect(page.rawCount == 5)
    }

    @Test func ignoresCarouselStacks() throws {
        let json = """
        {"item": {"props": {"pageProps": {"initialData": {"searchResult": {"itemStacks": [
            {"layoutEnum": "CAROUSEL", "items": [\(product(id: "carousel"))]},
            {"layoutEnum": "GRID", "items": [\(product(id: "grid"))]}
        ]}}}}}}
        """

        let page = try map(json: json)

        #expect(page.products.map(\.id) == ["grid"])
        #expect(page.rawCount == 1)
    }

    @Test func missingItemStacksIsEmpty() throws {
        let page = try map(json: #"{"item": {"props": {"pageProps": {"initialData": {"searchResult": {"paginationV2": {"maxPage": 3}}}}}}}"#)

        #expect(page.products.isEmpty)
        #expect(page.rawCount == 0)
        #expect(page.reportedMaxPage == 3)
    }

    @Test func missingSearchResultIsEmpty() throws {
        let page = try map(json: #"{"item": {"props": {"pageProps": {"initialData": {}}}}}"#)

        #expect(page.products.isEmpty)
        #expect(page.reportedMaxPage == nil)
    }

    @Test func defaultsCurrencyToUSD() throws {
        let page = try map(json: response(items: [product(id: "1", priceInfo: "null")]))

        #expect(page.products.first?.currencyCode == "USD")
    }

    private func map(fixture name: String) throws -> ProductPage {
        try map(data: FixtureLoader.data(name))
    }

    private func map(json: String) throws -> ProductPage {
        try map(data: Data(json.utf8))
    }

    private func map(data: Data) throws -> ProductPage {
        SearchResponseMapper.map(try JSONDecoder().decode(SearchResponseDTO.self, from: data))
    }

    private func response(items: [String]) -> String {
        """
        {"item": {"props": {"pageProps": {"initialData": {"searchResult": {
            "itemStacks": [{"layoutEnum": "GRID", "items": [\(items.joined(separator: ","))]}]
        }}}}}}
        """
    }

    private func product(
        id: String,
        name: String = #""Switch""#,
        price: String = "10.5",
        image: String = #""https://example.com/a.jpg""#,
        priceInfo: String = #"{"priceDetails": {"currency": "MXN"}}"#
    ) -> String {
        """
        {"__typename": "Product", "usItemId": "\(id)", "name": \(name), "price": \(price), "image": \(image), "priceInfo": \(priceInfo)}
        """
    }
}
