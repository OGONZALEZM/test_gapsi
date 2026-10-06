//
//  ProductRow.swift
//  gapsi
//
//  Created by Oscar Gonzalez on 6/10/26.
//

import Domain
import SwiftUI

struct ProductRow: View {
    let product: Product

    var body: some View {
        HStack(spacing: 12) {
            ProductThumbnail(url: product.thumbnailURL)

            VStack(alignment: .leading, spacing: 4) {
                Text(product.title)
                    .lineLimit(2)
                Text(product.price.formatted(.currency(code: product.currencyCode)))
                    .font(.headline)
            }
        }
        .accessibilityElement(children: .combine)
    }
}

#if DEBUG
#Preview {
    List {
        ForEach(PreviewData.products) { product in
            ProductRow(product: product)
        }
        ProductRow(product: PreviewData.brokenImageProduct)
    }
    .listStyle(.plain)
}
#endif
