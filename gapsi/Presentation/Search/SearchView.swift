//
//  SearchView.swift
//  gapsi
//
//  Created by Oscar Gonzalez on 6/10/26.
//

import Domain
import SwiftUI

struct SearchView: View {
    @StateObject private var viewModel: SearchViewModel

    init(viewModel: @autoclosure @escaping () -> SearchViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel())
    }

    var body: some View {
        NavigationStack {
            content
                .navigationTitle("Gapsi")
                .searchable(text: $viewModel.queryText)
                .searchSuggestions {
                    ForEach(viewModel.historySuggestions, id: \.self) { term in
                        Label(term, systemImage: "clock.arrow.circlepath")
                            .searchCompletion(term)
                    }
                }
                .onSubmit(of: .search) { viewModel.submit() }
        }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .idle where viewModel.history.isEmpty:
            StatusView(systemImage: "magnifyingglass", title: Text("Search for products"))
        case .idle:
            recentSearches
        case .loading:
            ProgressView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        case .results(let products):
            List(products) { product in
                ProductRow(product: product)
            }
            .listStyle(.plain)
            .scrollDismissesKeyboard(.immediately)
        case .empty:
            StatusView(
                systemImage: "magnifyingglass",
                title: Text("No results for \"\(viewModel.lastQuery?.value ?? "")\"")
            )
        case .failure(let error):
            StatusView(
                systemImage: "exclamationmark.triangle",
                title: Text("Something went wrong"),
                message: Text(error.message),
                actionTitle: Text("Try again"),
                action: viewModel.retry
            )
        }
    }

    private var recentSearches: some View {
        List {
            Section("Recent searches") {
                ForEach(viewModel.history, id: \.self) { term in
                    Button {
                        viewModel.search(historyTerm: term)
                    } label: {
                        Label(term, systemImage: "clock.arrow.circlepath")
                            .foregroundStyle(.primary)
                    }
                }
                .onDelete { offsets in
                    offsets.map { viewModel.history[$0] }.forEach(viewModel.removeHistoryTerm)
                }
            }
        }
        .scrollDismissesKeyboard(.immediately)
    }
}

#if DEBUG
#Preview("Idle") {
    SearchView(viewModel: PreviewData.searchViewModel(result: .success(ProductPage(products: [], rawCount: 0, reportedMaxPage: nil))))
}

#Preview("Recent searches") {
    SearchView(viewModel: PreviewData.searchViewModel(
        result: .success(ProductPage(products: [], rawCount: 0, reportedMaxPage: nil)),
        history: ["nintendo", "sony headphones", "laptop"]
    ))
}

#Preview("Results") {
    SearchView(viewModel: PreviewData.searchViewModel(
        result: .success(ProductPage(products: PreviewData.products, rawCount: 3, reportedMaxPage: 1)),
        submitting: "nintendo"
    ))
}

#Preview("Empty") {
    SearchView(viewModel: PreviewData.searchViewModel(
        result: .success(ProductPage(products: [], rawCount: 0, reportedMaxPage: nil)),
        submitting: "zzzz"
    ))
}

#Preview("Failure") {
    SearchView(viewModel: PreviewData.searchViewModel(result: .failure(.connectivity), submitting: "nintendo"))
}
#endif
