//
//  ProductPaginatorTests.swift
//  gapsi
//
//  Created by Oscar Gonzalez on 6/10/26.
//

import Testing
@testable import Domain

struct ProductPaginatorTests {
    @Test func firstPageSetsMaxPageAndLaterPagesCannotChangeIt() {
        var paginator = ProductPaginator()
        _ = paginator.consume(.stub(ids: ["1"], reportedMaxPage: 2), pageNumber: 1)
        _ = paginator.consume(.stub(ids: ["2"], reportedMaxPage: 10), pageNumber: 2)

        #expect(paginator.hasMore == false)
    }

    @Test func emptyRawPageEndsPagination() {
        var paginator = ProductPaginator()
        let products = paginator.consume(.stub(ids: [], rawCount: 0), pageNumber: 1)

        #expect(products.isEmpty)
        #expect(paginator.hasMore == false)
    }

    @Test func pageOfOnlyDuplicatesKeepsPaginating() {
        var paginator = ProductPaginator()
        _ = paginator.consume(.stub(ids: ["1", "2"]), pageNumber: 1)
        let products = paginator.consume(.stub(ids: ["2", "1"]), pageNumber: 2)

        #expect(products.isEmpty)
        #expect(paginator.hasMore)
        #expect(paginator.nextPage == 3)
    }

    @Test func returnsOnlyUnseenProductsInOrder() {
        var paginator = ProductPaginator()
        _ = paginator.consume(.stub(ids: ["1", "2"]), pageNumber: 1)
        let products = paginator.consume(.stub(ids: ["3", "2", "4", "3"]), pageNumber: 2)

        #expect(products.map(\.id) == ["3", "4"])
    }

    @Test func reachingMaxPageEndsPagination() {
        var paginator = ProductPaginator()
        _ = paginator.consume(.stub(ids: ["1"], reportedMaxPage: 2), pageNumber: 1)
        #expect(paginator.hasMore)

        _ = paginator.consume(.stub(ids: ["2"]), pageNumber: 2)
        #expect(paginator.hasMore == false)
    }

    @Test(arguments: [0, 1, 3])
    func unexpectedPageNumberIsIgnored(_ pageNumber: Int) {
        var paginator = ProductPaginator()
        _ = paginator.consume(.stub(ids: ["1"], reportedMaxPage: 5), pageNumber: 1)
        let before = paginator

        let products = paginator.consume(.stub(ids: ["9"], rawCount: 0), pageNumber: pageNumber)

        #expect(products.isEmpty)
        #expect(paginator == before)
    }

    @Test func pagesAfterEndAreIgnored() {
        var paginator = ProductPaginator()
        _ = paginator.consume(.stub(ids: [], rawCount: 0), pageNumber: 1)
        let before = paginator

        let products = paginator.consume(.stub(ids: ["1"]), pageNumber: 2)

        #expect(products.isEmpty)
        #expect(paginator == before)
    }
}
