//
//  Plate-CoreDataHelpers.swift
//  MyPlates
//
//  Created by Tatyana Buinitskaya on 20.12.2024.
//

import Foundation

extension Plate {

    var platePhoto: String {
        get {photo ?? ""}
        set {photo = newValue}
    }
    
    var plateCreationDate: Date {
        creationDate ?? .now
    }
    
    var plateModificationDate: Date {
        modificationDate ?? .now
    }
    
    var plateNotes: String {
           get { notes ?? "" }
           set { notes = newValue }
       }
    // is needed?
    var plateStatus: String {
        if completed {
            return "Completed"
        } else {
            return "Missed"
        }
    }
    
    var plateTags: [Tag] {
        let result = tags?.allObjects as? [Tag] ?? []
        return result.sorted()
    }
    var plateTagsList: String {
        guard let tags else { return "No tags" }

        if tags.count == 0 {
            return "No tags"
        } else {
            return plateTags.map(\.tagName).formatted()
        }
    }
    static var example: Plate {
        let controller = DataController(inMemory: true)
        let viewContext = controller.container.viewContext

        let plate = Plate(context: viewContext)
        plate.photo = "photo"
        plate.creationDate = .now
        plate.quality = 2
        plate.notes = "Example notes"
        plate.completed = false
        return plate
    }
}

extension Plate: Comparable {
    public static func <(lhs: Plate, rhs: Plate) -> Bool {
            return lhs.plateCreationDate < rhs.plateCreationDate
    }
}
