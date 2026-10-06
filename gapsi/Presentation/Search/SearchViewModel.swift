//
//  SearchViewModel.swift
//  gapsi
//
//  Created by Oscar Gonzalez on 6/10/26.
//

import Combine
import Domain
import Foundation

@MainActor
final class SearchViewModel: ObservableObject {
    enum State: Equatable {
        case idle
        case loading
        case results([Product])
        case empty
        case failure(ProductRepositoryError)
    }

    @Published var queryText = ""
    @Published private(set) var state: State = .idle
    @Published private(set) var lastQuery: SearchQuery?
    @Published private(set) var history: [String]

    private(set) var searchTask: Task<Void, Never>?

    private let searchUseCase: SearchProductsUseCase
    private let historyUseCase: SearchHistoryUseCase
    private var paginator = ProductPaginator()

    init(searchUseCase: SearchProductsUseCase, historyUseCase: SearchHistoryUseCase) {
        self.searchUseCase = searchUseCase
        self.historyUseCase = historyUseCase
        history = historyUseCase.terms()
    }

    var historySuggestions: [String] {
        let text = queryText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return history }
        return history.filter {
            $0.localizedCaseInsensitiveContains(text) && $0.caseInsensitiveCompare(text) != .orderedSame
        }
    }

    func submit() {
        guard let query = SearchQuery(queryText) else { return }
        history = historyUseCase.record(query)
        search(query)
    }

    func search(historyTerm term: String) {
        queryText = term
        submit()
    }

    func removeHistoryTerm(_ term: String) {
        history = historyUseCase.remove(term)
    }

    func retry() {
        guard let lastQuery else { return }
        search(lastQuery)
    }

    private func search(_ query: SearchQuery) {
        searchTask?.cancel()
        lastQuery = query
        paginator = ProductPaginator()
        state = .loading

        let pageNumber = paginator.nextPage
        searchTask = Task { [weak self, searchUseCase] in
            let result: Result<ProductPage, any Error>
            do {
                result = .success(try await searchUseCase.execute(query, page: pageNumber))
            } catch {
                result = .failure(error)
            }
            guard !Task.isCancelled else { return }
            self?.apply(result, pageNumber: pageNumber)
        }
    }

    private func apply(_ result: Result<ProductPage, any Error>, pageNumber: Int) {
        switch result {
        case .success(let page):
            let products = paginator.consume(page, pageNumber: pageNumber)
            state = products.isEmpty ? .empty : .results(products)
        case .failure(is CancellationError):
            return
        case .failure(let error as ProductRepositoryError):
            state = .failure(error)
        case .failure:
            state = .failure(.invalidData)
        }
    }
}
