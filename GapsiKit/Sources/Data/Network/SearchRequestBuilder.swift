//
//  SearchRequestBuilder.swift
//  gapsi
//
//  Created by Oscar Gonzalez on 6/10/26.
//

import Domain
import Foundation

struct SearchRequestBuilder: Sendable {
    static let host = "axesso-walmart-data-service.p.rapidapi.com"
    static let baseURL = "https://axesso-walmart-data-service.p.rapidapi.com/wlm/walmart-search-by-keyword"

    private let apiKey: String

    init(apiKey: String) {
        self.apiKey = apiKey
    }

    func makeRequest(query: SearchQuery, page: Int) -> URLRequest {
        guard var components = URLComponents(string: Self.baseURL) else {
            preconditionFailure("Invalid base URL: \(Self.baseURL)")
        }
        components.queryItems = [
            URLQueryItem(name: "keyword", value: query.value),
            URLQueryItem(name: "page", value: String(page)),
            URLQueryItem(name: "sortBy", value: "best_match"),
        ]
        guard let url = components.url else {
            preconditionFailure("Could not build search URL from \(components)")
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue(apiKey, forHTTPHeaderField: "x-rapidapi-key")
        request.setValue(Self.host, forHTTPHeaderField: "x-rapidapi-host")
        return request
    }
}
