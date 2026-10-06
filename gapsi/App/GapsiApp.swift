//
//  GapsiApp.swift
//  gapsi
//
//  Created by Oscar Gonzalez on 6/10/26.
//

import Foundation
import SwiftUI

@main
struct GapsiApp: App {
    private let container: Result<AppContainer, AppConfigurationError>

    init() {
        URLCache.shared = URLCache(memoryCapacity: 50 * 1024 * 1024, diskCapacity: 200 * 1024 * 1024)
        container = Result { () throws(AppConfigurationError) in try AppConfiguration() }
            .map(AppContainer.init)
    }

    var body: some Scene {
        WindowGroup {
            switch container {
            case .success(let container):
                SearchView(viewModel: container.makeSearchViewModel())
            case .failure(let error):
                ConfigurationErrorView(message: error.localizedDescription)
            }
        }
    }
}
