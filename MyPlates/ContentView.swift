//
//  ContentView.swift
//  MyPlates
//
//  Created by Tatyana Buinitskaya on 19.12.2024.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        
            Text("Content")
       
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
