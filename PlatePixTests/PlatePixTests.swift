//
//  PlatePixTests.swift
//  PlatePixTests
//
//  Created by Tatyana Buinitskaya on 04.02.2025.
//

import CoreData
import XCTest
@testable import PlatePix

class BaseTestCase: XCTestCase {

    var dataController: DataController!

    var managedObjectContext: NSManagedObjectContext!

    override func setUpWithError() throws {
        dataController = DataController(inMemory: true)
        managedObjectContext = dataController.container.viewContext
    }
}
