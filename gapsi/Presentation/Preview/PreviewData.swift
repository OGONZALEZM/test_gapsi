#if DEBUG
import Domain
import Foundation

enum PreviewData {
    static let imageURL = URL(string: "https://i5.walmartimages.com/seo/Nintendo-Switch-2-System_e54b513c-cf10-44a5-8a78-14a5f70644a8.dca71e01a5172a18dbc2bc689f959469.jpeg?odnHeight=180&odnWidth=180&odnBg=FFFFFF")!
    static let brokenImageURL = URL(string: "https://invalid.example/missing.jpg")!

    static let products: [Product] = [
        Product(
            id: "15949610846",
            title: "Nintendo Switch™ 2 System",
            price: 499,
            currencyCode: "USD",
            thumbnailURL: imageURL
        ),
        Product(
            id: "17241550295",
            title: "Nintendo Classic Edition NES Mini Game Console",
            price: Decimal(string: "99.99")!,
            currencyCode: "USD",
            thumbnailURL: URL(string: "https://i5.walmartimages.com/seo/Nintendo-Classic-Edition-NES-Mini-Game-Console_8ab6ae80-58ed-418e-94bc-d6bb83efca80.6aa6d7ed7db538f2ee2cdb5b40929f59.jpeg?odnHeight=180&odnWidth=180&odnBg=FFFFFF")!
        ),
        Product(
            id: "384283330",
            title: "Nintendo - Entertainment System: SNES Classic Edition (2017 Limited Edition)",
            price: Decimal(string: "109.99")!,
            currencyCode: "USD",
            thumbnailURL: URL(string: "https://i5.walmartimages.com/seo/Nintendo-Entertainment-System-SNES-Classic-Edition-2017-Limited-Edition_27460289-6720-4668-b77c-7c11bfed1658_1.157dc365b0011dc85e3598f62b8a907f.jpeg")!
        ),
    ]

    static let brokenImageProduct = Product(
        id: "broken",
        title: "Product whose thumbnail fails to load",
        price: 10,
        currencyCode: "USD",
        thumbnailURL: brokenImageURL
    )

    @MainActor
    static func searchViewModel(
        result: Result<ProductPage, ProductRepositoryError>,
        submitting query: String? = nil
    ) -> SearchViewModel {
        let viewModel = SearchViewModel(
            searchUseCase: SearchProductsUseCase(repository: PreviewProductRepository(result: result)),
            historyUseCase: SearchHistoryUseCase(repository: PreviewSearchHistoryRepository())
        )
        if let query {
            viewModel.queryText = query
            viewModel.submit()
        }
        return viewModel
    }
}

private struct PreviewProductRepository: ProductRepository {
    let result: Result<ProductPage, ProductRepositoryError>

    func search(_ query: SearchQuery, page: Int) async throws -> ProductPage {
        try result.get()
    }
}

private struct PreviewSearchHistoryRepository: SearchHistoryRepository {
    func load() -> [String] { [] }
    func save(_ terms: [String]) {}
}
#endif
