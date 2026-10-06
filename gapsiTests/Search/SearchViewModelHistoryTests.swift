import Domain
import Testing
@testable import gapsi

@MainActor
struct SearchViewModelHistoryTests {
    @Test func loadsPersistedHistoryOnInit() {
        let viewModel = makeViewModel(history: ["sony", "nintendo"])

        #expect(viewModel.history == ["sony", "nintendo"])
    }

    @Test func submitPutsTermFirstAndPersistsIt() async {
        let repository = InMemorySearchHistoryRepository(terms: ["sony", "nintendo"])
        let viewModel = makeViewModel(historyRepository: repository)
        viewModel.queryText = " Nintendo "

        viewModel.submit()
        await viewModel.searchTask?.value

        #expect(viewModel.history == ["Nintendo", "sony"])
        #expect(repository.load() == ["Nintendo", "sony"])
    }

    @Test func searchingFromHistoryRunsThatTerm() async {
        let products = StubProductRepository(.success(.stub(ids: ["1"])))
        let viewModel = makeViewModel(products: products, history: ["sony", "nintendo"])

        viewModel.search(historyTerm: "nintendo")
        await viewModel.searchTask?.value

        #expect(viewModel.queryText == "nintendo")
        #expect(products.receivedQueries.map(\.value) == ["nintendo"])
        #expect(viewModel.history == ["nintendo", "sony"])
        #expect(viewModel.state == .results([.stub(id: "1")]))
    }

    @Test func removingTermUpdatesAndPersistsHistory() {
        let repository = InMemorySearchHistoryRepository(terms: ["sony", "nintendo"])
        let viewModel = makeViewModel(historyRepository: repository)

        viewModel.removeHistoryTerm("SONY")

        #expect(viewModel.history == ["nintendo"])
        #expect(repository.load() == ["nintendo"])
    }

    @Test func suggestionsShowAllHistoryWhenQueryIsBlank() {
        let viewModel = makeViewModel(history: ["sony", "nintendo"])
        viewModel.queryText = "  "

        #expect(viewModel.historySuggestions == ["sony", "nintendo"])
    }

    @Test func suggestionsMatchCaseInsensitivelyAndSkipExactMatch() {
        let viewModel = makeViewModel(history: ["nintendo switch", "Nintendo", "sony"])
        viewModel.queryText = "nintendo"

        #expect(viewModel.historySuggestions == ["nintendo switch"])
    }

    private func makeViewModel(
        products: any ProductRepository = StubProductRepository(),
        history: [String] = []
    ) -> SearchViewModel {
        makeViewModel(products: products, historyRepository: InMemorySearchHistoryRepository(terms: history))
    }

    private func makeViewModel(
        products: any ProductRepository = StubProductRepository(),
        historyRepository: InMemorySearchHistoryRepository
    ) -> SearchViewModel {
        SearchViewModel(
            searchUseCase: SearchProductsUseCase(repository: products),
            historyUseCase: SearchHistoryUseCase(repository: historyRepository)
        )
    }
}
