//
//  DataController.swift
//  MyPlates
//
//  Created by Tatyana Buinitskaya on 19.12.2024.
//

import CoreData
import UIKit

class DataController: ObservableObject {
    let container: NSPersistentCloudKitContainer
    
    @Published var selectedFilter: Filter? = Filter.all
    @Published var selectedPlate: Plate?
    
    private var saveTask: Task<Void, Error>?
    
    static var preview: DataController = {
        let dataController = DataController(inMemory: true)
        dataController.createSampleData()
        return dataController
    }()
    
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
}
