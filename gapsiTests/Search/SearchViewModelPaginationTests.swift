//
//  SearchViewModelPaginationTests.swift
//  gapsi
//
//  Created by Oscar Gonzalez on 6/10/26.
//

import Domain
import Testing
@testable import gapsi

@MainActor
struct SearchViewModelPaginationTests {
    @Test func appendsOnlyNewProductsFromNextPage() async {
        let repository = StubProductRepository(
            .success(.stub(ids: ["1", "2"], reportedMaxPage: 3)),
            .success(.stub(ids: ["2", "3"]))
        )
        let viewModel = await searched(repository)

        viewModel.loadNextPage()
        #expect(viewModel.pagination == .loading)
        await settle(viewModel)

        #expect(viewModel.state == .results([.stub(id: "1"), .stub(id: "2"), .stub(id: "3")]))
        #expect(viewModel.pagination == .idle)
        #expect(repository.receivedPages == [1, 2])
    }

    @Test func ignoresRequestsWhileAPageIsLoading() async {
        let repository = StubProductRepository(
            .success(.stub(ids: ["1"], reportedMaxPage: 3)),
            .success(.stub(ids: ["2"]))
        )
        let viewModel = await searched(repository)

        viewModel.loadNextPage()
        viewModel.loadNextPage()
        await settle(viewModel)

        #expect(repository.receivedPages == [1, 2])
    }

    @Test func emptyRawPageFinishesPagination() async {
        let repository = StubProductRepository(
            .success(.stub(ids: ["1"])),
            .success(.stub(ids: [], rawCount: 0))
        )
        let viewModel = await searched(repository)

        viewModel.loadNextPage()
        await settle(viewModel)
        viewModel.loadNextPage()

        #expect(viewModel.pagination == .finished)
        #expect(viewModel.state == .results([.stub(id: "1")]))
        #expect(repository.receivedPages == [1, 2])
    }

    @Test func singlePageResultIsFinishedImmediately() async {
        let repository = StubProductRepository(.success(.stub(ids: ["1"], reportedMaxPage: 1)))
        let viewModel = await searched(repository)

        viewModel.loadNextPage()

        #expect(viewModel.pagination == .finished)
        #expect(repository.receivedPages == [1])
    }

    @Test func pageOfDuplicatesLoadsTheFollowingPageAutomatically() async {
        let repository = StubProductRepository(
            .success(.stub(ids: ["1", "2"], reportedMaxPage: 5)),
            .success(.stub(ids: ["2", "1"])),
            .success(.stub(ids: ["3"]))
        )
        let viewModel = await searched(repository)

        viewModel.loadNextPage()
        await settle(viewModel)

        #expect(viewModel.state == .results([.stub(id: "1"), .stub(id: "2"), .stub(id: "3")]))
        #expect(repository.receivedPages == [1, 2, 3])
    }

    @Test func nextPageFailureKeepsLoadedProductsAndCanRetry() async {
        let repository = StubProductRepository(
            .success(.stub(ids: ["1"], reportedMaxPage: 3)),
            .failure(.server),
            .success(.stub(ids: ["2"]))
        )
        let viewModel = await searched(repository)

        viewModel.loadNextPage()
        await settle(viewModel)
        #expect(viewModel.pagination == .failed(.server))
        #expect(viewModel.state == .results([.stub(id: "1")]))

        viewModel.loadNextPage()
        #expect(repository.receivedPages == [1, 2])

        viewModel.retryNextPage()
        await settle(viewModel)

        #expect(viewModel.state == .results([.stub(id: "1"), .stub(id: "2")]))
        #expect(repository.receivedPages == [1, 2, 2])
    }

    @Test func doesNothingBeforeThereAreResults() {
        let repository = StubProductRepository()
        let viewModel = makeViewModel(repository)

        viewModel.loadNextPage()

        #expect(viewModel.searchTask == nil)
        #expect(repository.receivedPages.isEmpty)
    }

    @Test func newSearchDiscardsPendingNextPage() async throws {
        let repository = SuspendingProductRepository(
            suspending: "a",
            onPage: 2,
            otherwiseReturn: .stub(ids: ["1"], reportedMaxPage: 3)
        )
        let viewModel = makeViewModel(repository)
        viewModel.queryText = "a"
        viewModel.submit()
        await viewModel.searchTask?.value

        viewModel.loadNextPage()
        let pendingNextPage = try #require(viewModel.searchTask)
        await repository.waitUntilSuspended()

        viewModel.queryText = "b"
        viewModel.submit()
        await viewModel.searchTask?.value
        #expect(viewModel.pagination == .idle)

        repository.resume(returning: .stub(ids: ["stale"]))
        await pendingNextPage.value

        #expect(viewModel.state == .results([.stub(id: "1")]))
        #expect(viewModel.lastQuery?.value == "b")
    }

    private func searched(_ repository: StubProductRepository) async -> SearchViewModel {
        let viewModel = makeViewModel(repository)
        viewModel.queryText = "nintendo"
        viewModel.submit()
        await viewModel.searchTask?.value
        return viewModel
    }

    private func settle(_ viewModel: SearchViewModel) async {
        while viewModel.pagination == .loading {
            await viewModel.searchTask?.value
        }
    }

    private func makeViewModel(_ repository: any ProductRepository) -> SearchViewModel {
        SearchViewModel(
            searchUseCase: SearchProductsUseCase(repository: repository),
            historyUseCase: SearchHistoryUseCase(repository: InMemorySearchHistoryRepository())
        )
    }
}
