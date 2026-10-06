//
//  SearchResponseMapper.swift
//  gapsi
//
//  Created by Oscar Gonzalez on 6/10/26.
//

import Domain
import Foundation

enum SearchResponseMapper {
    static let defaultCurrencyCode = "USD"

    static func map(_ dto: SearchResponseDTO) -> ProductPage {
        let searchResult = dto.item.props.pageProps.initialData.searchResult
        let gridProducts = (searchResult?.itemStacks ?? [])
            .filter { $0.layoutEnum == "GRID" }
            .flatMap { $0.items ?? [] }
            .filter { $0.typename == "Product" }

        return ProductPage(
            products: gridProducts.compactMap(product),
            rawCount: gridProducts.count,
            reportedMaxPage: searchResult?.paginationV2?.maxPage
        )
    }

    private static func product(from item: SearchResponseDTO.StackItem) -> Product? {
        guard
            let id = item.usItemId, !id.isEmpty,
            let name = item.name?.trimmingCharacters(in: .whitespacesAndNewlines), !name.isEmpty,
            let price = item.price,
            let thumbnailURL = item.image.flatMap(webURL)
        else {
            return nil
        }

        return Product(
            id: id,
            title: name,
            price: rounded(price),
            currencyCode: item.priceInfo?.priceDetails?.currency ?? defaultCurrencyCode,
            thumbnailURL: thumbnailURL
        )
    }

    private static func webURL(_ string: String) -> URL? {
        guard
            let url = URL(string: string),
            let scheme = url.scheme?.lowercased(), ["http", "https"].contains(scheme),
            url.host != nil
        else {
            return nil
        }
        return url
    }

    // JSONDecoder may route Decimal through Double on some OS versions, leaving binary noise (189.4 -> 189.40000000000001).
    private static func rounded(_ price: Decimal) -> Decimal {
        var value = price
        var result = Decimal()
        NSDecimalRound(&result, &value, 2, .plain)
        return result
    }
}
