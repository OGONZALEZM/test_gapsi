//
//  SearchResponseDTO.swift
//  gapsi
//
//  Created by Oscar Gonzalez on 6/10/26.
//

import Foundation

struct SearchResponseDTO: Decodable {
    let item: Item

    struct Item: Decodable {
        let props: Props
    }

    struct Props: Decodable {
        let pageProps: PageProps
    }

    struct PageProps: Decodable {
        let initialData: InitialData
    }

    struct InitialData: Decodable {
        let searchResult: SearchResult?
    }

    struct SearchResult: Decodable {
        let itemStacks: [ItemStack]?
        let paginationV2: Pagination?
    }

    struct Pagination: Decodable {
        let maxPage: Int?
    }

    struct ItemStack: Decodable {
        let layoutEnum: String?
        let items: [StackItem]?
    }

    struct StackItem: Decodable {
        let typename: String?
        let usItemId: String?
        let name: String?
        let price: Decimal?
        let image: String?
        let priceInfo: PriceInfo?

        enum CodingKeys: String, CodingKey {
            case typename = "__typename"
            case usItemId, name, price, image, priceInfo
        }
    }

    struct PriceInfo: Decodable {
        let priceDetails: PriceDetails?
    }

    struct PriceDetails: Decodable {
        let currency: String?
    }
}
