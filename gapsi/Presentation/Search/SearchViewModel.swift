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

    enum PaginationState: Equatable {
        case idle
        case loading
        case failed(ProductRepositoryError)
        case finished
    }

    @Published var queryText = ""
    @Published private(set) var state: State = .idle
    @Published private(set) var pagination: PaginationState = .idle
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

    func loadNextPage() {
        guard case .results = state, pagination == .idle, paginator.hasMore, let lastQuery else { return }
        pagination = .loading
        fetch(lastQuery, page: paginator.nextPage, kind: .nextPage)
    }

    func retryNextPage() {
        guard case .failed = pagination else { return }
        pagination = .idle
        loadNextPage()
    }

    private func search(_ query: SearchQuery) {
        searchTask?.cancel()
        lastQuery = query
        paginator = ProductPaginator()
        pagination = .idle
        state = .loading
        fetch(query, page: paginator.nextPage, kind: .firstPage)
    }

    private enum PageKind {
        case firstPage
        case nextPage
    }

    private func fetch(_ query: SearchQuery, page pageNumber: Int, kind: PageKind) {
        searchTask = Task { [weak self, searchUseCase] in
            let result: Result<ProductPage, ProductRepositoryError>
            do {
                result = .success(try await searchUseCase.execute(query, page: pageNumber))
            } catch is CancellationError {
                return
            } catch let error as ProductRepositoryError {
                result = .failure(error)
            } catch {
                result = .failure(.invalidData)
            }
            guard !Task.isCancelled, let self else { return }
            switch kind {
            case .firstPage: applyFirstPage(result, pageNumber: pageNumber)
            case .nextPage: applyNextPage(result, pageNumber: pageNumber)
            }
        }
    }

    private func applyFirstPage(_ result: Result<ProductPage, ProductRepositoryError>, pageNumber: Int) {
        switch result {
        case .success(let page):
            let products = paginator.consume(page, pageNumber: pageNumber)
            state = products.isEmpty ? .empty : .results(products)
            pagination = paginator.hasMore ? .idle : .finished
        case .failure(let error):
            state = .failure(error)
        }
    }

    private func applyNextPage(_ result: Result<ProductPage, ProductRepositoryError>, pageNumber: Int) {
        guard case .results(let current) = state else { return }
        switch result {
        case .success(let page):
            let newProducts = paginator.consume(page, pageNumber: pageNumber)
            state = .results(current + newProducts)
            pagination = paginator.hasMore ? .idle : .finished
            if newProducts.isEmpty {
                loadNextPage()
            }
        case .failure(let error):
            pagination = .failed(error)
        }
    }
}
