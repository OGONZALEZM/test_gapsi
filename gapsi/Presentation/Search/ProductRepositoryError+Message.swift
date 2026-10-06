//
//  ProductRepositoryError.swift
//  gapsi
//
//  Created by Oscar Gonzalez on 6/10/26.
//

import Domain
import Foundation

extension ProductRepositoryError {
    var message: String {
        switch self {
        case .connectivity:
            String(localized: "No internet connection. Check your network and try again.")
        case .unauthorized:
            String(localized: "The API key was rejected. Check Config/Secrets.xcconfig.")
        case .rateLimited:
            String(localized: "The API request limit was reached. Please try again later.")
        case .server:
            String(localized: "The service is unavailable right now. Please try again.")
        case .invalidData:
            String(localized: "We couldn't read the results. Please try again.")
        }
    }
}
