//
//  ContentView.swift
//  MyPlates
//
//  Created by Tatyana Buinitskaya on 19.12.2024.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var dataController: DataController
    
    var body: some View {
        
        List(selection: $dataController.selectedPlate) {
            ForEach(dataController.platesForSelectedFilter()) { plate in
                PlateBox(plate: plate)
            
                    }
            .onDelete(perform: delete)
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
        .searchable(text: $dataController.filterText, tokens: $dataController.filterTokens, suggestedTokens: .constant(dataController.suggestedFilterTokens), prompt: "Filter issues, or type # to add tags") { tag in
            Text(tag.tagName)
        }
        .toolbar {
            Menu {
                Button(dataController.filterEnabled ? "Turn Filter Off" : "Turn Filter On") {
                    dataController.filterEnabled.toggle()
                }

                Divider()

                Menu("Sort By") {
                    Picker("Sort By", selection: $dataController.sortType) {
                        Text("Date Created").tag(SortType.dateCreated)
                        Text("Date Modified").tag(SortType.dateModified)
                    }

                    Divider()

                    Picker("Sort Order", selection: $dataController.sortNewestFirst) {
                        Text("Newest to Oldest").tag(true)
                        Text("Oldest to Newest").tag(false)
                    }
                }

                Picker("Status", selection: $dataController.filterStatus) {
                    Text("All").tag(Status.all)
                    Text("Missed").tag(Status.missed)
                    Text("Completed").tag(Status.done)
                }
                .disabled(dataController.filterEnabled == false)

                Picker("Meal quality", selection: $dataController.filterQuality) {
                    Text("All").tag(-1)
                    Text("Bad").tag(0)
                    Text("Ok").tag(1)
                    Text("Greate").tag(2)
                }
                .disabled(dataController.filterEnabled == false)
            } label: {
                Label("Filter", systemImage: "line.3.horizontal.decrease.circle")
                Label("Filter", systemImage: "line.3.horizontal.decrease.circle")
                    .symbolVariant(dataController.filterEnabled ? .fill : .none)
            }
            
            Button(action: dataController.newPlate) {
                Label("New plate", systemImage: "square.and.pencil")
            }
        }

    }
    
    func delete(_ offsets: IndexSet) {
        let plates = dataController.platesForSelectedFilter()

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
