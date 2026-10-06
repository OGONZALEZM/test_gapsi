//
//  FixtureLoader.swift
//  gapsi
//
//  Created by Oscar Gonzalez on 6/10/26.
//

import Testing
import Foundation

enum FixtureLoader {
    static func data(_ name: String) throws -> Data {
        let url = try #require(Bundle.module.url(forResource: name, withExtension: "json", subdirectory: "Fixtures"))
        return try Data(contentsOf: url)
    }
}
