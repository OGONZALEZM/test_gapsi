//
//  AppContainer.swift
//  gapsi
//
//  Created by Oscar Gonzalez on 6/10/26.
//

import DataLayer
import Domain
import Foundation

struct AppContainer {
    private let searchProductsUseCase: SearchProductsUseCase
    private let searchHistoryUseCase: SearchHistoryUseCase

    init(configuration: AppConfiguration) {
        let productRepository = RemoteProductRepository(
            apiKey: configuration.rapidAPIKey,
            client: URLSessionHTTPClient(session: Self.makeAPISession())
        )
        searchProductsUseCase = SearchProductsUseCase(repository: productRepository)
        searchHistoryUseCase = SearchHistoryUseCase(repository: UserDefaultsSearchHistoryRepository())
    }

    @MainActor
    func makeSearchViewModel() -> SearchViewModel {
        SearchViewModel(searchUseCase: searchProductsUseCase, historyUseCase: searchHistoryUseCase)
    }

    // URLCache.shared is reserved for thumbnails; search results must always be fresh.
    private static func makeAPISession() -> URLSession {
        let configuration = URLSessionConfiguration.default
        configuration.urlCache = nil
        configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
        configuration.timeoutIntervalForRequest = 20
        return URLSession(configuration: configuration)
    }
}
