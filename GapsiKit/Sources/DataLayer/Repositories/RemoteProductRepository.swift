//
//  RemoteProductRepository.swift
//  gapsi
//
//  Created by Oscar Gonzalez on 6/10/26.
//

import Domain
import Foundation

public struct RemoteProductRepository: ProductRepository {
    private let client: any HTTPClient
    private let requestBuilder: SearchRequestBuilder

    public init(apiKey: String, client: URLSessionHTTPClient = URLSessionHTTPClient()) {
        self.init(client: client, requestBuilder: SearchRequestBuilder(apiKey: apiKey))
    }

    init(client: any HTTPClient, requestBuilder: SearchRequestBuilder) {
        self.client = client
        self.requestBuilder = requestBuilder
    }

    public func search(_ query: SearchQuery, page: Int) async throws -> ProductPage {
        let request = requestBuilder.makeRequest(query: query, page: page)

        let data: Data
        let response: HTTPURLResponse
        do {
            (data, response) = try await client.data(for: request)
        } catch {
            throw Self.mapTransportError(error)
        }

        try Self.validate(response)

        do {
            let dto = try JSONDecoder().decode(SearchResponseDTO.self, from: data)
            return SearchResponseMapper.map(dto)
        } catch {
            throw ProductRepositoryError.invalidData
        }
    }

    private static func validate(_ response: HTTPURLResponse) throws {
        switch response.statusCode {
        case 200:
            return
        case 401, 403:
            throw ProductRepositoryError.unauthorized
        case 429:
            throw ProductRepositoryError.rateLimited
        case 500...599:
            throw ProductRepositoryError.server
        default:
            throw ProductRepositoryError.invalidData
        }
    }

    private static let connectivityCodes: Set<URLError.Code> = [
        .notConnectedToInternet,
        .networkConnectionLost,
        .timedOut,
        .cannotConnectToHost,
        .cannotFindHost,
        .dataNotAllowed,
    ]

    private static func mapTransportError(_ error: any Error) -> any Error {
        switch error {
        case is CancellationError:
            return CancellationError()
        case let urlError as URLError where urlError.code == .cancelled:
            return CancellationError()
        case let urlError as URLError where connectivityCodes.contains(urlError.code):
            return ProductRepositoryError.connectivity
        default:
            return ProductRepositoryError.invalidData
        }
    }
}
