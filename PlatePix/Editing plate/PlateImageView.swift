//
//  PlateImageView.swift
//  PlatePix
//
//  Created by Tatyana Buinitskaya on 28.01.2025.
//

import SwiftUI
import CloudKit

/// A view that displays the image for a plate, with support for loading from both CloudKit and local storage.
struct PlateImageView: View {
    /// The environment object that provides data for the plate.
    @EnvironmentObject var dataController: DataController
    /// An environment variable that manages the app's selected color.
    @EnvironmentObject var colorManager: AppColorManager
    /// The observed plate object that holds the data for the specific plate.
    @ObservedObject var plate: Plate
    /// Default value is "fork.knife.circle.fill" to signify a plate-related icon.
    var placeholderIcon: String = "fork.knife.circle.fill"
    /// The maximum width that the plate image will occupy.
    /// This ensures that the image adapts to the screen size.
    var maxWidth: CGFloat = UIScreen.main.bounds.width * 1
    /// The maximum height that the plate image will occupy.
    /// This restricts the image size, ensuring it does not grow too large.
    var maxHeight: CGFloat = 600
    
    var body: some View {
        VStack {

            var resolvedImage: UIImage? {

                let key = plate.objectID.uriRepresentation().absoluteString

                if let cached = ImageCache.shared.object(forKey: key as NSString) {
                    return cached
                }

                if let path = plate.photo,
                   let image = fetchImageFromFileSystem(imagePath: path) {

                    ImageCache.shared.setObject(image, forKey: key as NSString)
                    return image
                }

                return nil
            }
            if let image = resolvedImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: maxWidth, maxHeight: maxHeight)
                    .clipShape(Rectangle())
            } else {
                Image(systemName: placeholderIcon)
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(.white)
                    .padding()
                    .background(colorManager.selectedColor.color)
                    .frame(maxWidth: maxWidth, maxHeight: maxHeight)
                    .clipShape(Rectangle())
            }
        }
        .task(id: "\(plate.cloudRecordID ?? "")\(plate.photo ?? "")") {
            guard let cloudID = plate.cloudRecordID else { return }

                if let fileName = plate.photo {

                    let documentsURL = FileManager.default
                        .urls(for: .documentDirectory, in: .userDomainMask)
                        .first!

                    let fileURL = documentsURL.appendingPathComponent(fileName)

                    if FileManager.default.fileExists(atPath: fileURL.path) {
                        return
                    }
                }

                print("DOWNLOADING FROM CLOUDKIT:", cloudID)

                guard let image = await fetchImageFromCloudKit(recordID: cloudID) else {
                    print("DOWNLOAD FAILED")
                    return
                }


            guard let localPath = saveImageToFileSystem2(image: image) else {
                return
            }

            await MainActor.run {
                plate.photo = localPath
                dataController.save()
            }
        }
        .accessibilityIdentifier("plateView")
                   }
        
    

    /// Fetches an image from CloudKit for a given record ID.
    /// The method retrieves a `CKRecord`, extracts the `imageData` asset,
    /// loads the image data from its file URL, and converts it into a `UIImage`.
    /// - Parameter recordID: The CloudKit record identifier.
    /// - Returns: A `UIImage` if the image exists and can be loaded, otherwise `nil`.
    func fetchImageFromCloudKit(recordID: String) async -> UIImage? {

        let ckID = CKRecord.ID(recordName: recordID)
        let db = CKContainer.default().privateCloudDatabase

        do {
            let record = try await db.record(for: ckID)

            guard let asset = record["imageData"] as? CKAsset,
                  let url = asset.fileURL else {
                return nil
            }

            let data = try Data(contentsOf: url)
            return UIImage(data: data)

        } catch {
            print("CloudKit fetch error:", error)
            return nil
        }
    }
    
    /// Loads an image from the local file system using a stored image path.
    /// The method resolves the file path inside the app's documents directory,
    /// checks if the file exists, and loads it as a `UIImage`.
    /// - Parameter imagePath: File name or full image path string.
    /// - Returns: A `UIImage` if the file exists and can be loaded, otherwise `nil`.
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
    
    
    /// Saves a `UIImage` to the app's Documents directory as a JPEG file.
    /// The image is compressed and written to disk using a generated UUID filename.
    /// - Parameter image: The image to save.
    /// - Returns: The generated file name if saving succeeds, otherwise `nil`.
    func saveImageToFileSystem2(image: UIImage) -> String? {

        let photoDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!

        let photoName = UUID().uuidString + ".jpg"
        let photoURL = photoDirectory.appendingPathComponent(photoName)

        if let imageData = image.jpegData(compressionQuality: 0.8) {
            try? imageData.write(to: photoURL)
            return photoName
        }

        return nil
    }
}
