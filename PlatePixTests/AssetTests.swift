//
//  AssetTests.swift
//  PlatePixTests
//
//  Created by Tatyana Buinitskaya on 04.02.2025.
//

import XCTest
@testable import PlatePix

class AssetTests: XCTestCase {

    func testColorsExist() {
        // The list of expected color names in the asset catalog.
        let allColors = ["A Dark Blue", "A Dark Gray", "A Gold", "A Gray", "A Green",
                         "A Light Blue", "A Midnight", "A Orange", "A Pink", "A Purple", "A Red", "A Teal"]
        // Verify that each color can be successfully loaded from the asset catalog.
        for color in allColors {
            XCTAssertNotNil(UIColor(named: color), "Failed to load color '\(color)' from asset catalog.")
        }
    }

    func testAwardsLoadCorrectly() {
        // Assert that the awards array is not empty, indicating successful loading from JSON.
        XCTAssertTrue(Award.allAwards.isEmpty == false, "Failed to load awards from JSON.")
    }
}
