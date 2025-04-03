//
//  TagTests.swift
//  PlatePixTests
//
//  Created by Tatyana Buinitskaya on 04.02.2025.
//

import CoreData
import XCTest
@testable import PlatePix

final class TagTests: BaseTestCase {

    func testCreatingTagsAndPlates() {
        let count = 10
        let plateCount = count * count
        // Create `count` number of tags, each associated with `count` number of plates.
        for _ in 0..<count {
            let tag = Tag(context: managedObjectContext)

            for _ in 0..<count {
                let plate = Plate(context: managedObjectContext)
                tag.addToPlates(plate)
            }
        }
        // Verify that the number of tags and plates matches the expected counts.
        XCTAssertEqual(dataController.count(for: Tag.fetchRequest()), count, "Expected \(count) tags.")
        XCTAssertEqual(dataController.count(for: Plate.fetchRequest()), plateCount, "Expected \(plateCount) plates.")
    }

    func testDeletingTagDoesNotDeletePlates() throws {
        // Create sample data to work with.
        dataController.createSampleData()
        // Fetch all tags from the data store.
        let request = NSFetchRequest<Tag>(entityName: "Tag")
        let tags = try managedObjectContext.fetch(request)
        // Delete the first tag from the fetched list.
        dataController.delete(tags[0])
        // Verify that exactly one tag has been deleted.
        XCTAssertEqual(dataController.count(for: Tag.fetchRequest()), 4, "Expected 4 tags after deleting 1.")
        // Verify that no plates have been deleted despite the tag deletion.
        XCTAssertEqual(dataController.count(for: Plate.fetchRequest()), 50, "Expected 50 plates after deleting a tag.")
    }
}
