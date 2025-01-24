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
    //if mealtime not tags:
    var mealtime: String?

    static var all = Filter(id: UUID(), name: "All plates", icon: "calendar")

    static let healthy = Filter(id: UUID(), name: "Healthy", icon: "star.fill", quality: 2)
    static let moderate = Filter(id: UUID(), name: "Moderate", icon: "star.fill", quality: 1)
    static let unhealthy = Filter(id: UUID(), name: "Unhealthy", icon: "star.fill", quality: 0)
    
    //if mealtime not tags:
    static let breakfast = Filter(id: UUID(), name: "Breakfast", icon: "clock", mealtime: "breakfast")
    static let morningSnack = Filter(id: UUID(), name: "Morning snack", icon: "clock", mealtime: "morningSnack")
    static let lunch = Filter(id: UUID(), name: "Lunch", icon: "clock", mealtime: "lunch")
    static let daySnack = Filter(id: UUID(), name: "Day snack", icon: "clock", mealtime: "daySnack")
    static let dinner = Filter(id: UUID(), name: "Dinner", icon: "clock", mealtime: "dinner")
    static let eveningSnack = Filter(id: UUID(), name: "Evening snack", icon: "clock", mealtime: "eveningSnack")
    static let anytimeMeal = Filter(id: UUID(), name: "Anytime meal", icon: "clock", mealtime: "anytimeMeal")
//    static let breakfast = Filter(id: UUID(), name: "Breakfast", icon: "clock", mealtime: .breakfast)
//    static let morningSnack = Filter(id: UUID(), name: "Morning snack", icon: "clock", mealtime: .morningSnack)
//    static let lunch = Filter(id: UUID(), name: "Lunch", icon: "clock", mealtime: .lunch)
//    static let daySnack = Filter(id: UUID(), name: "Day snack", icon: "clock", mealtime: .daySnack)
//    static let dinner = Filter(id: UUID(), name: "Dinner", icon: "clock", mealtime: .dinner)
//    static let eveningSnack = Filter(id: UUID(), name: "Evening snack", icon: "clock", mealtime: .eveningSnack)
//    static let anytimeMeal = Filter(id: UUID(), name: "Anytime meal", icon: "clock", mealtime: .anytimeMeal)

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
        //if mealtime not tags:
        if existingFilter.mealtime != nil {
            combinedFilter.mealtime = existingFilter.mealtime
        }
        
        return combinedFilter
    }
}
