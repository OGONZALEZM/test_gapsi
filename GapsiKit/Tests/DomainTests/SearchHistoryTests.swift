//
//  SearchHistoryTests.swift
//  gapsi
//
//  Created by Oscar Gonzalez on 6/10/26.
//

import Testing
@testable import Domain

struct SearchHistoryTests {
    @Test func recordInsertsMostRecentFirst() {
        var history = SearchHistory(terms: ["tv"])
        history.record(SearchQuery("laptop")!)
        #expect(history.terms == ["laptop", "tv"])
    }

    @Test func recordDeduplicatesCaseInsensitivelyKeepingNewSpelling() {
        var history = SearchHistory(terms: ["tv", "laptop"])
        history.record(SearchQuery("LapTop")!)
        #expect(history.terms == ["LapTop", "tv"])
    }

    @Test func recordRespectsLimit() {
        var history = SearchHistory(terms: ["b", "c"], limit: 2)
        history.record(SearchQuery("a")!)
        #expect(history.terms == ["a", "b"])
    }

    @Test func initTruncatesToLimit() {
        let history = SearchHistory(terms: ["a", "b", "c"], limit: 2)
        #expect(history.terms == ["a", "b"])
    }

    @Test func removeIsCaseInsensitive() {
        var history = SearchHistory(terms: ["tv", "Laptop"])
        history.remove("LAPTOP")
        #expect(history.terms == ["tv"])
    }
}
