//
//  DataController.swift
//  PlatePix
//
//  Created by Tatyana Buinitskaya on 19.12.2024.
//
import CloudKit
import CoreData
import StoreKit
import SwiftUI
import UIKit
import WidgetKit
import RevenueCat

/// An environment singleton responsible for managing the Core Data stack, handling data persistence,
/// fetch requests, filter management, and tracking user awards within the app.
class DataController: ObservableObject {
    /// The CloudKit container used to store all Core Data entities in the app.
    let container: NSPersistentCloudKitContainer
    /// Delegate for handling Core Data and Spotlight search integration.
    var spotlightDelegate: NSCoreDataCoreSpotlightDelegate?
    /// An environment variable that manages the app's selected color.
    @EnvironmentObject var colorManager: AppColorManager
    @Environment(\.colorScheme) var colorScheme
    /// The currently selected filter for viewing plates, initialized with today's date.
    @Published var selectedFilter: Filter? = Filter.filterForDate(Date())
    /// The currently selected plate, if any, for detailed viewing or editing.
    @Published var selectedPlate: Plate?
    /// The text used to filter plates based on user input.
    @Published var filterText = ""
    /// The quality filter applied to plates. A value of -1 indicates no filter is applied.
    @Published var filterQuality = -1
    /// The selected mealtime filter for categorizing plates.
    @Published var filterMealtime: String?
    /// A Boolean value indicating whether the plates are sorted from newest to oldest.
    @Published var sortNewestFirst = true
    /// The currently selected image, typically for display or upload.
    @Published var selectedImage: UIImage?
//    /// A flag indicating whether the congratulations screen should be shown.
//    @Published var showCongratulations: Bool = false
    /// The award currently being tracked or displayed.
    @Published var currentAward: Award = .example
    /// The date selected for filtering plates, initialized with the current date.
    @Published var selectedDate: Date? = Date()
    /// A dictionary to manage the visibility of tag type filters by their names.
    @Published var showTagTypeFilters: [String: Bool] = [:]
    /// A flag indicating if a new tag has been created.
    @Published var hasNewTag = false
    /// The list of available tag types. Updates are persisted using UserDefaults.
    @Published var availableTagTypes: [String] = [] {
    didSet {
        UserDefaults.standard.set(availableTagTypes, forKey: "availableTagTypes")
    }
}
    /// A variable that tracks whether a new plate is created.
    @Published var isNewPlateCreated = false
    /// A Boolean value indicating whether reminders are enabled.
    @Published var reminderEnabled = false
    /// Stores the selected time for daily reminders.
    @Published var reminderTime = Date()
    /// The UserDefaults suite where we're saving user data.
    let defaults: UserDefaults
    /// The StoreKit products we've loaded for the store.
    @Published var products = [Product]()
    
    //    /// A unique identifier for the "New Plate" user activity, used for deep linking and shortcuts.
    //    private let newPlateActivity = "com.TatianaBuinitskaia.PlatePix.newPlate"
    @Published var isSubscriptionIsActive = false


    /// Array of predefined meal times for filtering plates and UI selection, to be localized.
    let mealtimeArray: [String] = [
        "Breakfast",
        "Morning Snack",
        "Lunch",
        "Day Snack",
        "Dinner",
        "Evening Snack",
        "Anytime Meal"
    ]
    
    /// A background task that monitors in-app purchase transactions.
    /// This ensures that the app properly handles previous purchases and unlocks premium features when needed.
    private var storeTask: Task<Void, Never>?
    /// A background task responsible for saving changes to Core Data asynchronously.
    private var saveTask: Task<Void, Error>?
    /// A static preview instance of DataController for SwiftUI previews and testing.
    static var preview: DataController = {
        let dataController = DataController(inMemory: true)
        return dataController
    }()
  
    
    /// Dynamically generates the title based on the selected filters such as date, quality, mealtime, and tags.
    var dynamicTitle: String {
        // If there's a selected date, we start with the date first
        if let selectedDate = selectedDate {
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            dateFormatter.timeStyle = .none
            var title = dateFormatter.string(from: selectedDate) // Date of selected date
            // If there's a quality filter, add it after the date
            if let filter = selectedFilter, filter.quality >= 0 {
                if filter.quality == 0 {
                    title += NSLocalizedString(" Unhealthy", comment: "Quality")
                } else if filter.quality == 1 {
                    title += NSLocalizedString(" Moderate", comment: "Quality")
                } else if filter.quality == 2 {
                    title += NSLocalizedString(" Healthy", comment: "Quality")
                }
            }
            if let filter = selectedFilter, let mealtime = filter.mealtime {
                let mealtimeTitle = NSLocalizedString(mealtime, comment: "Mealtime")
                    title += " \(mealtimeTitle)"
            }
            if let tag = selectedFilter?.tag {
                title += " \(tag.name ?? NSLocalizedString("Filtered Plates", comment: ""))"
            }
            return title
        }
        // If it's today's filter, return today's date
        if selectedFilter == Filter.filterForDate(Date()) {
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            dateFormatter.timeStyle = .none
            return dateFormatter.string(from: Date()) // Today's date
        }
        // If no date is selected and there is a tag filter selected, show the tag name
        if let tag = selectedFilter?.tag {
            return tag.name ?? NSLocalizedString("Filtered Plates", comment: "Fallback tag name")
        }
        // If no date is selected and there is a quality filter selected (even with "All" plates), show quality
        if let filter = selectedFilter, filter.quality >= 0 {
            if filter.quality == 0 {
                return NSLocalizedString("Unhealthy", comment: "Quality")
            } else if filter.quality == 1 {
                return NSLocalizedString("Moderate", comment: "Quality")
            } else if filter.quality == 2 {
                return NSLocalizedString("Healthy", comment: "Quality")
            }
        }
        if let filter = selectedFilter {
            if let mealtime = filter.mealtime {
                return NSLocalizedString(mealtime, comment: "Mealtime")
            }
        }
        // If no filter is selected, return "All Plates" or fallback to default
        return NSLocalizedString("All Plates", comment: "")
    }
   
    /// Manages the awards that have been congratulated, persisting the data using UserDefaults.
    var congratulatedAwards: [Award] {
        get {
            guard let data = UserDefaults.standard.data(forKey: "congratulatedAwards") else { return [] }
            let decoder = JSONDecoder()
            return (try? decoder.decode([Award].self, from: data)) ?? []
        }
        set {
            let encoder = JSONEncoder()
            if let data = try? encoder.encode(newValue) {
                UserDefaults.standard.set(data, forKey: "congratulatedAwards")
            }
        }
    }

    /// A static property that initializes and provides the Core Data managed object model.
    ///
    /// This model is essential for defining the structure of the app's persistent data, including
    /// entities, attributes, and relationships. It is loaded from the compiled `.momd` file
    /// located in the app bundle.
    static let model: NSManagedObjectModel = {
        // Attempt to locate the compiled Core Data model file named "Main.momd" in the app bundle.
        guard let url = Bundle.main.url(forResource: "Main", withExtension: "momd") else {
            // If the model file cannot be found, terminate the app with an error message.
            // This ensures the app does not continue running in an inconsistent state.
            fatalError("Failed to locate model file.")
        }
        // Attempt to load the managed object model from the located file URL.
        guard let managedObjectModel = NSManagedObjectModel(contentsOf: url) else {
            // If loading the model fails, terminate the app to prevent issues with data handling.
            fatalError("Failed to load model file.")
        }
        // Return the successfully loaded managed object model to be used throughout the app.
        return managedObjectModel
    }()

    /// Initializes a data controller, either in memory (for temporary use such as testing and previewing),
    /// or on permanent storage (for use in regular app runs.)
    ///
    /// Defaults to permanent storage.
    /// - Parameter inMemory: Whether to store this data in temporary memory or not.
    /// - Parameter defaults: The UserDefaults suite where user data should be stored
    init(inMemory: Bool = false, defaults: UserDefaults = .standard) {
      
        // Assigns the provided `UserDefaults` instance (or `.standard` if none is provided).
        self.defaults = defaults

        self.availableTagTypes = UserDefaults.standard.stringArray(forKey: "availableTagTypes") ?? []
   //     container = NSPersistentCloudKitContainer(name: "Main")
        container = NSPersistentCloudKitContainer(name: "Main", managedObjectModel: Self.model)
        
        // Starts a background task to monitor App Store transactions.
//        storeTask = Task {
//            await monitorTransactions()
//        }

        // For testing and previewing purposes, we create a
        // temporary, in-memory database by writing to /dev/null
        // so our data is destroyed after the app finishes running.
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(filePath: "/dev/null")
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        // Make sure that we watch iCloud for all changes to make
        // absolutely sure we keep our local UI in sync when a
        // remote change happens.
        container.persistentStoreDescriptions.first?.setOption(
            true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey
        )
        NotificationCenter.default.addObserver(
            forName: .NSPersistentStoreRemoteChange,
            object: container.persistentStoreCoordinator,
            queue: .main,
            using: remoteStoreChanged
        )
        container.loadPersistentStores { [weak self] _, error in
            if let error {
                fatalError("Fatal error loading store: \(error.localizedDescription)")
            }
            if let description = self?.container.persistentStoreDescriptions.first {
                description.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
            
            if let coordinator = self?.container.persistentStoreCoordinator {
                self?.spotlightDelegate = NSCoreDataCoreSpotlightDelegate(
                    forStoreWith: description,
                    coordinator: coordinator
                )
                
                self?.spotlightDelegate?.startSpotlightIndexing()            }
        }

            #if DEBUG
            if CommandLine.arguments.contains("enable-testing") {
                self?.deleteAll()
            }
            UIView.setAnimationsEnabled(false)
            #endif
        }
        Purchases.shared.getCustomerInfo {(customerInfo, error) in
                self.isSubscriptionIsActive = customerInfo?.entitlements.all["premium"]?.isActive == true
            }
    }
  
    /// Runs a fetch request with various predicates that filter the user's plates based
    /// on tags, mealtime, quality, title and notes.
    /// - Returns: An array of all matching plates.
    
    func platesForSelectedFilter() -> [Plate] {
        let filter = selectedFilter ?? .all
        var predicates = [NSPredicate]()

        // Apply date filter if a selected date exists
        if let selectedDate = filter.selectedDate ?? selectedDate {
            let startOfDay = Calendar.current.startOfDay(for: selectedDate)
            if let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay) {
                predicates.append(NSPredicate(
                    format: "creationDate >= %@ AND creationDate < %@",
                    startOfDay as NSDate,
                    endOfDay as NSDate))
            }
        }
        
        // Apply tag filter
        if let tag = filter.tag {
            let tagPredicate = NSPredicate(format: "tags CONTAINS %@", tag)
            predicates.append(tagPredicate)
        }
        
        // Apply quality filter if selected
        if filter.quality >= 0 {
            predicates.append(NSPredicate(format: "quality = %d", filter.quality))
        }
        
        // Apply mealtime filter if selected
        if let mealtime = filter.mealtime {
            predicates.append(NSPredicate(format: "mealtime = %@", mealtime))
        }
        
        // Apply filter text if it exists
        let trimmedFilterText = filterText.trimmingCharacters(in: .whitespaces)
        if !trimmedFilterText.isEmpty {
            let titlePredicate = NSPredicate(format: "title CONTAINS[c] %@", trimmedFilterText)
            let notesPredicate = NSPredicate(format: "notes CONTAINS[c] %@", trimmedFilterText)
            let textSearchPredicate = NSCompoundPredicate(orPredicateWithSubpredicates: [titlePredicate, notesPredicate])
            predicates.append(textSearchPredicate)
        }

        let fetchRequest: NSFetchRequest<Plate> = Plate.fetchRequest()

        // If the filter is "All", only apply the search filter (if any)
        if filter == .all {
            fetchRequest.predicate = predicates.isEmpty ? nil : NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        } else {
            fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        }

        // Sorting plates by creationDate
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: sortNewestFirst)]
        
        return (try? container.viewContext.fetch(fetchRequest)) ?? []
    }

    /// Creates a new plate and initializes its properties with default values or values from the current selection.
        /// - Note: The creation date is set to the selected date (or today's date if no date is selected). The quality and mealtime are set to default values.
    func newPlate() -> Bool {
//        var shouldCreate = fullVersionUnlocked
        var shouldCreate = isSubscriptionIsActive
           if shouldCreate == false {
               // check how many plates we currently have
               shouldCreate = count(for: Plate.fetchRequest()) < 35 // 35
           }
           guard shouldCreate else {
               return false
           }
        
        let plate = Plate(context: container.viewContext)
        
        // Get the current count of plates to use as part of the name
        var plateCount = count(for: Plate.fetchRequest())

        var plateTitle: String

            repeat {
                // Generate a new title with the current count
                plateTitle = String(format: NSLocalizedString("Plate - %d", comment: "Title with plate number"), plateCount)
                plateCount += 1
            } while plateExists(with: plateTitle)  // Keep incrementing until we find a unique name

            plate.title = plateTitle
   
        if let selectedDate = selectedDate {
               // Set the creation date to the selected date, but keep the time as midnight
               let calendar = Calendar.current
               let newDate = calendar.startOfDay(for: selectedDate) // This sets time to midnight
               plate.creationDate = newDate
           } else {
               // If no date is selected, default to today's date and time
               plate.creationDate = .now
           }
        plate.quality = 1
        // Set the mealtime attribute from the selected filter, defaulting to "breakfast" if no mealtime is selected
        plate.mealtime = "Anytime Meal"
        plate.photo = nil
        selectedPlate = plate
        save()
        return true
    }
    
    /// Check if a plate with the same title already exists
    private func plateExists(with title: String) -> Bool {
        let fetchRequest: NSFetchRequest<Plate> = Plate.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "title == %@", title)
        
        do {
            let count = try container.viewContext.count(for: fetchRequest)
            return count > 0
        } catch {
            print("Error checking for existing plate: \(error)")
            return false
        }
    }
    
    /// Creates a new tag with default values and saves it to the context.
        /// - Note: New tags are added to the available tag types if they do not already exist.
    func newTag() {
        let tag = Tag(context: container.viewContext)
        tag.id = UUID()
        tag.name = " New Tag"
        tag.creationDate = Date()
        tag.type = "My"
        if !availableTagTypes.contains(tag.type ?? "My") {
            availableTagTypes.append(tag.type ?? "My")
            }
        save()
        // Add new tag logic
           hasNewTag = true  // Ensure "User" tags are initially shown
           showTagTypeFilters["My"] = true
    }
    
    /// Counts the number of plates created on a specific date.
        /// - Parameter date: The date to filter plates by.
        /// - Returns: The number of plates created on the given date.
    func countSelectedDatePlates(for date: Date) -> Int {
        let request: NSFetchRequest<Plate> = Plate.fetchRequest()
        // Get the start and end of the given day
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .second, value: 86399, to: startOfDay) ?? startOfDay
        // Use a range for comparison
        request.predicate = NSPredicate(
            format: "creationDate >= %@ AND creationDate <= %@",
            startOfDay as NSDate,
            endOfDay as NSDate)
        return (try? container.viewContext.count(for: request)) ?? 0
    }


    /// Called when remote store changes. It triggers a change in the view model.
    func remoteStoreChanged(_ notification: Notification) {
        objectWillChange.send()
    }

    /// Saves our Core Data context iff there are changes. This silently ignores
    /// any errors caused by saving, but this should be fine because all our attributes are optional.
    func save() {
        saveTask?.cancel()
        if container.viewContext.hasChanges {
            try? container.viewContext.save()
        }
    }

    /// Schedules a save of the Core Data context after a delay of 3 seconds to batch changes.
    func queueSave() {
        saveTask?.cancel()
        saveTask = Task { @MainActor in
            try await Task.sleep(for: .seconds(3))
            save()
        }
    }

    /// Deletes a specified object from Core Data and saves the context after deletion.
        ///
        /// - Parameter object: The NSManagedObject to be deleted.
    func delete(_ object: NSManagedObject) {
        objectWillChange.send()
        container.viewContext.delete(object)
        save()
    }

    /// Performs a batch delete of the objects returned by the fetch request.
        ///
        /// - Parameter fetchRequest: The NSFetchRequest for the objects to be deleted.
    private func delete(_ fetchRequest: NSFetchRequest<NSFetchRequestResult>) {
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        batchDeleteRequest.resultType = .resultTypeObjectIDs
        // When performing a batch delete we need to make sure we read the result back
        // then merge all the changes from that result back into our live view context
        // so that the two stay in sync.
        if let delete = try? container.viewContext.execute(batchDeleteRequest) as? NSBatchDeleteResult {
            let changes = [NSDeletedObjectsKey: delete.result as? [NSManagedObjectID] ?? []]
            NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes, into: [container.viewContext])
        }
    }

    /// Deletes all objects of type Tag and Plate, then saves the context.
    func deleteAll() {
        let request1: NSFetchRequest<NSFetchRequestResult> = Tag.fetchRequest()
        delete(request1)
        let request2: NSFetchRequest<NSFetchRequestResult> = Plate.fetchRequest()
        delete(request2)
        save()
    }

    // MARK: Awards
    
//    /// Checks whether a user has earned a specific award.
//        /// - Parameter award: The award to check.
//        /// - Returns: True if the user has earned the award, otherwise false.
//    func hasEarned(award: Award) -> Bool {
//        switch award.criterion {
//        case "plates":
//            let fetchRequest = Plate.fetchRequest()
//            let awardCount = count(for: fetchRequest)
//            return awardCount >= award.value
////        case "days":
////                let context = container.viewContext
////               let uniqueDaysCount = countUniqueDays(context: context)
////               return uniqueDaysCount >= award.value
//            
//        case "unlock":
//            return fullVersionUnlocked
//        default:
//            return false
//        }
//    }

    /// Checks whether a user has earned a specific award.
        /// - Parameter award: The award to check.
        /// - Returns: True if the user has earned the award, otherwise false.
    func hasEarned(award: Award) -> Bool {
        if award.criterion == "plates" {
            let fetchRequest = Plate.fetchRequest()
            let awardCount = count(for: fetchRequest)
            return awardCount >= award.value
        }
        return false
    }
    
    /// Checks if any awards have been earned.
       /// - Returns: True if any awards have been earned, otherwise false.
    func checkAwards() -> Bool {
        var existingAwards = congratulatedAwards
        for award in Award.allAwards {
            if hasEarned(award: award) && !existingAwards.contains(where: { $0.id == award.id }) {
                existingAwards.append(award)
                congratulatedAwards = existingAwards
                return true
            }
        }
        return false
    }

    /// Counts the number of items for a fetch request.
       /// - Parameter fetchRequest: The fetch request to count.
       /// - Returns: The count of items for the specified fetch request.
    func count<T>(for fetchRequest: NSFetchRequest<T>) -> Int {
        (try? container.viewContext.count(for: fetchRequest)) ?? 0
    }

    /// Counts the number of unique days on which plates were created.
        /// - Parameter context: The managed object context to fetch from.
        /// - Returns: The number of unique days with plates.
    func countUniqueDays(context: NSManagedObjectContext) -> Int {
        let fetchRequest: NSFetchRequest<Plate> = Plate.fetchRequest()
        do {
            let plates = try context.fetch(fetchRequest)
            // Extract unique days from plate creation dates
            let uniqueDays = Set(plates.compactMap { plate in
                plate.creationDate?.startOfDay  // Ensure we're only using the date, not time
            })
            return uniqueDays.count
        } catch {
            print("Failed to fetch plates: \(error)")
            return 0
        }
    }

    // MARK: Tags
    
    /// Returns a list of tags that are associated with a given plate, but are missing from it.
        ///
        /// - Parameter plate: The Plate object to compare against.
        /// - Returns: An array of missing tags.
    func missingTags(from plate: Plate) -> [Tag] {
        let request = Tag.fetchRequest()
        let allTags = (try? container.viewContext.fetch(request)) ?? []
        let allTagsSet = Set(allTags)
        let difference = allTagsSet.symmetricDifference(plate.plateTags)
        return difference.sorted()
    }

    /// Fetches all tags from Core Data.
        ///
        /// - Returns: An array of all Tag objects.
    func allTags() -> [Tag] {
        let request: NSFetchRequest<Tag> = Tag.fetchRequest()
        return (try? container.viewContext.fetch(request)) ?? []
    }
    
    /// Provides a header view for a tag section with an appropriate icon and toggle button.
        /// - Parameter type: The type of the tag to display.
        /// - Returns: A view for the header of a tag section.
    func tagHeaderView(for type: String, colorScheme: ColorScheme) -> some View {
        let localizedType = NSLocalizedString(type, comment: "Tag category") // Localize type name
       
        return HStack {
            // Display appropriate icon based on tag type
            if type == "Food" {
                Label(localizedType.capitalized, systemImage: "fork.knife.circle")
            } else if type == "Month" {
                Label(localizedType.capitalized, systemImage: "30.square")
            } else if type == "Emotion" {
                Label(localizedType.capitalized, systemImage: colorScheme == .dark ? "face.smiling.inverse" : "face.smiling")
            } else if type == "Reaction" {
                Label(localizedType.capitalized, systemImage: "heart.text.square")
            } else {
                Label(localizedType.capitalized, systemImage: "tag")
            }

            Spacer()

            // Toggle button for expand/collapse
            if availableTagTypes.contains(type) {
                toggleButton(isExpanded: getToggleBinding(for: type))
            }
        }
        .padding(.vertical, 4)
    }
    
    /// Determines if tags of a specific type should be displayed based on user filters.
        /// - Parameter type: The tag type to check.
        /// - Returns: True if the tags of the specified type should be shown, otherwise false.
    func shouldShowTags(for type: String) -> Bool {
        if type == "My" {
            return showTagTypeFilters[type] ?? hasNewTag
        }
        return showTagTypeFilters[type] ?? false
    }

    /// Toggles the expansion state of a button.
        /// - Parameter isExpanded: A binding to the state of the button's expansion.
        /// - Returns: A view for the toggle button with the appropriate icon.
    func toggleButton(isExpanded: Binding<Bool>) -> some View {
        Button {
            isExpanded.wrappedValue.toggle()
        } label: {
            Image(systemName: isExpanded.wrappedValue ? "chevron.down" : "chevron.right")
                .foregroundStyle(.secondary)
        }
    }

    /// Retrieves a binding to toggle the expansion of tags based on their type.
        /// - Parameter type: The tag type to retrieve the binding for.
        /// - Returns: A binding to the expansion state for the specified tag type.
    func getToggleBinding(for type: String) -> Binding<Bool> {
        return Binding<Bool>(
            get: { self.showTagTypeFilters[type] ?? false },
            set: { self.showTagTypeFilters[type] = $0 }
        )
    }

    /// Sorts tags based on their type and the default tag types.
        /// - Parameters:
        ///   - type1: The first tag type to compare.
        ///   - type2: The second tag type to compare.
        /// - Returns: True if `type1` should come before `type2` in the sorted list, otherwise false.
    func sortTags(_ type1: String, _ type2: String) -> Bool {
        let defaultTagTypes = ["Month", "Food", "Emotion", "Reaction"]
        
        if type1 == "My" {
            return true
        } else if type2 == "My" {
            return false
        }
        let isType1Default = defaultTagTypes.contains(type1)
        let isType2Default = defaultTagTypes.contains(type2)
        if isType1Default && !isType2Default {
            return false
        } else if !isType1Default && isType2Default {
            return true
        }
        return type1 < type2
    }

    /// Creates sample data for testing purposes.
    /// - This method populates Core Data with test tags and plates.
    func createSampleData() {
        let viewContext = container.viewContext
        for i in 1...5 {
            let tag = Tag(context: viewContext)
            tag.id = UUID()
            tag.name = "Tag \(i)"

            for j in 1...10 {
                let plate = Plate(context: viewContext)
                plate.title = "Issue \(i)-\(j)"
                plate.creationDate = .now
                tag.addToPlates(plate)
            }
        }

        try? viewContext.save()
    }

    /// Retrieves a `Plate` object using its unique identifier.
    /// - Parameter uniqueIdentifier: The string representation of the plate’s unique identifier.
    /// - Returns: A `Plate` object if found, otherwise `nil`.
    func plate(with uniqueIdentifier: String) -> Plate? {
        guard let url = URL(string: uniqueIdentifier) else {
            return nil
        }

        guard let id = container.persistentStoreCoordinator.managedObjectID(forURIRepresentation: url) else {
            return nil
        }

        return try? container.viewContext.existingObject(with: id) as? Plate
    }
    
    /// Determines the appropriate localization table name based on the tag type.
    /// - Parameter tagType: The type of the tag (e.g., "Month", "Emotion", etc.).
    /// - Returns: The corresponding localization table name as a `String`.
    func tableNameForTagType(_ tagType: String?) -> String {
        switch tagType {
        case "Month":
            return "DefaultMonths"
        case "Emotion":
            return "DefaultEmotions"
        case "Reaction":
            return "DefaultReactions"
        case "Food":
            return "DefaultFoodTags"
        default:
            return "Localizable" // Fallback in case no specific table is found
        }
    }

    /// Formats a date using the default date format.
       /// - Parameter date: The date to format.
       /// - Returns: The formatted date string.
   func formattedDate(_ date: Date) -> String {
        dateFormatter.string(from: date)
    }

    /// The date formatter used for formatting dates.
        /// - Returns: The configured date formatter.
    var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
      //  formatter.locale = Locale.current
        formatter.dateStyle = .medium
        return formatter
    }

    //    /// Handles resuming activity from user actions, such as shortcuts or handoff.
    //       /// If triggered, it attempts to create a new plate.
    //       /// - Parameter userActivity: The user activity object containing activity details.
    //    func resumeActivity(_ userActivity: NSUserActivity) {
    //        tryNewPlate()
    //    }
}

/// An extension to `Date` that provides a computed property for getting the start of the day.
extension Date {
    /// The start of the day for the given date.
       ///
       /// This computed property uses the current calendar to determine the start of the day (midnight) for the given `Date`.
       /// It adjusts the time to 00:00:00 of the same day, regardless of the time of day the `Date` represents.
       ///
       /// - Returns: A `Date` object representing the start of the day (midnight) of the current date.
    var startOfDay: Date {
        Calendar.current.startOfDay(for: self)
    }

}
