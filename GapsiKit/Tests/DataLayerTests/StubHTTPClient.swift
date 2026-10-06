//
//  StubHTTPClient.swift
//  gapsi
//
//  Created by Oscar Gonzalez on 6/10/26.
//

import Foundation
import os
@testable import DataLayer

final class StubHTTPClient: HTTPClient {
    enum Outcome: Sendable {
        case success(status: Int, data: Data)
        case failure(any Error)
    }

    private let outcome: Outcome
    private let requests = OSAllocatedUnfairLock<[URLRequest]>(initialState: [])

    init(_ outcome: Outcome) {
        self.outcome = outcome
    }

    var lastRequest: URLRequest? {
        requests.withLock { $0.last }
    }

    func data(for request: URLRequest) async throws -> (Data, HTTPURLResponse) {
        requests.withLock { $0.append(request) }
        switch outcome {
        case let .success(status, data):
            let response = HTTPURLResponse(url: request.url!, statusCode: status, httpVersion: nil, headerFields: nil)!
            return (data, response)
        case let .failure(error):
            throw error
        }
    }
}
