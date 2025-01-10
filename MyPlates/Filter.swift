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
    //m
    var quality = -1
    
 
    
    static var all = Filter(id: UUID(), name: "All plates", icon: "calendar")
    static let today: Filter = {
        let calendar = Calendar.current
        let startOfToday = calendar.startOfDay(for: Date())
        return Filter(id: UUID(), name: "Today", icon: "1.square", minModificationDate: startOfToday)
    }()
    
    //m
    
    
    
    static let healthy = Filter(id: UUID(), name: "Healthy", icon: "star.fill", quality: 2)
    static let moderate = Filter(id: UUID(), name: "Moderate", icon: "star.fill", quality: 1)
    static let unhealthy = Filter(id: UUID(), name: "Unhealthy", icon: "star.fill", quality: 0)
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func ==(lhs: Filter, rhs: Filter) -> Bool {
        lhs.id == rhs.id
    }
}
