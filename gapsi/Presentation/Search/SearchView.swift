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

    init(viewModel: SearchViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        NavigationStack {
            content
                .navigationTitle("Gapsi")
                .searchable(text: $viewModel.queryText)
                .onSubmit(of: .search) { viewModel.submit() }
        }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .idle:
            StatusView(systemImage: "magnifyingglass", title: Text("Search for products"))
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
}

#if DEBUG
#Preview("Idle") {
    SearchView(viewModel: PreviewData.searchViewModel(result: .success(ProductPage(products: [], rawCount: 0, reportedMaxPage: nil))))
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
