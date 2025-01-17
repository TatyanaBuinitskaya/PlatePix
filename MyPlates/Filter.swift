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
 //   var minModificationDate = Date.distantPast
    var tag: Tag?
    var quality = -1
    var selectedDate: Date?

    static var all = Filter(id: UUID(), name: "All plates", icon: "calendar")

    static let healthy = Filter(id: UUID(), name: "Healthy", icon: "star.fill", quality: 2)
    static let moderate = Filter(id: UUID(), name: "Moderate", icon: "star.fill", quality: 1)
    static let unhealthy = Filter(id: UUID(), name: "Unhealthy", icon: "star.fill", quality: 0)

    static func filterForDate(_ date: Date) -> Filter {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
//        if calendar.isDate(date, inSameDayAs: Date()) {
//            // If today is selected, return the "Today" filter and set the selectedDate to today
//            return Filter(id: UUID(), name: "Today", icon: "1.square", selectedDate: startOfDay)
    //    } else {
            // For other dates, return the "Selected Date" filter
            return Filter(id: UUID(), name: "Selected Date", icon: "calendar", selectedDate: startOfDay)
 //       }
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func ==(lhs: Filter, rhs: Filter) -> Bool {
        lhs.id == rhs.id
    }
}

extension Filter {
    // This method combines the current filter with a new date filter
    func applyingFilters(from existingFilter: Filter) -> Filter {
        var combinedFilter = self
        
        // Keep the tag and quality from the existing filter if they are set
        if let tag = existingFilter.tag {
            combinedFilter.tag = tag
        }
        
        if existingFilter.quality >= 0 {
            combinedFilter.quality = existingFilter.quality
        }
        
        return combinedFilter
    }
}
