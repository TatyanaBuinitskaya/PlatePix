//
//  DataController.swift
//  MyPlates
//
//  Created by Tatyana Buinitskaya on 19.12.2024.
//
import CloudKit
import CoreData
import UIKit

enum SortType: String {
    case dateCreated = "creationDate"
    case dateModified = "modificationDate"
}

class DataController: ObservableObject {
    let container: NSPersistentCloudKitContainer
    
    @Published var selectedFilter: Filter? = Filter.today
    @Published var selectedPlate: Plate?
    @Published var filterText = ""
    @Published var filterTokens = [Tag]()
    
    @Published var filterQuality = -1
    @Published var sortType = SortType.dateCreated
    @Published var sortNewestFirst = true
    // m
    @Published var selectedImage: UIImage?
    @Published var showCongratulations: Bool = false
    @Published var currentAward: Award = .example
    
    @Published var selectedDate: Date? = nil
 
    
    private var saveTask: Task<Void, Error>?
    
    static var preview: DataController = {
        let dataController = DataController(inMemory: true)
        // dataController.createSampleData()
        return dataController
    }()
    
    
    var dynamicTitle: String {
        if let tag = selectedFilter?.tag {
            return tag.name ?? "Filtered Plates"
        }
        
        if selectedFilter == Filter.today {
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .long
            dateFormatter.timeStyle = .none
            return dateFormatter.string(from: Date()) // Today's date
        }
        
        if let selectedDate = selectedDate { // Assuming `selectedDate` is a variable storing the picked date
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .long
            dateFormatter.timeStyle = .none
            return dateFormatter.string(from: selectedDate) // Selected date
        }
        
        if selectedFilter == Filter.healthy {
            return "Healthy"
        }
        
        return "All Plates"
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
        container = NSPersistentCloudKitContainer(name: "Main")
        
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(filePath: "/dev/null")
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        container.persistentStoreDescriptions.first?.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)
        NotificationCenter.default.addObserver(forName: .NSPersistentStoreRemoteChange, object: container.persistentStoreCoordinator, queue: .main, using: remoteStoreChanged)
        
        container.loadPersistentStores { storeDescription, error in
            if let error {
                fatalError("Fatal error loading store: \(error.localizedDescription)")
            }
        }
        //m
        let context = container.viewContext
        createDefaultTags(context: context)

    }
    func remoteStoreChanged(_ notification: Notification) {
        objectWillChange.send()
    }
    
    // m
    func createDefaultTags(context: NSManagedObjectContext) {
        let defaultTagNames = ["Breakfast", "Lunch", "Dinner", "Snack"]
        
        for tagName in defaultTagNames {
            let fetchRequest: NSFetchRequest<Tag> = Tag.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "name == %@", tagName)
            
            if let count = try? context.count(for: fetchRequest), count == 0 {
                let tag = Tag(context: context)
                tag.id = UUID()
                tag.name = tagName
            }
        }
        
        try? context.save()
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
    
    // 1 tag
    func missingTags(from plate: Plate) -> [Tag] {
        let request = Tag.fetchRequest()
        let allTags = (try? container.viewContext.fetch(request)) ?? []
        
        guard let plateTag = plate.tag else {
            return allTags.sorted()
        }
        return allTags.filter { $0 != plateTag }.sorted()
    }
    
    
    func allTags() -> [Tag] {
        let request: NSFetchRequest<Tag> = Tag.fetchRequest()
    
        return (try? container.viewContext.fetch(request)) ?? []
    }
    
//    func platesForSelectedFilter() -> [Plate] {
//        let filter = selectedFilter ?? .all
//        var predicates = [NSPredicate]()
//        
//        if let tag = filter.tag {
//            //  let tagPredicate = NSPredicate(format: "tags CONTAINS %@", tag)
//            let tagPredicate = NSPredicate(format: "tag.name == %@", tag.tagName)
//            
//            predicates.append(tagPredicate)
//        } else {
//            let datePredicate = NSPredicate(format: "modificationDate > %@", filter.minModificationDate as NSDate)
//            predicates.append(datePredicate)
//        }
//        
//        if filter.quality >= 0 {
//            let qualityPredicate = NSPredicate(format: "quality = %d", filter.quality)
//            predicates.append(qualityPredicate)
//        } else if filterQuality >= 0 {
//            let qualityFilterPredicate = NSPredicate(format: "quality = %d", filterQuality)
//            predicates.append(qualityFilterPredicate)
//        }
//        
//        let trimmedFilterText = filterText.trimmingCharacters(in: .whitespaces)
//        
//        if trimmedFilterText.isEmpty == false {
//            let titlePredicate = NSPredicate(format: "title CONTAINS[c] %@", trimmedFilterText)
//            let notesPredicate = NSPredicate(format: "notes CONTAINS[c] %@", trimmedFilterText)
//            let tagPredicate = NSPredicate(format: "tag.name CONTAINS[c] %@", trimmedFilterText) // Search in tag's name
//            
//            
//            
//            let combinedPredicate = NSCompoundPredicate(orPredicateWithSubpredicates: [titlePredicate, notesPredicate, tagPredicate])
//            predicates.append(combinedPredicate)
//        }
//        
//        // Filter by quality specified in the Sidebar filter
//        if filter.quality >= 0 {
//            let qualityPredicate = NSPredicate(format: "quality = %d", filter.quality)
//            predicates.append(qualityPredicate)
//        } else if filterQuality >= 0 {
//            // Apply ContentView quality filter only if no Sidebar quality filter is active
//            let qualityFilterPredicate = NSPredicate(format: "quality = %d", filterQuality)
//            predicates.append(qualityFilterPredicate)
//        }
//        
//        let request = Plate.fetchRequest()
//        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
//        request.sortDescriptors = [NSSortDescriptor(key: sortType.rawValue, ascending: sortNewestFirst)]
//        let allPlates = (try? container.viewContext.fetch(request)) ?? []
//        
//        
//        return allPlates
//    }
    
    func platesForSelectedFilter() -> [Plate] {
           let filter = selectedFilter ?? .all
           var predicates = [NSPredicate]()

        if let tag = filter.tag {
            let tagPredicate = NSPredicate(format: "tag.name == %@", tag.tagName)
            
            predicates.append(tagPredicate)
        }
        else if let selectedDate = selectedDate {
               let startOfDay = Calendar.current.startOfDay(for: selectedDate)
               let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay)!

               let datePredicate = NSPredicate(format: "creationDate >= %@ AND creationDate < %@", startOfDay as NSDate, endOfDay as NSDate)
               predicates.append(datePredicate)
           } else if filter.minModificationDate > Date.distantPast {
               let datePredicate = NSPredicate(format: "modificationDate > %@", filter.minModificationDate as NSDate)
               predicates.append(datePredicate)
           }

           if filter.quality >= 0 {
               let qualityPredicate = NSPredicate(format: "quality = %d", filter.quality)
               predicates.append(qualityPredicate)
           } else if filterQuality >= 0 {
               let qualityFilterPredicate = NSPredicate(format: "quality = %d", filterQuality)
               predicates.append(qualityFilterPredicate)
           }

           let trimmedFilterText = filterText.trimmingCharacters(in: .whitespaces)
           if !trimmedFilterText.isEmpty {
               let titlePredicate = NSPredicate(format: "title CONTAINS[c] %@", trimmedFilterText)
               let notesPredicate = NSPredicate(format: "notes CONTAINS[c] %@", trimmedFilterText)
               let combinedPredicate = NSCompoundPredicate(orPredicateWithSubpredicates: [titlePredicate, notesPredicate])
               predicates.append(combinedPredicate)
           }

           let request = Plate.fetchRequest()
           request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
           request.sortDescriptors = [NSSortDescriptor(key: sortType.rawValue, ascending: sortNewestFirst)]
           
           return (try? container.viewContext.fetch(request)) ?? []
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
    
   
   
    
//    func saveImageToiCloud(image: UIImage, imageName: String) -> String? {
//        // Correctly construct the iCloud path without duplication
//        guard let iCloudURL = FileManager.default.url(forUbiquityContainerIdentifier: nil)?
//                .appendingPathComponent("Documents")
//                .appendingPathComponent("\(imageName).jpg") else {
//            print("Error: iCloud URL is invalid.")
//            return nil
//        }
//        
//        if let imageData = image.jpegData(compressionQuality: 0.8) {
//            do {
//                try imageData.write(to: iCloudURL)
//                print("Image successfully saved to iCloud at path: \(iCloudURL.path)")
//                return iCloudURL.path
//            } catch {
//                print("Error saving image to iCloud: \(error.localizedDescription)")
//            }
//        } else {
//            print("Failed to generate JPEG data for the image.")
//        }
//        return nil
//    }
    
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

//    func saveCloudKitRecordID(recordID: CKRecord.ID?) {
//        guard let recordID = recordID else {
//            print("Invalid record ID.")
//            return
//        }
//
//        // Get the context from your Core Data container
//        let context = container.viewContext
//
//        // Fetch the PlateEntity object you want to update or create a new one
//        let plateEntity = Plate(context: context)
//        
//        
//        // Save the CloudKit record ID as a string (we're using the record's ID, which is a String)
//        plateEntity.cloudRecordID = recordID.recordName // Save the record ID as a string
//
//        // Optionally, store the photo attribute (image URL or path) as well
//        plateEntity.photo = "YourImagePathOrURLHere" // Example: URL or local file path for the photo
//
//        do {
//            // Save the context to persist the data
//            try context.save()
//            print("CloudKit record ID saved to Core Data.")
//        } catch {
//            print("Failed to save CloudKit record ID to Core Data: \(error.localizedDescription)")
//        }
//    }

//    func fetchImageFromiCloud(imagePath: String) -> UIImage? {
//        // Check if the provided imagePath already contains the directory path.
//        // If so, we should only append the image file name to the Documents directory
//        let imageFileName = imagePath.components(separatedBy: "/").last ?? imagePath
//        
//        // Correctly construct the iCloud URL without duplicating path components
//        guard let iCloudURL = FileManager.default.url(forUbiquityContainerIdentifier: nil)?
//                .appendingPathComponent("Documents")
//                .appendingPathComponent(imageFileName) else {
//            print("Error: iCloud URL is invalid or file not found.")
//            return nil
//        }
//        
//        print("iCloud file URL: \(iCloudURL.path)")  // Log the constructed iCloud path
//        
//        // Use fileExistsAtPath to confirm if the file exists in iCloud
//        guard FileManager.default.fileExists(atPath: iCloudURL.path) else {
//            print("Image not found in iCloud at path: \(iCloudURL.path)")
//            return nil
//        }
//
//        return UIImage(contentsOfFile: iCloudURL.path)
//    }
    
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
    
    
    func countPlates(for quality: Int) -> Int {
        let request: NSFetchRequest<Plate> = Plate.fetchRequest()
        request.predicate = NSPredicate(format: "quality = %d", quality)
        return (try? container.viewContext.count(for: request)) ?? 0
    }
    
    // 1 tag
    func newPlate() {
        
        let plate = Plate(context: container.viewContext)
        plate.title = "Plate " + (plate.creationDate ?? .now).formatted()
        plate.creationDate = .now
        plate.quality = 1
        // m
        plate.photo = nil
        if let tag = selectedFilter?.tag {
            plate.tag = tag
        }
        
        selectedPlate = plate

        save()
        
    }
    
 
   
    
    func newTag() {
        let tag = Tag(context: container.viewContext)
        tag.id = UUID()
        tag.name = "New tag"
        save()
    }
    
    func count<T>(for fetchRequest: NSFetchRequest<T>) -> Int {
        (try? container.viewContext.count(for: fetchRequest)) ?? 0
    }
    
    func hasEarned(award: Award) -> Bool {
        switch award.criterion {
        case "plates":
          
            let fetchRequest = Plate.fetchRequest()
            let awardCount = count(for: fetchRequest)
            return awardCount >= award.value
            
            //        case "closed":
            //            // returns true if they closed a certain number of issues
            //            let fetchRequest = Plate.fetchRequest()
            //            fetchRequest.predicate = NSPredicate(format: "completed = true")
            //            let awardCount = count(for: fetchRequest)
            //            return awardCount >= award.value
            
            //        case "tags":
            //            // return true if they created a certain number of tags
            //            let fetchRequest = Tag.fetchRequest()
            //            let awardCount = count(for: fetchRequest)
            //            return awardCount >= award.value
            
        default:
            // an unknown award criterion; this should never be allowed
            // fatalError("Unknown award criterion: \(award.criterion)")
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
}
