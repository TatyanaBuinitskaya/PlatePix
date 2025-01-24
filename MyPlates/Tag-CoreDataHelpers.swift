//
//  Tag-CoreDataHelpers.swift
//  MyPlates
//
//  Created by Tatyana Buinitskaya on 20.12.2024.
//

import Foundation

extension Tag {
    var tagID: UUID {
        id ?? UUID()
    }
    
    var tagName: String {
        name ?? ""
    }
    
    var tagCreationDate: Date {
        creationDate ?? .now
    }
//    var tagTodayPlates: [Plate] {
//        let result = plates?.allObjects as? [Plate] ?? []
//        return result.filter {$0.creationDate == .now}
//      
//    }
    
    //many tags
    var tagActivePlates: [Plate] {
        let result = plates?.allObjects as? [Plate] ?? []
        return result.filter { $0.completed == false }
    }

    static var example: Tag {
        let controller = DataController(inMemory: true)
        let viewContext = controller.container.viewContext
        
        let tag = Tag(context: viewContext)
        tag.id = UUID()
        tag.name = "Example tag"
        tag.creationDate = .now
        return tag
    }
}

extension Tag: Comparable {
    public static func <(lhs: Tag, rhs: Tag) -> Bool {
        let left = lhs.tagName.localizedLowercase
        let right = rhs.tagName.localizedLowercase

        if left == right {
            return lhs.tagID.uuidString < rhs.tagID.uuidString
        } else {
            return left < right
        }
    }
}



