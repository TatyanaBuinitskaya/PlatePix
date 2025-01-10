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
    
    var plateModificationDate: Date {
        modificationDate ?? .now
    }
    var plateTitle: String {
        get {title ?? "" }
        set {title = newValue }
    }
    var plateNotes: String {
        get { notes ?? "" }
        set { notes = newValue }
    }
    // 1 tag
    var plateTag: Tag {
           get { tag ?? Tag.example }
           set { tag = newValue }
       }
    // 1 tag
    var plateTagList: String {
        guard let tag else { return "No tags" }
        return plateTag.tagName
    }
    
    static var example: Plate {
        let controller = DataController(inMemory: true)
        let viewContext = controller.container.viewContext
        let plate = Plate(context: viewContext)
        plate.creationDate = .now
        plate.quality = 2
        plate.title = "Plate " + Date().formatted()
        plate.notes = "plus cup of coffee with milk"
        plate.completed = false
        
        plate.photo = Bundle.main.path(forResource: "example", ofType: "jpg")

        return plate
        
    }
}

extension Plate: Comparable {
    public static func <(lhs: Plate, rhs: Plate) -> Bool {
            return lhs.plateCreationDate < rhs.plateCreationDate
    }
}
