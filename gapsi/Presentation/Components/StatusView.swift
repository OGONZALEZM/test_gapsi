//
//  StatusView.swift
//  gapsi
//
//  Created by Oscar Gonzalez on 6/10/26.
//

import SwiftUI

struct StatusView: View {
    private let systemImage: String
    private let title: Text
    private let message: Text?
    private let actionTitle: Text?
    private let action: (@MainActor () -> Void)?

    init(
        systemImage: String,
        title: Text,
        message: Text? = nil,
        actionTitle: Text? = nil,
        action: (@MainActor () -> Void)? = nil
    ) {
        self.systemImage = systemImage
        self.title = title
        self.message = message
        self.actionTitle = actionTitle
        self.action = action
    }

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: systemImage)
                .font(.largeTitle)
                .foregroundStyle(.secondary)
                .accessibilityHidden(true)

            title
                .font(.headline)

            if let message {
                message
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            if let actionTitle, let action {
                Button(action: action) {
                    actionTitle
                }
                .buttonStyle(.bordered)
            }
        }
        .multilineTextAlignment(.center)
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#if DEBUG
#Preview("Message only") {
    StatusView(systemImage: "magnifyingglass", title: Text("Search for products"))
}

#Preview("With action") {
    StatusView(
        systemImage: "exclamationmark.triangle",
        title: Text("Something went wrong"),
        message: Text("No internet connection. Check your network and try again."),
        actionTitle: Text("Try again"),
        action: {}
    )
}
#endif
