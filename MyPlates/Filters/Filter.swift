//
//  Filter.swift
//  MyPlates
//
//  Created by Tatyana Buinitskaya on 20.12.2024.
//

import Foundation

/// A struct that represents a filter for plates, which can be used to categorize and filter plates based on attributes like quality, meal type, and date.
struct Filter: Identifiable, Hashable {
    /// The unique identifier for each filter, used to distinguish between different filters.
    var id: UUID
    /// The name of the filter (e.g., "Healthy", "Lunch"), helping users understand the category or type of filter applied.
    var name: String
    /// The icon associated with the filter, providing a visual cue about the filter's category.
    var icon: String
    /// An optional tag associated with the filter, used for further categorization or grouping of filters.
    var tag: Tag?
    /// The quality score of the filter, where -1 indicates no specific quality (default), 0 represents "Unhealthy", 1 represents "Moderate", and 2 represents "Healthy".
    var quality = -1
    /// The selected date for the filter, if any, used to filter plates based on a specific date.
    var selectedDate: Date?
    /// The mealtime associated with the filter (e.g., "Breakfast", "Lunch"), helping to categorize plates based on the time of day.
    var mealtime: String?
    /// A default filter representing all plates with no specific criteria, used when no filters are applied.
    static var all = Filter(id: UUID(), name: "All plates", icon: "calendar")
    /// A filter representing healthy plates (quality = 2), used when only healthy plates should be displayed.
    static let healthy = Filter(id: UUID(), name: "Healthy", icon: "star.fill", quality: 2)
    /// A filter representing moderately healthy plates (quality = 1), used when moderately healthy plates should be displayed.
    static let moderate = Filter(id: UUID(), name: "Moderate", icon: "star.fill", quality: 1)
    /// A filter representing unhealthy plates (quality = 0), used when only unhealthy plates should be displayed.
    static let unhealthy = Filter(id: UUID(), name: "Unhealthy", icon: "star.fill", quality: 0)
    /// A filter representing breakfast plates, used when only breakfast plates should be displayed.
    static let breakfast = Filter(id: UUID(), name: "Breakfast", icon: "clock", mealtime: "Breakfast")
    /// A filter representing morning snack plates, used when only morning snack plates should be displayed.
    static let morningSnack = Filter(id: UUID(), name: "Morning Snack", icon: "clock", mealtime: "Morning Snack")
    /// A filter representing lunch plates, used when only lunch plates should be displayed.
    static let lunch = Filter(id: UUID(), name: "Lunch", icon: "clock", mealtime: "Lunch")
    /// A filter representing day snack plates, used when only day snack plates should be displayed.
    static let daySnack = Filter(id: UUID(), name: "Day Snack", icon: "clock", mealtime: "Day Snack")
    /// A filter representing dinner plates, used when only dinner plates should be displayed.
    static let dinner = Filter(id: UUID(), name: "Dinner", icon: "clock", mealtime: "Dinner")
    /// A filter representing evening snack plates, used when only evening snack plates should be displayed.
    static let eveningSnack = Filter(id: UUID(), name: "Evening Snack", icon: "clock", mealtime: "Evening Snack")
    /// A filter representing anytime meal plates, used when plates can be consumed at any time.
    static let anytimeMeal = Filter(id: UUID(), name: "Anytime Meal", icon: "clock", mealtime: "Anytime Meal")
    
    /// Creates a filter for a specific date, useful for filtering plates based on a selected day.
    /// - Parameter date: The date for which the filter is applied.
    /// - Returns: A new `Filter` with the selected date.
    static func filterForDate(_ date: Date) -> Filter {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        return Filter(id: UUID(), name: "Selected Date", icon: "calendar", selectedDate: startOfDay)
    }

    /// Computes the hash value for the filter, required for usage in hash-based collections like `Set`.
    /// - Parameter hasher: The hasher used to compute the hash.
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    /// Compares two filters for equality. Filters are considered equal if they have the same unique identifier.
    /// - Parameters:
    ///   - lhs: The left-hand side filter.
    ///   - rhs: The right-hand side filter.
    /// - Returns: `true` if the filters are equal, `false` otherwise.
    static func == (lhs: Filter, rhs: Filter) -> Bool {
        lhs.id == rhs.id
    }
}

extension Filter {
    /// Applies the filters from an existing filter to the current filter, combining their attributes.
    /// This is useful for refining filters when users apply multiple criteria.
    /// - Parameter existingFilter: The filter whose properties should be applied to the current filter.
    /// - Returns: A new `Filter` that combines the current filter with the properties of the existing filter.
    func applyingFilters(from existingFilter: Filter) -> Filter {
        var combinedFilter = self
        // Combine the tag if it exists in the existing filter.
        if let tag = existingFilter.tag {
            combinedFilter.tag = tag
        }
        // Combine the quality if it is a valid value (not -1).
        if existingFilter.quality >= 0 {
            combinedFilter.quality = existingFilter.quality
        }
        // Combine the mealtime if it exists in the existing filter.
        if existingFilter.mealtime != nil {
            combinedFilter.mealtime = existingFilter.mealtime
        }
        return combinedFilter
    }
}
