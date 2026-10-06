//
//  RemoteProductRepositoryTests.swift
//  gapsi
//
//  Created by Oscar Gonzalez on 6/10/26.
//

import Foundation
import Testing
@testable import Data
@testable import Domain

struct RemoteProductRepositoryTests {
    private let query = SearchQuery("nintendo")!

    @Test func decodesSuccessfulResponse() async throws {
        let repository = makeRepository(.success(status: 200, data: try FixtureLoader.data("search_nintendo_p1")))

        let page = try await repository.search(query, page: 1)

        #expect(page.products.count == 41)
    }

    @Test func sendsBuiltRequest() async throws {
        let client = StubHTTPClient(.success(status: 200, data: try FixtureLoader.data("search_nintendo_p15")))
        let repository = RemoteProductRepository(client: client, requestBuilder: SearchRequestBuilder(apiKey: "k"))

        _ = try await repository.search(query, page: 2)

        let request = try #require(client.lastRequest)
        #expect(request.url?.query?.contains("page=2") == true)
        #expect(request.value(forHTTPHeaderField: "x-rapidapi-key") == "k")
    }

    @Test func undecodableSuccessIsInvalidData() async {
        let repository = makeRepository(.success(status: 200, data: Data("{}".utf8)))

        await #expect(throws: ProductRepositoryError.invalidData) {
            try await repository.search(query, page: 1)
        }
    }

    @Test(arguments: [
        (401, ProductRepositoryError.unauthorized),
        (403, .unauthorized),
        (429, .rateLimited),
        (500, .server),
        (503, .server),
        (599, .server),
        (204, .invalidData),
        (301, .invalidData),
        (404, .invalidData),
    ])
    func mapsStatusCodes(status: Int, expected: ProductRepositoryError) async {
        let repository = makeRepository(.success(status: status, data: Data()))

        await #expect(throws: expected) {
            try await repository.search(query, page: 1)
        }
    }

    @Test(arguments: [
        URLError.Code.notConnectedToInternet,
        .networkConnectionLost,
        .timedOut,
        .cannotConnectToHost,
        .cannotFindHost,
        .dataNotAllowed,
    ])
    func mapsConnectivityErrors(code: URLError.Code) async {
        let repository = makeRepository(.failure(URLError(code)))

        await #expect(throws: ProductRepositoryError.connectivity) {
            try await repository.search(query, page: 1)
        }
    }

    @Test func otherURLErrorIsInvalidData() async {
        let repository = makeRepository(.failure(URLError(.badServerResponse)))

        await #expect(throws: ProductRepositoryError.invalidData) {
            try await repository.search(query, page: 1)
        }
    }

    @Test func nonHTTPResponseIsInvalidData() async {
        let repository = makeRepository(.failure(HTTPClientError.nonHTTPResponse))

        await #expect(throws: ProductRepositoryError.invalidData) {
            try await repository.search(query, page: 1)
        }
    }

    @Test(arguments: [
        StubHTTPClient.Outcome.failure(CancellationError()),
        .failure(URLError(.cancelled)),
    ])
    func cancellationIsRethrownAsCancellationError(outcome: StubHTTPClient.Outcome) async {
        let repository = makeRepository(outcome)

        await #expect(throws: CancellationError.self) {
            try await repository.search(query, page: 1)
        }
    }

    private func makeRepository(_ outcome: StubHTTPClient.Outcome) -> RemoteProductRepository {
        RemoteProductRepository(client: StubHTTPClient(outcome), requestBuilder: SearchRequestBuilder(apiKey: "k"))
    }
}
