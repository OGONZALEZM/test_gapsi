//
//  SearchRequestBuilderTests.swift
//  gapsi
//
//  Created by Oscar Gonzalez on 6/10/26.
//

import Foundation
import Testing
@testable import DataLayer
@testable import Domain

struct SearchRequestBuilderTests {
    private let request = SearchRequestBuilder(apiKey: "test-key")
        .makeRequest(query: SearchQuery("nintendo switch")!, page: 3)

    @Test func buildsEscapedQuery() throws {
        let url = try #require(request.url)
        let components = try #require(URLComponents(url: url, resolvingAgainstBaseURL: false))

        #expect(url.absoluteString.hasPrefix(SearchRequestBuilder.baseURL + "?"))
        #expect(components.percentEncodedQuery?.contains("keyword=nintendo%20switch") == true)
        #expect(components.queryItems?.contains(URLQueryItem(name: "page", value: "3")) == true)
        #expect(components.queryItems?.contains(URLQueryItem(name: "sortBy", value: "best_match")) == true)
    }

    @Test func setsRapidAPIHeaders() {
        #expect(request.value(forHTTPHeaderField: "x-rapidapi-key") == "test-key")
        #expect(request.value(forHTTPHeaderField: "x-rapidapi-host") == "axesso-walmart-data-service.p.rapidapi.com")
        #expect(request.httpMethod == "GET")
    }
}
