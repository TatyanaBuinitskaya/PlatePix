//
//  DevelopmentTests.swift
//  MyPlatesTests
//
//  Created by Tatyana Buinitskaya on 05.02.2025.
//

import CoreData
import XCTest
@testable import MyPlates

final class DevelopmentTests: BaseTestCase {

    func testSampleDataCreationWorks() {
        // When
        dataController.createSampleData()
        // Then
        XCTAssertEqual(dataController.count(for: Tag.fetchRequest()), 5, "There should be 5 sample tags.")
        XCTAssertEqual(dataController.count(for: Plate.fetchRequest()), 50, "There should be 50 sample plates.")
    }

    func testDeleteAllClearsEverything() {
        // Given
        dataController.createSampleData()
        // When
        dataController.deleteAll()
        // Then
        XCTAssertEqual(dataController.count(for: Tag.fetchRequest()), 0, "deleteAll() should leave 0 tags.")
        XCTAssertEqual(dataController.count(for: Plate.fetchRequest()), 0, "deleteAll() should leave 0 plates.")
    }

    func testExampleTagHasNoPlates() {
        // Given
        let tag = Tag.example
        // Then
        XCTAssertEqual(tag.plates?.count, 0, "The example tag should have 0 plates.")
    }

    func testExamplePlateQuality() {
        // Given
        let plate = Plate.example
        // Then
        XCTAssertEqual(plate.quality, 2, "The example plate should be healthy.")
    }
}
