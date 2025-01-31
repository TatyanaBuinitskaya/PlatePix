//
//  Plate-CoreDataHelpers.swift
//  MyPlates
//
//  Created by Tatyana Buinitskaya on 20.12.2024.
//

import Foundation
import SwiftUI

extension Plate {
    var platePhoto: String {
        get {photo ?? ""}
        set {photo = newValue}
    }
    var plateCreationDate: Date {
        creationDate ?? .now
    }
    var plateTitle: String {
        get {title ?? "" }
        set {title = newValue}
    }
    var plateNotes: String {
        get { notes ?? "" }
        set { notes = newValue}
    }
    var plateTags: [Tag] {
        let result = tags?.allObjects as? [Tag] ?? []
        return result.sorted()
    }
    var issueTagsList: String {
        guard let tags else { return "No tags" }

        if tags.count == 0 {
            return "No tags"
        } else {
            return plateTags.map(\.tagName).formatted()
        }
    }
    var plateMealtime: String {
        get {mealtime ?? "" }
        set {mealtime = newValue}
    }
    static var example: Plate {
        let controller = DataController(inMemory: true)
        let viewContext = controller.container.viewContext
        let plate = Plate(context: viewContext)
        plate.creationDate = .now
        plate.quality = 2
        plate.mealtime = "anytimeMeal"
        plate.title = "Plate " + Date().formatted()
        plate.notes = "plus cup of coffee with milk"
        plate.photo = Bundle.main.path(forResource: "example", ofType: "jpg")
        return plate
    }
}

extension Plate: Comparable {
    public static func < (lhs: Plate, rhs: Plate) -> Bool {
        return lhs.plateCreationDate < rhs.plateCreationDate
    }
}
