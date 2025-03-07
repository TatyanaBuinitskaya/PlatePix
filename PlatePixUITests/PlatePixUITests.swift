//
//  PlatePixUITests.swift
//  PlatePixUITests
//
//  Created by Tatyana Buinitskaya on 05.02.2025.
//

import XCTest

final class PlatePixUITests: XCTestCase {
    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        // Set up the application for testing
        app = XCUIApplication()
        app.launchArguments = ["enable-testing"]
        app.launch()
    }

    @MainActor
    func testAppStartsWithNavigationBar() throws {
        XCTAssertTrue(app.navigationBars.element.exists, "There should be a navigation bar when the app launches.")
    }

    func testAppHasBasicButtonsOnLaunch() throws {
        XCTAssertTrue(app.navigationBars.buttons["Filters"].exists, "There should be a Filters button launch.")
    }

    func testNoPlatessAtStart() {
        XCTAssertEqual(app.cells.count, 0, "There should be no items initially.")
    }

    func testAllAwardsShowLockedAlert() {
        // Given
        app.buttons["Filters"].tap()
        app.buttons["Show awards"].tap()
        // When
        for award in app.scrollViews.buttons.allElementsBoundByIndex {
            award.tap()
            // Then
            XCTAssertTrue(app.alerts["Locked"].exists, "There should be a Locked alert showing for awards.")
            app.buttons["OK"].tap()
        }
    }
}
