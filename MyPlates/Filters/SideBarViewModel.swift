//
//  SideBarViewModel.swift
//  MyPlates
//
//  Created by Tatyana Buinitskaya on 06.02.2025.
//

import CoreData
import Foundation
import SwiftUICore
import SwiftUI

/// An extension of `SideBarView` containing the `ViewModel` class,
/// responsible for handling filter-related logic and managing Core Data fetches.
extension SideBarView {
    /// A `ViewModel` class that conforms to `ObservableObject` and `NSFetchedResultsControllerDelegate`,
    /// allowing it to manage data changes and update the UI reactively.
    class ViewModel: NSObject, ObservableObject, NSFetchedResultsControllerDelegate {
        /// A reference to the `DataController`, which manages Core Data operations.
        var dataController: DataController
        /// An environment variable that manages the app's selected color.
        @EnvironmentObject var colorManager: AppColorManager
        /// The current color scheme of the app (light or dark mode).
        @Environment(\.colorScheme) var colorScheme

        /// A fetched results controller for managing `Tag` entities from Core Data.
        /// It fetches tags from the database and updates the UI when changes occur.
        private let tagsController: NSFetchedResultsController<Tag>
        /// A published array of `Tag` objects representing the available tag filters.
        /// When tags change in Core Data, this array is updated to reflect those changes.
        @Published var tags = [Tag]()
        /// A computed property that maps tags into `Filter` objects for easier processing.
        var tagFilters: [Filter] {
            tags.map { tag in
                Filter(
                    id: tag.tagID,
                    name: NSLocalizedString(tag.tagName, tableName: dataController.tableNameForTagType(tag.type), comment: ""),
                    icon: "tag",
                    tag: tag)
            }
        }
        /// Returns the total count of all plates stored in Core Data.
        var allPlatesCount: Int {
            let request: NSFetchRequest<Plate> = Plate.fetchRequest()
            let count = (try? dataController.container.viewContext.count(for: request)) ?? 0
            return count
        }

        /// Initializes the `ViewModel` and sets up the fetched results controller for `Tag` entities.
        /// - Parameter dataController: The `DataController` used for managing Core Data interactions.
        init(dataController: DataController) {
            self.dataController = dataController
            // Create a fetch request to retrieve tags, sorted alphabetically by name.
            let request = Tag.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(keyPath: \Tag.name, ascending: true)]
            // Initialize the fetched results controller with the Core Data context.
            tagsController = NSFetchedResultsController(
                fetchRequest: request,
                managedObjectContext: dataController.container.viewContext,
                sectionNameKeyPath: nil,
                cacheName: nil
            )
            super.init()
            // Assign self as the delegate to listen for Core Data changes.
            tagsController.delegate = self
            // Perform the initial fetch to load tags into the `tags` array.
            do {
                try tagsController.performFetch()
                tags = tagsController.fetchedObjects ?? []
            } catch {
                print("Failed to fetch tags")
            }
        }

        /// A delegate method from `NSFetchedResultsControllerDelegate`, called when the fetched objects change.
                /// This method updates the `tags` array whenever new `Tag` objects are added, deleted, or modified in Core Data.
                /// - Parameter controller: The `NSFetchedResultsController` that detected the changes.
        func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
            if let newTags = controller.fetchedObjects as? [Tag] {
                tags = newTags
            }
        }

        /// A function to generate tag filters by grouping them by type and creating viewable filters.
        func generateTagFilters(colorScheme: ColorScheme) -> [AnyView] {
            // Group the tag filters by their type.
            let groupedTags = Dictionary(grouping: tagFilters) { $0.tag?.type ?? "Other" }
            // Return sorted views for each tag type.
            return groupedTags.keys.sorted(by: dataController.sortTags).flatMap { type -> [AnyView] in
                var views: [AnyView] = []
                // Only show the section if the tag type exists in availableTagTypes
                if dataController.availableTagTypes.contains(type) {
                    // Header for each tag type
                    views.append(AnyView(dataController.tagHeaderView(for: type, colorScheme: colorScheme)))
                    // Show items if the tag type should be displayed
                    if dataController.shouldShowTags(for: type) {
                        views.append(contentsOf: tagFilterList(for: groupedTags[type, default: []]))
                    }
                }
                return views
            }
        }

        /// A function to generate the list of tag filters for a specific tag type.
        func tagFilterList(for filters: [Filter]) -> [AnyView] {
            filters.map { filter in
                AnyView(
                    NavigationLink(value: filter) {
                        Text(LocalizedStringKey(filter.name))
                            .fontWeight(.light)
                            .badge("\(countTagPlates(for: filter.name))")
                            .accessibilityLabel(filter.name)
                            .accessibilityHint("\(countTagPlates(for: filter.name)) plates")
                    }
                )
            }
        }

        /// Counts the number of plates with the given quality rating.
        /// - Parameter quality: The quality rating to filter plates by.
        /// - Returns: The number of plates with the specified quality rating.
        func countQualityPlates(for quality: Int) -> Int {
            let request: NSFetchRequest<Plate> = Plate.fetchRequest()
            request.predicate = NSPredicate(format: "quality = %d", quality)
            return (try? dataController.container.viewContext.count(for: request)) ?? 0
        }

        /// Counts the number of plates for a specific mealtime.
        /// - Parameter mealtime: The mealtime filter.
        /// - Returns: The number of plates associated with the given mealtime.
        func countMealtimePlates(for mealtime: String) -> Int {
            let request: NSFetchRequest<Plate> = Plate.fetchRequest()
            request.predicate = NSPredicate(format: "mealtime = %@", mealtime) // Use %@ for strings
            return (try? dataController.container.viewContext.count(for: request)) ?? 0
        }

        /// Counts the number of plates associated with a specific tag.
        /// - Parameter tagName: The name of the tag to filter plates by.
        /// - Returns: The number of plates with the specified tag.
        func countTagPlates(for tagName: String) -> Int {
            let request: NSFetchRequest<Plate> = Plate.fetchRequest()
            // Use the name of the tag for comparison
            request.predicate = NSPredicate(format: "ANY tags.name == %@", tagName)
            return (try? dataController.container.viewContext.count(for: request)) ?? 0
        }
    }
}
