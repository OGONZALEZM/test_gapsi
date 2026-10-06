//
//  SearchViewModelTests.swift
//  gapsi
//
//  Created by Oscar Gonzalez on 6/10/26.
//

import Domain
import Testing
@testable import gapsi

@MainActor
struct SearchViewModelTests {
    private let history = InMemorySearchHistoryRepository()

    @Test(arguments: ["", "   ", "\n "])
    func blankQueryDoesNothing(_ text: String) {
        let viewModel = makeViewModel(StubProductRepository(.success(.stub(ids: ["1"]))))
        viewModel.queryText = text

        viewModel.submit()

        #expect(viewModel.searchTask == nil)
        #expect(viewModel.state == .idle)
        #expect(history.load().isEmpty)
    }

    @Test func successShowsResultsAndRecordsTrimmedTerm() async {
        let viewModel = makeViewModel(StubProductRepository(.success(.stub(ids: ["1", "2"]))))
        viewModel.queryText = "  nintendo  "

        viewModel.submit()
        #expect(viewModel.state == .loading)
        await viewModel.searchTask?.value

        #expect(viewModel.state == .results([.stub(id: "1"), .stub(id: "2")]))
        #expect(history.load() == ["nintendo"])
    }

    @Test func emptyPageShowsEmptyState() async {
        let viewModel = makeViewModel(StubProductRepository(.success(.stub(ids: [], rawCount: 0))))
        viewModel.queryText = "zzzz"

        viewModel.submit()
        await viewModel.searchTask?.value

        #expect(viewModel.state == .empty)
        #expect(viewModel.lastQuery?.value == "zzzz")
    }

    @Test func repositoryErrorShowsFailure() async {
        let viewModel = makeViewModel(StubProductRepository(.failure(.rateLimited)))
        viewModel.queryText = "nintendo"

        viewModel.submit()
        await viewModel.searchTask?.value

        #expect(viewModel.state == .failure(.rateLimited))
    }

    @Test func retryRepeatsLastSearch() async {
        let repository = StubProductRepository(.failure(.connectivity), .success(.stub(ids: ["1"])))
        let viewModel = makeViewModel(repository)
        viewModel.queryText = "nintendo"
        viewModel.submit()
        await viewModel.searchTask?.value

        viewModel.queryText = "edited but not submitted"
        viewModel.retry()
        await viewModel.searchTask?.value

        #expect(viewModel.state == .results([.stub(id: "1")]))
        #expect(repository.receivedQueries.map(\.value) == ["nintendo", "nintendo"])
        #expect(history.load() == ["nintendo"])
    }

    @Test func staleSearchDoesNotOverrideNewerOne() async throws {
        let repository = SuspendingProductRepository(suspending: "a", otherwiseReturn: .stub(ids: ["b"]))
        let viewModel = makeViewModel(repository)

        viewModel.queryText = "a"
        viewModel.submit()
        let searchA = try #require(viewModel.searchTask)
        await repository.waitUntilSuspended()

        viewModel.queryText = "b"
        viewModel.submit()
        await viewModel.searchTask?.value
        #expect(viewModel.state == .results([.stub(id: "b")]))

        repository.resume(returning: .stub(ids: ["a"]))
        await searchA.value

        #expect(viewModel.state == .results([.stub(id: "b")]))
        #expect(viewModel.lastQuery?.value == "b")
    }

    private func makeViewModel(_ repository: any ProductRepository) -> SearchViewModel {
        SearchViewModel(
            searchUseCase: SearchProductsUseCase(repository: repository),
            historyUseCase: SearchHistoryUseCase(repository: history)
        )
    }
}
