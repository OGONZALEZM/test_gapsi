//
//  ConfigurationErrorView.swift
//  gapsi
//
//  Created by Oscar Gonzalez on 6/10/26.
//

import SwiftUI

struct ConfigurationErrorView: View {
    let message: String

    var body: some View {
        StatusView(
            systemImage: "key",
            title: Text("App not configured"),
            message: Text(message)
        )
    }
}

#if DEBUG
#Preview {
    ConfigurationErrorView(message: AppConfigurationError.missingRapidAPIKey.localizedDescription)
}
#endif
