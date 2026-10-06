//
//  ProductThumbnail.swift
//  gapsi
//
//  Created by Oscar Gonzalez on 6/10/26.
//

import SwiftUI

struct ProductThumbnail: View {
    let url: URL
    var size: CGFloat = 64

    var body: some View {
        AsyncImage(url: url) { phase in
            switch phase {
            case .success(let image):
                image
                    .resizable()
                    .scaledToFit()
            case .failure:
                Image(systemName: "photo")
                    .foregroundStyle(.secondary)
            case .empty:
                ProgressView()
            @unknown default:
                Color.clear
            }
        }
        .frame(width: size, height: size)
        .accessibilityHidden(true)
    }
}

#if DEBUG
#Preview {
    HStack(spacing: 24) {
        ProductThumbnail(url: PreviewData.imageURL)
        ProductThumbnail(url: PreviewData.brokenImageURL)
        ProductThumbnail(url: PreviewData.imageURL, size: 120)
    }
    .padding()
}
#endif
