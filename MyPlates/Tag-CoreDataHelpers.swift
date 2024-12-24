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
    var tagTodayPlates: [Plate] {
        let result = plates?.allObjects as? [Plate] ?? []
        return result.filter {$0.creationDate == .now}
      
    }
//    var tagTodayPlates: [Plate] {
//        let result = plates?.allObjects as? [Plate] ?? []
//        let calendar = Calendar.current
//        let startOfToday = calendar.startOfDay(for: Date())
//        return result.filter { $0.creationDate >= startOfToday }
//    }
    
    static var example: Tag {
        let controller = DataController(inMemory: true)
        let viewContext = controller.container.viewContext
        
        let tag = Tag(context: viewContext)
        tag.id = UUID()
        tag.name = "Example Tag"
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


