//
//  DataController.swift
//  MyPlates
//
//  Created by Tatyana Buinitskaya on 19.12.2024.
//

import CoreData
import UIKit

enum SortType: String {
    case dateCreated = "creationDate"
    case dateModified = "modificationDate"
}

enum Status {
    case all, missed, done
}

class DataController: ObservableObject {
    let container: NSPersistentCloudKitContainer
    
    @Published var selectedFilter: Filter? = Filter.all
    @Published var selectedPlate: Plate?
    @Published var filterText = ""
    @Published var filterTokens = [Tag]()
    
    @Published var filterEnabled = false
    @Published var filterQuality = -1
    @Published var filterStatus = Status.all
    @Published var sortType = SortType.dateCreated
    @Published var sortNewestFirst = true
    
    private var saveTask: Task<Void, Error>?
    
    static var preview: DataController = {
        let dataController = DataController(inMemory: true)
        dataController.createSampleData()
        return dataController
    }()
    
    var suggestedFilterTokens: [Tag] {
        guard filterText.starts(with: "#") else {
            return []
        }

        let trimmedFilterText = String(filterText.dropFirst()).trimmingCharacters(in: .whitespaces)
        let request = Tag.fetchRequest()

        if trimmedFilterText.isEmpty == false {
            request.predicate = NSPredicate(format: "name CONTAINS[c] %@", trimmedFilterText)
        }

        return (try? container.viewContext.fetch(request).sorted()) ?? []
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
    }
    func remoteStoreChanged(_ notification: Notification) {
        objectWillChange.send()
    }
    
    func createSampleData() {
        let viewContext = container.viewContext

        for i in 1...3 {
            let tag = Tag(context: viewContext)
            tag.id = UUID()
            tag.name = "Tag \(i)"

            for j in 1...10 {
                let plate = Plate(context: viewContext)
              
                plate.photo = "photo"
              
                tag.addToPlates(plate)
            }
        }
        try? viewContext.save()
    }
    
//    func createSampleData() {
//        let viewContext = container.viewContext
//
//        for i in 1...3 {
//            let tag = Tag(context: viewContext)
//            tag.id = UUID()
//            tag.name = "Tag \(i)"
//
//            for j in 1...10 {
//                let plate = Plate(context: viewContext)
//                // Generate a unique file path for the photo
//                let photoFileName = "Plate_\(i)_\(j).jpg"
//                let photoFilePath = getPhotoDirectory().appendingPathComponent(photoFileName).path
//                // Set the photo file path
//                plate.photo = photoFilePath
//                // Optionally save a placeholder image
//                savePlaceholderPhoto(fileName: photoFileName)
//                tag.addToPlates(plate)
//            }
//        }
//        try? viewContext.save()
//    }
    // photo derictory
        private func getPhotoDirectory() -> URL {
            let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
            let photoDirectory = paths[0].appendingPathComponent("Photos")
            if !FileManager.default.fileExists(atPath: photoDirectory.path) {
                try? FileManager.default.createDirectory(at: photoDirectory, withIntermediateDirectories: true)
            }
            return photoDirectory
        }
        

        private func savePlaceholderPhoto(fileName: String) {
            let photoDirectory = getPhotoDirectory()
            let fileURL = photoDirectory.appendingPathComponent(fileName)
            // Create a simple placeholder image
            let placeholderImage = UIImage(systemName: "photo") ?? UIImage()
            if let imageData = placeholderImage.jpegData(compressionQuality: 1.0) {
                try? imageData.write(to: fileURL)
            }
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
    
    func missingTags(from plate: Plate) -> [Tag] {
        let request = Tag.fetchRequest()
        let allTags = (try? container.viewContext.fetch(request)) ?? []

        let allTagsSet = Set(allTags)
        let difference = allTagsSet.symmetricDifference(plate.plateTags)

        return difference.sorted()
    }
    
//    func platesForSelectedFilter() -> [Plate] {
//        let filter = selectedFilter ?? .all
//        var allPlates: [Plate]
//
//        if let tag = filter.tag {
//            allPlates = tag.plates?.allObjects as? [Plate] ?? []
//        } else {
//            let request = Plate.fetchRequest()
//          //  request.predicate = NSPredicate(format: "date > %@", filter.minModificationDate as NSDate)
//            request.predicate = NSPredicate(format: "modificationDate > %@", filter.minModificationDate as NSDate)
//
//            
//            
//            allPlates = (try? container.viewContext.fetch(request)) ?? []
//        }
//        
//
//        
//        return allPlates.sorted()
//    }
    func platesForSelectedFilter() -> [Plate] {
        let filter = selectedFilter ?? .all
        var predicates = [NSPredicate]()

        if let tag = filter.tag {
            let tagPredicate = NSPredicate(format: "tags CONTAINS %@", tag)
            predicates.append(tagPredicate)
        } else {
            let datePredicate = NSPredicate(format: "modificationDate > %@", filter.minModificationDate as NSDate)
            predicates.append(datePredicate)
        }
        let trimmedFilterText = filterText.trimmingCharacters(in: .whitespaces)

        if trimmedFilterText.isEmpty == false {
            let titlePredicate = NSPredicate(format: "title CONTAINS[c] %@", trimmedFilterText)
            let notesPredicate = NSPredicate(format: "notes CONTAINS[c] %@", trimmedFilterText)
            let combinedPredicate = NSCompoundPredicate(orPredicateWithSubpredicates: [titlePredicate, notesPredicate])
            predicates.append(combinedPredicate)
        }
        // or
        if filterTokens.isEmpty == false {
            let tokenPredicate = NSPredicate(format: "ANY tags IN %@", filterTokens)
            predicates.append(tokenPredicate)
        }
        // and
//        if filterTokens.isEmpty == false {
//            for filterToken in filterTokens {
//                let tokenPredicate = NSPredicate(format: "tags CONTAINS %@", filterToken)
//                predicates.append(tokenPredicate)
//            }
//        }
        
        if filterEnabled {
            if filterQuality >= 0 {
                let qualityFilter = NSPredicate(format: "quality = %d", filterQuality)
                predicates.append(qualityFilter)
            }

            if filterStatus != .all {
                let lookForDone = filterStatus == .done
                let statusFilter = NSPredicate(format: "completed = %@", NSNumber(value: lookForDone))
                predicates.append(statusFilter)
            }
        }

        let request = Plate.fetchRequest()
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        request.sortDescriptors = [NSSortDescriptor(key: sortType.rawValue, ascending: sortNewestFirst)]
        let allPlates = (try? container.viewContext.fetch(request)) ?? []
        
        
        return allPlates
    }
    func newPlate() {
        let plate = Plate(context: container.viewContext)
        plate.title = "New Plate"
        plate.creationDate = .now
        plate.quality = 1
        
        if let tag = selectedFilter?.tag {
            plate.addToTags(tag)
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
            // returns true if they added a certain number of issues
            let fetchRequest = Plate.fetchRequest()
            let awardCount = count(for: fetchRequest)
            return awardCount >= award.value

        case "closed":
            // returns true if they closed a certain number of issues
            let fetchRequest = Plate.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "completed = true")
            let awardCount = count(for: fetchRequest)
            return awardCount >= award.value

        case "tags":
            // return true if they created a certain number of tags
            let fetchRequest = Tag.fetchRequest()
            let awardCount = count(for: fetchRequest)
            return awardCount >= award.value

        default:
            // an unknown award criterion; this should never be allowed
            // fatalError("Unknown award criterion: \(award.criterion)")
            return false
        }
    }
 
}
