//
//  ContentView.swift
//  MyPlates
//
//  Created by Tatyana Buinitskaya on 19.12.2024.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var dataController: DataController
    
    var plates: [Plate] {
        let filter = dataController.selectedFilter ?? .all
        var allPlates: [Plate]

        if let tag = filter.tag {
            allPlates = tag.plates?.allObjects as? [Plate] ?? []
        } else {
            let request = Plate.fetchRequest()
          //  request.predicate = NSPredicate(format: "date > %@", filter.minModificationDate as NSDate)
            request.predicate = NSPredicate(format: "modificationDate > %@", filter.minModificationDate as NSDate)

            
            
            allPlates = (try? dataController.container.viewContext.fetch(request)) ?? []
        }
        return allPlates.sorted()
    }
 
    
    var body: some View {
        
        List(selection: $dataController.selectedPlate) {
            ForEach(plates) { plate in
                PlateBox(plate: plate)
            
                    }
            .onDelete(perform: delete)
                }
        Button("Print"){
            print(plates)
        }
       
//        List {
//            ForEach(plates) { plate in
//               // Text(plate.platePhoto)
//                if let photoPath = plate.photo {
//                    let imageURL = URL(fileURLWithPath: photoPath)
//                    if let imageData = try? Data(contentsOf: imageURL) {
//                        let image = UIImage(data: imageData)
//                        // Use the image
//                    }
//                }
//            }
//        }
        .navigationTitle("Plates")
       
    }
    func delete(_ offsets: IndexSet) {
        for offset in offsets {
            let item = plates[offset]
            dataController.delete(item)
        }
    }
}

#Preview {
    ContentView()
}

//if let image = UIImage(named: "example"),
//   let imageData = image.jpegData(compressionQuality: 1.0) {
//    entity.photo = imageData
//    try? context.save()
//}
//
//if let imageData = entity.photo,
//   let image = UIImage(data: imageData) {
//    // Use the UIImage
//}
//n the Core Data model editor, select the Binary Data attribute and enable Allows External Storage.
//This ensures Core Data will store the data outside the persistent store if it's large, reducing the database's size.



//// Save image to disk
//if let image = UIImage(named: "example"),
//   let imageData = image.jpegData(compressionQuality: 1.0) {
//    let fileURL = FileManager.default.temporaryDirectory.appendingPathComponent("image.jpg")
//    try? imageData.write(to: fileURL)
//    entity.imagePath = fileURL.path // Save the file path in Core Data
//    try? context.save()
//}
//
//// Retrieve image from disk
//if let imagePath = entity.imagePath,
//   let imageData = FileManager.default.contents(atPath: imagePath) {
//    let image = UIImage(data: imageData)
//}
