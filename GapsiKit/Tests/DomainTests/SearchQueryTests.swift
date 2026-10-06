//
//  SearchQueryTests.swift
//  gapsi
//
//  Created by Oscar Gonzalez on 6/10/26.
//

import Testing
@testable import Domain

struct SearchQueryTests {
    @Test func trimsWhitespaceAndNewlines() {
        #expect(SearchQuery("  laptop \n")?.value == "laptop")
    }

    @Test(arguments: ["", "   ", "\n\t "])
    func rejectsBlankInput(_ raw: String) {
        #expect(SearchQuery(raw) == nil)
    }
}
