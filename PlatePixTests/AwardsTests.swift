//
//  AwardsTests.swift
//  PlatePixTests
//
//  Created by Tatyana Buinitskaya on 04.02.2025.
//

import CoreData
import XCTest
@testable import PlatePix

final class AwardsTests: BaseTestCase {
    let awards = Award.allAwards

    func testAwardIDMatchesName() {
        for award in awards {
            XCTAssertEqual(award.id, award.name, "Award ID should always match its name.")
        }
    }

    func testNewUserHasUnlockedNoAwards() {
        for award in awards {
            XCTAssertFalse(dataController.hasEarned(award: award), "New users should have no earned awards")
        }
    }

    func testCreatingPlatesUnlocksAwards() {
        let values = [10, 25, 50, 100, 500, 1000, 5000, 10000] // The milestone values for unlocking awards.

        for (count, value) in values.enumerated() {
            var plates = [Plate]() // The list to hold created plates.
            // Create the specified number of plates to simulate user activity.
            for _ in 0..<value {
                let plate = Plate(context: managedObjectContext)
                plates.append(plate)
            }
            // Filter awards to find those that meet the plate-related criteria.
            let matches = awards.filter { award in
                award.criterion == "plates" && dataController.hasEarned(award: award)
            }
            // Assert that the expected number of awards are unlocked.
            XCTAssertEqual(matches.count, count + 1, "Adding \(value) plates should unlock \(count + 1) awards.")
            // Clean up data to ensure each iteration starts fresh.
            dataController.deleteAll()
        }
    }
}
