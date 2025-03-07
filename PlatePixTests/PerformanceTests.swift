//
//  PerformanceTests.swift
//  PlatePixTests
//
//  Created by Tatyana Buinitskaya on 05.02.2025.
//

import XCTest
@testable import PlatePix

final class PerformanceTests: BaseTestCase {

    func testAwardCalculationPerformance() {
        // Create a significant amount of test data
        for _ in 1...100 {
            dataController.createSampleData()
        }

        // Simulate lots of awards to check
        let awards = Array(repeating: Award.allAwards, count: 25).joined()
        
        measure {
            _ = awards.filter(dataController.hasEarned)
        }
    }

}
