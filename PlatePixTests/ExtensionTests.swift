//
//  ExtensionTests.swift
//  PlatePixTests
//
//  Created by Tatyana Buinitskaya on 05.02.2025.
//

import CoreData
import XCTest
@testable import PlatePix

final class ExtensionTests: BaseTestCase {

    func testPlateTitleUnwrap() {
        // Given
        let plate = Plate(context: managedObjectContext)
        // When
        plate.title = "Example plate"
        // Then
        XCTAssertEqual(plate.plateTitle, "Example plate", "Changing title should also change plateTitle.")
        // When
        plate.plateTitle = "Updated plate"
        // Then
        XCTAssertEqual(plate.title, "Updated plate", "Changing plateTitle should also change title.")
    }

    func testPlatePhotoUnwrap() {
        // Given
        let plate = Plate(context: managedObjectContext)
        // When
        plate.photo = "Example photo path"
        // Then
        XCTAssertEqual(plate.platePhoto, "Example photo path", "Changing photo should also change platePhoto.")
        // When
        plate.platePhoto = "Updated photo path"
        // Then
        XCTAssertEqual(plate.photo, "Updated photo path", "Changing issueContent should also change content.")
    }

    func testPlateCreationDateUnwrap() {
        // Given
        let plate = Plate(context: managedObjectContext)
        let testDate = Date.now
        // When
        plate.creationDate = testDate
        // Then
        XCTAssertEqual(plate.plateCreationDate, testDate, "Changing creationDate should also change plateCreationDate.")
    }

    func testPlateTagsUnwrap() {
        // Given
        let tag = Tag(context: managedObjectContext)
        let plate = Plate(context: managedObjectContext)
        // Then
        XCTAssertEqual(plate.plateTags.count, 0, "A new plate should have no tags.")
        // When
        plate.addToTags(tag)
        // Then
        XCTAssertEqual(plate.plateTags.count, 1, "Adding 1 tag to a plate should result in plateTags having count 1.")
    }

    func testPlateTags() {
        // Given
        let tag = Tag(context: managedObjectContext)
        let plate = Plate(context: managedObjectContext)
        // When
        tag.name = "My Tag"
        plate.addToTags(tag)
        // Then
        XCTAssertEqual(
            plate.plateTags.first?.tagName,
            "My Tag",
            "Adding 1 tag to a plate should make plateTags first name be My Tag.")
    }

    func testPlateSortingIsStable() {
        // Given
        let plate1 = Plate(context: managedObjectContext)
        plate1.creationDate = .now

        let plate2 = Plate(context: managedObjectContext)
        plate2.creationDate = .now.addingTimeInterval(1)

        let plate3 = Plate(context: managedObjectContext)
        plate3.creationDate = .now.addingTimeInterval(100)

        let allPlates = [plate1, plate2, plate3]
        // When
        let sorted = allPlates.sorted()
        // Then
        XCTAssertEqual(
            [plate1, plate2, plate3],
            sorted,
            "Sorting plate arrays should use creation date.")
    }

    func testTagIDUnwrap() {
        // Given
        let tag = Tag(context: managedObjectContext)
        // When
        tag.id = UUID()
        // Then
        XCTAssertEqual(tag.tagID, tag.id, "Changing id should also change tagID.")
    }

    func testTagNameUnwrap() {
        // Given
        let tag = Tag(context: managedObjectContext)
        // When
        tag.name = "Example Tag"
        // Then
        XCTAssertEqual(tag.tagName, "Example Tag", "Changing name should also change tagName.")
    }

    func testTagSortingIsStable() {
        // Given
        let tag1 = Tag(context: managedObjectContext)
        tag1.name = "B Tag"
        tag1.id = UUID()

        let tag2 = Tag(context: managedObjectContext)
        tag2.name = "B Tag"
        tag2.id = UUID(uuidString: "FFFFFFFF-DC22-4463-8C69-7275D037C13D")

        let tag3 = Tag(context: managedObjectContext)
        tag3.name = "A Tag"
        tag3.id = UUID()

        let allTags = [tag1, tag2, tag3]
        // When
        let sortedTags = allTags.sorted()
        // Then
        XCTAssertEqual([tag3, tag1, tag2], sortedTags, "Sorting tag arrays should use name then UUID string.")
    }

    func testBundleDecodingAwards() {
        // Given
        let awards = Bundle.main.decode("Awards.json", as: [Award].self)
        // Then
        XCTAssertFalse(awards.isEmpty, "Awards.json should decode to a non-empty array.")
    }

    func testDecodingString() {
        // Given
        let bundle = Bundle(for: ExtensionTests.self)
        // When
        let data = bundle.decode("DecodableString.json", as: String.self)
        // Then
        XCTAssertEqual(data, "Never ask a starfish for directions.", "The string must match DecodableString.json.")
    }

    func testDecodingDictionary() {
        // Given
        let bundle = Bundle(for: ExtensionTests.self)
        // When
        let data = bundle.decode("DecodableDictionary.json", as: [String: Int].self)
        // Then
        XCTAssertEqual(data.count, 3, "There should be three items decoded from DecodableDictionary.json.")
        XCTAssertEqual(data["One"], 1, "The dictionary should contain the value 1 for the key One.")
    }
}
