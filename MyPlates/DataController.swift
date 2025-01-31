//
//  DataController.swift
//  MyPlates
//
//  Created by Tatyana Buinitskaya on 19.12.2024.
//
import CloudKit
import CoreData
import UIKit
import SwiftUI

class DataController: ObservableObject {
    let container: NSPersistentCloudKitContainer
    @Published var selectedFilter: Filter? = Filter.filterForDate(Date())
    @Published var selectedPlate: Plate?
    @Published var filterText = ""
    @Published var filterQuality = -1
    @Published var filterMealtime: String?
    @Published var sortNewestFirst = true
    @Published var selectedImage: UIImage?
    @Published var showCongratulations: Bool = false
    @Published var currentAward: Award = .example
    @Published var selectedDate: Date? = Date()
    @Published var showTagTypeFilters: [String: Bool] = [:]
    @Published var hasNewTag = false
    @Published var availableTagTypes: [String] = [] {
    didSet {
        UserDefaults.standard.set(availableTagTypes, forKey: "availableTagTypes")
    }
}
    @Published var showNotes: Bool {
           didSet {
               UserDefaults.standard.set(showNotes, forKey: "showNotes")
           }
       }
       @Published var showMealTime: Bool {
           didSet {
               UserDefaults.standard.set(showMealTime, forKey: "showMealTime")
           }
       }
       @Published var showQuality: Bool {
           didSet {
               UserDefaults.standard.set(showQuality, forKey: "showQuality")
           }
       }
    @Published var showTags: Bool {
        didSet {
            UserDefaults.standard.set(showTags, forKey: "showTags")
        }
    }
    let mealtimeDictionary: [String: String] = [
        "breakfast": NSLocalizedString("Breakfast", comment: "Mealtime: Breakfast"),
        "morningSnack": NSLocalizedString("Morning snack", comment: "Mealtime: Morning Snack"),
        "lunch": NSLocalizedString("Lunch", comment: "Mealtime: Lunch"),
        "daySnack": NSLocalizedString("Day snack", comment: "Mealtime: Day Snack"),
        "dinner": NSLocalizedString("Dinner", comment: "Mealtime: Dinner"),
        "eveningSnack": NSLocalizedString("Evening snack", comment: "Mealtime: Evening Snack"),
        "anytimeMeal": NSLocalizedString("Anytime meal", comment: "Mealtime: Anytime Meal")
    ]
    private var saveTask: Task<Void, Error>?
    static var preview: DataController = {
        let dataController = DataController(inMemory: true)
        // dataController.createSampleData()
        return dataController
    }()
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
                    title += NSLocalizedString(" Unhealthy", comment: "Unhealthy quality filter")
                } else if filter.quality == 1 {
                    title += NSLocalizedString(" Moderate", comment: "Moderate quality filter")
                } else if filter.quality == 2 {
                    title += NSLocalizedString(" Healthy", comment: "Healthy quality filter")
                }
            }
            if let filter = selectedFilter, let mealtime = filter.mealtime {
                if let mealtimeTitle = mealtimeDictionary[mealtime] {
                    title += " \(mealtimeTitle)"
                }
            }
            if let tag = selectedFilter?.tag {
                title += " \(tag.name ?? NSLocalizedString("Filtered Plates", comment: "Fallback tag name"))"
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
                return NSLocalizedString("Unhealthy", comment: "Unhealthy quality filter")
            } else if filter.quality == 1 {
                return NSLocalizedString("Moderate", comment: "Moderate quality filter")
            } else if filter.quality == 2 {
                return NSLocalizedString("Healthy", comment: "Healthy quality filter")
            }
        }
        if let filter = selectedFilter {
            if let mealtime = filter.mealtime {
                return mealtimeDictionary[mealtime] ?? NSLocalizedString("Unknown", comment: "Unknown mealtime")
            }
        }
        // If no filter is selected, return "All Plates" or fallback to default
        return NSLocalizedString("All Plates", comment: "Fallback title for all plates")
    }
    var allPlatesCount: Int {
        let request: NSFetchRequest<Plate> = Plate.fetchRequest()
        let count = (try? container.viewContext.count(for: request)) ?? 0
        return count
    }
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
    init(inMemory: Bool = false) {
        self.showNotes = UserDefaults.standard.bool(forKey: "showNotes")
        self.showMealTime = UserDefaults.standard.bool(forKey: "showMealTime")
        self.showQuality = UserDefaults.standard.bool(forKey: "showQuality")
        self.showTags = UserDefaults.standard.bool(forKey: "showTags")
        self.availableTagTypes = UserDefaults.standard.stringArray(forKey: "availableTagTypes") ?? []
        container = NSPersistentCloudKitContainer(name: "Main")
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(filePath: "/dev/null")
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        container.persistentStoreDescriptions.first?.setOption(
            true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey
        )
        NotificationCenter.default.addObserver(
            forName: .NSPersistentStoreRemoteChange,
            object: container.persistentStoreCoordinator,
            queue: .main,
            using: remoteStoreChanged
        )
        container.loadPersistentStores { _, error in
            if let error {
                fatalError("Fatal error loading store: \(error.localizedDescription)")
            }
        }
    }
    func remoteStoreChanged(_ notification: Notification) {
        objectWillChange.send()
    }
    func createDefaultTags(tagType: String, tagNames: [String], context: NSManagedObjectContext) {
        for tagName in tagNames {
            let fetchRequest: NSFetchRequest<Tag> = Tag.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "name == %@", tagName)
            // If the tag doesn't exist, create and save it
            if (try? context.count(for: fetchRequest)) == 0 {
                let tag = Tag(context: context)
                tag.id = UUID()
                tag.name = tagName
                tag.type = tagType
                addTagTypeIfNeeded(tagType)
            }
        }
        saveContext(context)
    }

    func deleteDefaultTags(tagType: String, context: NSManagedObjectContext) {
        let fetchRequest: NSFetchRequest<Tag> = Tag.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "type == %@", tagType)
        do {
            let tagsToDelete = try context.fetch(fetchRequest)
            for tag in tagsToDelete {
                context.delete(tag)
            }
            removeTagTypeIfNeeded(tagType)
            saveContext(context)
            print("Successfully deleted all \(tagType) tags")
        } catch {
            print("Failed to delete \(tagType) tags: \(error)")
        }
    }
    // MARK: - Tag Type Management
    private func addTagTypeIfNeeded(_ tagType: String) {
        if !availableTagTypes.contains(tagType) {
            availableTagTypes.append(tagType)
        }
    }

    private func removeTagTypeIfNeeded(_ tagType: String) {
        if let index = availableTagTypes.firstIndex(of: tagType) {
            availableTagTypes.remove(at: index)
        }
    }
    // MARK: - Core Data Save
    private func saveContext(_ context: NSManagedObjectContext) {
        do {
            try context.save()
        } catch {
            print("Failed to save context: \(error)")
        }
    }
    // MARK: - Default Tag Management
    func createDefaultFoodTags(context: NSManagedObjectContext) {
        createDefaultTags(tagType: "Food", tagNames: defaultFoodTags, context: context)
    }
    func deleteDefaultFoodTags(context: NSManagedObjectContext) {
        deleteDefaultTags(tagType: "Food", context: context)
    }
    func createDefaultMonthTags(context: NSManagedObjectContext) {
        let defaultMonthTags = [
            "January", "February", "March", "April", "May", "June",
            "July", "August", "September", "October", "November", "December"
        ].map { NSLocalizedString($0, tableName: "DefaultTags", comment: "Month name") }
        createDefaultTags(tagType: "Month", tagNames: defaultMonthTags, context: context)
    }
    func deleteDefaultMonthTags(context: NSManagedObjectContext) {
        deleteDefaultTags(tagType: "Month", context: context)
    }
    func createDefaultEmotionTags(context: NSManagedObjectContext) {
        let defaultEmotionTags = ["Happy", "Stress"].map { NSLocalizedString(
            $0,
            tableName: "DefaultTags",
            comment: "Emotion"
        ) }
        createDefaultTags(tagType: "Emotion", tagNames: defaultEmotionTags, context: context)
    }
    func deleteDefaultEmotionTags(context: NSManagedObjectContext) {
        deleteDefaultTags(tagType: "Emotion", context: context)
    }
    func createDefaultReactionTags(context: NSManagedObjectContext) {
        let defaultReactionTags = ["Sick", "Feel good"].map { NSLocalizedString(
            $0,
            tableName: "DefaultTags",
            comment: "Reaction"
        ) }
        createDefaultTags(tagType: "Reaction", tagNames: defaultReactionTags, context: context)
    }
    func deleteDefaultReactionTags(context: NSManagedObjectContext) {
        deleteDefaultTags(tagType: "Reaction", context: context)
    }
    func save() {
        saveTask?.cancel()
        if container.viewContext.hasChanges {
            try? container.viewContext.save()
        }
    }
    func queueSave() {
        saveTask?.cancel()
        saveTask = Task { @MainActor in
            try await Task.sleep(for: .seconds(3))
            save()
        }
    }
    func delete(_ object: NSManagedObject) {
        objectWillChange.send()
        container.viewContext.delete(object)
        save()
    }
    private func delete(_ fetchRequest: NSFetchRequest<NSFetchRequestResult>) {
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        batchDeleteRequest.resultType = .resultTypeObjectIDs
        if let delete = try? container.viewContext.execute(batchDeleteRequest) as? NSBatchDeleteResult {
            let changes = [NSDeletedObjectsKey: delete.result as? [NSManagedObjectID] ?? []]
            NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes, into: [container.viewContext])
        }
    }
    func deleteAll() {
        let request1: NSFetchRequest<NSFetchRequestResult> = Tag.fetchRequest()
        delete(request1)
        let request2: NSFetchRequest<NSFetchRequestResult> = Plate.fetchRequest()
        delete(request2)
        save()
    }
    // many tags
    func missingTags(from plate: Plate) -> [Tag] {
        let request = Tag.fetchRequest()
        let allTags = (try? container.viewContext.fetch(request)) ?? []
        let allTagsSet = Set(allTags)
        let difference = allTagsSet.symmetricDifference(plate.plateTags)
        return difference.sorted()
    }
    func allTags() -> [Tag] {
        let request: NSFetchRequest<Tag> = Tag.fetchRequest()
        return (try? container.viewContext.fetch(request)) ?? []
    }
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
        if let tag = filter.tag {
               let tagPredicate = NSPredicate(format: "tags CONTAINS %@", tag)
               predicates.append(tagPredicate)
           }
        // Apply quality filter if a quality is selected
        if filter.quality >= 0 {
            predicates.append(NSPredicate(format: "quality = %d", filter.quality))
        }
        // Apply mealtime filter if a mealtime is selected
        if let mealtime = filter.mealtime {
            predicates.append(NSPredicate(format: "mealtime = %@", mealtime))
        }
        // Apply filter text if it exists
        let trimmedFilterText = filterText.trimmingCharacters(in: .whitespaces)
        if !trimmedFilterText.isEmpty {
            let titlePredicate = NSPredicate(format: "title CONTAINS[c] %@", trimmedFilterText)
            let notesPredicate = NSPredicate(format: "notes CONTAINS[c] %@", trimmedFilterText)
            predicates.append(NSCompoundPredicate(orPredicateWithSubpredicates: [titlePredicate, notesPredicate]))
        }
        // Combine all predicates (AND logic between date, quality, etc.)
        let fetchRequest: NSFetchRequest<Plate> = Plate.fetchRequest()
        if !predicates.isEmpty {
            fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        }
        // If the filter is "All", no predicate will be applied (fetch all plates)
        if filter == .all {
            fetchRequest.predicate = nil
        }
        // Sorting plates by creationDate
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: sortNewestFirst)]
        return (try? container.viewContext.fetch(fetchRequest)) ?? []
    }
    // m
    func saveImageToFileSystem(image: UIImage) -> String? {
        let photoDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let photoName = UUID().uuidString + ".jpg"
        let photoURL = photoDirectory.appendingPathComponent(photoName)
        if let imageData = image.jpegData(compressionQuality: 0.8) {
            do {
                try imageData.write(to: photoURL)
                print("Image successfully saved at path: \(photoURL.path)")
                return photoURL.path
            } catch {
                print("Error saving image: \(error.localizedDescription)")
            }
        } else {
            print("Failed to generate JPEG data for the image.")
        }
        return nil
    }
    func saveImageToCloudKit(image: UIImage, imageName: String) async -> CKRecord.ID? {
        // Convert UIImage to Data (JPEG format)
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            print("Failed to convert image to JPEG data.")
            return nil
        }
        // Save the image data locally before uploading to CloudKit (in a temporary directory)
        let fileManager = FileManager.default
        let temporaryDirectoryURL = fileManager.temporaryDirectory
        let fileURL = temporaryDirectoryURL.appendingPathComponent(imageName).appendingPathExtension("jpg")
        do {
            // Write the image data to the file URL
            try imageData.write(to: fileURL)
            // Create a CKAsset from the image file URL
            let imageAsset = CKAsset(fileURL: fileURL)
            // Create a CloudKit record to save the asset
            let record = CKRecord(recordType: "Plate") // Adjust the record type as needed
            record["imageData"] = imageAsset
            // Save the record to CloudKit's private database
            let container = CKContainer.default()
            let privateDatabase = container.privateCloudDatabase
            // Save the record and await the result
            let savedRecord = try await privateDatabase.save(record)
            // Clean up the local file after uploading it to CloudKit
            try fileManager.removeItem(at: fileURL)
            // Return the recordID of the saved record
            return savedRecord.recordID
        } catch {
            print("Error saving image to CloudKit: \(error.localizedDescription)")
            return nil
        }
    }
    func fetchImageFromCloudKit(recordID: String) async -> UIImage? {
        // Check if the recordID is non-empty.
        guard !recordID.isEmpty else {
            print("Record ID is empty")
            return nil
        }
        let container = CKContainer.default()
        let privateDatabase = container.privateCloudDatabase
        let ckRecordID = CKRecord.ID(recordName: recordID)
        do {
            let record = try await privateDatabase.record(for: ckRecordID)
            if let ckAsset = record["imageData"] as? CKAsset, let fileURL = ckAsset.fileURL {
                let imageData = try Data(contentsOf: fileURL)
                if let image = UIImage(data: imageData) {
                    print("Image fetched successfully from CloudKit.")
                    return image
                } else {
                    print("Failed to convert data into an image.")
                    return nil
                }
            } else {
                print("No image data found for record.")
                return nil
            }
        } catch {
            print("Failed to fetch record from CloudKit: \(error.localizedDescription)")
            return nil
        }
    }
    func fetchImageFromFileSystem(imagePath: String) -> UIImage? {
        // Extract the file name from the image path (if it's a full path or a file name)
        let imageFileName = imagePath.components(separatedBy: "/").last ?? imagePath
        // Construct the local file URL by appending the file name to the app's document directory path
        let fileManager = FileManager.default
        guard let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("Error: Could not find the document directory.")
            return nil
        }
        let localFileURL = documentsURL.appendingPathComponent(imageFileName)
        print("Local file URL: \(localFileURL.path)")  // Log the constructed local file path
        // Check if the file exists in the local file system
        guard fileManager.fileExists(atPath: localFileURL.path) else {
            print("Image not found in local storage at path: \(localFileURL.path)")
            return nil
        }
        // If the file exists, load the image from the file path
        return UIImage(contentsOfFile: localFileURL.path)
    }
    func countQualityPlates(for quality: Int) -> Int {
        let request: NSFetchRequest<Plate> = Plate.fetchRequest()
        request.predicate = NSPredicate(format: "quality = %d", quality)
        return (try? container.viewContext.count(for: request)) ?? 0
    }
   //  if mealtime not tags
    func countMealtimePlates(for mealtime: String) -> Int {
        let request: NSFetchRequest<Plate> = Plate.fetchRequest()
        request.predicate = NSPredicate(format: "mealtime = %@", mealtime) // Use %@ for strings
        return (try? container.viewContext.count(for: request)) ?? 0
    }
    func countTagPlates(for tagName: String) -> Int {
        let request: NSFetchRequest<Plate> = Plate.fetchRequest()
        // Use the name of the tag for comparison
        request.predicate = NSPredicate(format: "ANY tags.name == %@", tagName)
        return (try? container.viewContext.count(for: request)) ?? 0
    }
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
    func newPlate() {
        let plate = Plate(context: container.viewContext)
      // Format the date for localization
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long // Adjust to .short, .medium, or .full as needed
        dateFormatter.timeStyle = .none // Only include the date, no time
        dateFormatter.locale = Locale.current // Respect the user's locale settings
        let localizedDateString = dateFormatter.string(from: plate.creationDate ?? .now)
        // Construct the localized title
        plate.title = String(
            format: NSLocalizedString("Plate-%@", comment: "Title with creation date"),
          localizedDateString
        )
    //    plate.title = NSLocalizedString("Plate ", comment: "Part of title") + (plate.creationDate ?? .now).formatted
        // plate.creationDate = .now
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
        plate.mealtime = "anytimeMeal"
        plate.photo = nil
        selectedPlate = plate
        save()
    }
// MARK: Tags
    func newTag() {
        let tag = Tag(context: container.viewContext)
        tag.id = UUID()
        tag.name = " New Tag"
        tag.creationDate = Date()
        tag.type = "User"
        if !availableTagTypes.contains(tag.type ?? "User") {
            availableTagTypes.append(tag.type ?? "User")
            }
        save()
        // Add new tag logic
           hasNewTag = true  // Ensure "User" tags are initially shown
           showTagTypeFilters["User"] = true
    }
    func isTagRecentlyCreated(tag: Tag) -> Bool {
        guard let creationDate = tag.creationDate else { return false }
        let timeInterval = Date().timeIntervalSince(creationDate)
        return timeInterval <= 3600 // 3600 seconds = 1 hour
    }
    func sortTags(_ type1: String, _ type2: String) -> Bool {
        let defaultTagTypes = ["Month", "Food", "Emotion", "Reaction"]
        if type1 == "User" {
            return true
        } else if type2 == "User" {
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
    // Ensure "New Tags" section is always expanded when a new tag is created
    func shouldShowTags(for type: String) -> Bool {
        if type == "User" {
            return showTagTypeFilters[type] ?? hasNewTag
        }
        return showTagTypeFilters[type] ?? false
    }
    func toggleButton(isExpanded: Binding<Bool>) -> some View {
        Button {
            isExpanded.wrappedValue.toggle()
        } label: {
            Image(systemName: isExpanded.wrappedValue ? "chevron.down" : "chevron.right")
                .foregroundColor(.secondary)
        }
    }
    func getToggleBinding(for type: String) -> Binding<Bool> {
        return Binding<Bool>(
            get: { self.showTagTypeFilters[type] ?? false },
            set: { self.showTagTypeFilters[type] = $0 }
        )
    }
    func tagHeaderView(for type: String) -> some View {
        HStack {
            // Display appropriate icon based on tag type
            if type == "Food" {
                Image(systemName: "fork.knife")
                    .foregroundColor(.blue)
            } else if type == "Month" {
                Image(systemName: "30.square")
                    .foregroundColor(.blue)
            } else if type == "Emotion" {
                Image(systemName: "face.smiling")
                    .foregroundColor(.blue)
            } else if type == "Reaction" {
                Image(systemName: "exclamationmark.triangle")
                    .foregroundColor(.blue)
            } else {
                Image(systemName: "tag")
                    .foregroundColor(.blue)
            }
            Text(type.capitalized)
            Spacer()
            // Toggle button for expand/collapse
            if availableTagTypes.contains(type) {
                toggleButton(isExpanded: getToggleBinding(for: type))
            }
        }
        .padding(.vertical, 4)
    }
    func count<T>(for fetchRequest: NSFetchRequest<T>) -> Int {
        (try? container.viewContext.count(for: fetchRequest)) ?? 0
    }
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
    func hasEarned(award: Award) -> Bool {
        switch award.criterion {
        case "plates":
            let fetchRequest = Plate.fetchRequest()
            let awardCount = count(for: fetchRequest)
            return awardCount >= award.value
//        case "days":
//                let context = container.viewContext
//               let uniqueDaysCount = countUniqueDays(context: context)
//               return uniqueDaysCount >= award.value
        default:
            return false
        }
    }
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
   func formattedDate(_ date: Date) -> String {
        dateFormatter.string(from: date)
    }
    var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }
}

extension Date {
    var startOfDay: Date {
        Calendar.current.startOfDay(for: self)
    }
}
