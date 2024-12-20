//
//  Filter.swift
//  MyPlates
//
//  Created by Tatyana Buinitskaya on 20.12.2024.
//

import Foundation

struct Filter: Identifiable, Hashable {
    var id: UUID
    var name: String
    var icon: String
    var minModificationDate = Date.distantPast
    var tag: Tag?
    
    static var all = Filter(id: UUID(), name: "All plates", icon: "calendar.circle")
    static var today: Filter {
           let calendar = Calendar.current
           let startOfToday = calendar.startOfDay(for: Date())
           return Filter(id: UUID(), name: "Today", icon: "1.circle", minModificationDate: startOfToday)
       }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func ==(lhs: Filter, rhs: Filter) -> Bool {
        lhs.id == rhs.id
    }
}
