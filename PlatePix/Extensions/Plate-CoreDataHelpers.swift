//
//  Plate-CoreDataHelpers.swift
//  PlatePix
//
//  Created by Tatyana Buinitskaya on 20.12.2024.
//

import Foundation
import SwiftUI

/// An extension to the `Plate` model that provides computed properties for management of plate-related data.
extension Plate {
    /// The photo path associated with the plate. Returns an empty string if no photo is available.
    var platePhoto: String {
        get {photo ?? ""}
        set {photo = newValue}
    }
    /// The creation date of the plate. Defaults to the current date if not set.
    var plateCreationDate: Date {
        creationDate ?? .now
    }
    /// The title of the plate. Returns an empty string if no title is provided.
    var plateTitle: String {
        get {title ?? "" }
        set {title = newValue}
    }
    /// The notes related to the plate. Returns an empty string if no notes are available.
    var plateNotes: String {
        get { notes ?? "" }
        set { notes = newValue}
    }
    /// The list of tags associated with the plate, sorted alphabetically.
    var plateTags: [Tag] {
        let result = tags?.allObjects as? [Tag] ?? []
        return result.sorted()
    }
    /// The mealtime associated with the plate. Returns an empty string if not set.
    var plateMealtime: String {
        get {mealtime ?? "" }
        set {mealtime = newValue}
    }
    /// A sample `Plate` object used for previewing or testing purposes.
    ///
    /// This example plate is configured with sample data, including a creation date,
    /// quality rating, mealtime, title, notes, and a sample photo.
    static var example: Plate {
        let controller = DataController(inMemory: true)
        let viewContext = controller.container.viewContext
        let plate = Plate(context: viewContext)
        plate.creationDate = .now
        plate.quality = 2
        plate.mealtime = "Anytime Meal"
        plate.title = "Plate " + Date().formatted()
        plate.notes = "plus cup of coffee with milk"
        plate.photo = Bundle.main.path(forResource: "example", ofType: "jpg")
        return plate
    }
}

/// Allows plates to be compared based on their creation dates.
extension Plate: Comparable {
    /// Compares two `Plate` instances based on their creation dates.
    ///
    /// Plates with earlier creation dates are considered "less than" those with later dates.
    /// This is useful for sorting plates chronologically.
    public static func < (lhs: Plate, rhs: Plate) -> Bool {
        return lhs.plateCreationDate < rhs.plateCreationDate
    }
}
