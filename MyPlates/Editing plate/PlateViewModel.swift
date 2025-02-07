//
//  PlateViewModel.swift
//  MyPlates
//
//  Created by Tatyana Buinitskaya on 07.02.2025.
//

import Foundation
import UIKit
import CloudKit
import _PhotosUI_SwiftUI

//extension PlateView {
//  //  @dynamicMemberLookup
//    class ViewModel: ObservableObject {
//        var dataController: DataController
//        var plate: Plate
//        //    /// The image to display for the plate.
//        @Published var imagePlateView: UIImage?
//        /// A list of selected photo picker items.
//        @Published var pickerItems = [PhotosPickerItem]()
//
//        init(plate: Plate, dataController: DataController) {
//            self.dataController = dataController
//            self.plate = plate
//        }
////        subscript<Value>(dynamicMember keyPath: KeyPath<Plate, Value>) -> Value {
////           plate[keyPath: keyPath]
////        }
//        
//        /// Saves an image to the local filesystem.
//            /// - Parameter image: The image to be saved.
//            /// - Returns: The file path where the image was saved, or nil if the save failed.
//            /// - Note: The image is saved as a JPEG with 80% quality compression.
//        func saveImageToFileSystem(image: UIImage) -> String? {
//            let photoDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
//            let photoName = UUID().uuidString + ".jpg"
//            let photoURL = photoDirectory.appendingPathComponent(photoName)
//            if let imageData = image.jpegData(compressionQuality: 0.8) {
//                do {
//                    try imageData.write(to: photoURL)
//                    print("Image successfully saved at path: \(photoURL.path)")
//                    return photoURL.path
//                } catch {
//                    print("Error saving image: \(error.localizedDescription)")
//                }
//            } else {
//                print("Failed to generate JPEG data for the image.")
//            }
//            return nil
//        }
//
//        /// Saves an image to CloudKit.
//            /// - Parameters:
//            ///   - image: The image to be saved.
//            ///   - imageName: The name for the image file.
//            /// - Returns: The CloudKit record ID of the saved record, or nil if the operation failed.
//            /// - Note: The image is temporarily saved to the local filesystem before uploading to CloudKit to create a CKAsset.
//        func saveImageToCloudKit(image: UIImage, imageName: String) async -> CKRecord.ID? {
//            // Convert UIImage to Data (JPEG format)
//            guard let imageData = image.jpegData(compressionQuality: 0.8) else {
//                print("Failed to convert image to JPEG data.")
//                return nil
//            }
//            // Save the image data locally before uploading to CloudKit (in a temporary directory)
//            let fileManager = FileManager.default
//            let temporaryDirectoryURL = fileManager.temporaryDirectory
//            let fileURL = temporaryDirectoryURL.appendingPathComponent(imageName).appendingPathExtension("jpg")
//            do {
//                // Write the image data to the file URL
//                try imageData.write(to: fileURL)
//                // Create a CKAsset from the image file URL
//                let imageAsset = CKAsset(fileURL: fileURL)
//                // Create a CloudKit record to save the asset
//                let record = CKRecord(recordType: "Plate") // Adjust the record type as needed
//                record["imageData"] = imageAsset
//                // Save the record to CloudKit's private database
//                let container = CKContainer.default()
//                let privateDatabase = container.privateCloudDatabase
//                // Save the record and await the result
//                let savedRecord = try await privateDatabase.save(record)
//                // Clean up the local file after uploading it to CloudKit
//                try fileManager.removeItem(at: fileURL)
//                // Return the recordID of the saved record
//                return savedRecord.recordID
//            } catch {
//                print("Error saving image to CloudKit: \(error.localizedDescription)")
//                return nil
//            }
//        }
//
//        /// Saves an image captured from the camera.
//        /// - Parameter image: The image captured from the camera.
//        func saveImageFromCamera(image: UIImage) {
//            let normalizedImage = image.fixedOrientation() // Correct orientation
//            if let croppedImage = cropToSquare(image: normalizedImage) {
//                let imageName = UUID().uuidString
//                Task {
//                    do {
//                        // Attempt to save the image to CloudKit
//                        if let cloudRecordID = await saveImageToCloudKit(
//                            image: croppedImage,
//                            imageName: imageName
//                        ) {
//                            plate.cloudRecordID = cloudRecordID.recordName
//                            plate.photo = imageName
//                            imagePlateView = croppedImage
//                        } else {
//                            throw NSError(domain: "CloudKitSave", code: -1, userInfo: nil)
//                        }
//                    } catch {
//                        print("CloudKit save failed, attempting local save: \(error)")
//                        if let localPath = saveImageToFileSystem(image: croppedImage) {
//                            plate.photo = localPath
//                            imagePlateView = croppedImage
//                        } else {
//                            print("Failed to save image locally.")
//                        }
//                    }
//                    dataController.save()
//                }
//            }
//        }
//
//        /// Crops an image to a square format.
//        /// - Parameter image: The image to be cropped.
//        /// - Returns: A square-cropped version of the image, if successful.
//        func cropToSquare(image: UIImage) -> UIImage? {
//            let imageWidth = image.size.width
//            let imageHeight = image.size.height
//            let sideLength = min(imageWidth, imageHeight)
//            let xOffset = (imageWidth - sideLength) / 2
//            let yOffset = (imageHeight - sideLength) / 2
//            let cropRect = CGRect(x: xOffset, y: yOffset, width: sideLength, height: sideLength)
//            guard let cgImage = image.cgImage?.cropping(to: cropRect) else {
//                return nil
//            }
//            return UIImage(cgImage: cgImage)
//        }
//
//        /// Handles the selection of images from the photo library.
//        func handleImageSelection() {
//            guard let item = pickerItems.first else { return }
//            Task {
//                if let data = try? await item.loadTransferable(type: Data.self),
//                   let image = UIImage(data: data) {
//                    let normalizedImage = image.fixedOrientation() // Correct orientation
//                    if let croppedImage = cropToSquare(image: normalizedImage) {
//                        let imageName = UUID().uuidString
//                        do {
//                            if let recordID = await saveImageToCloudKit(
//                                image: croppedImage,
//                                imageName: imageName
//                            ) {
//                                plate.cloudRecordID = recordID.recordName
//                                plate.photo = imageName
//                                imagePlateView = croppedImage
//                            } else {
//                                throw NSError(domain: "CloudKitSave", code: -1, userInfo: nil)
//                            }
//                        } catch {
//                            print("CloudKit save failed, attempting local save: \(error)")
//                            if let localPath = saveImageToFileSystem(image: croppedImage) {
//                                plate.photo = localPath
//                                imagePlateView = croppedImage
//                            } else {
//                                print("Failed to save image locally.")
//                            }
//                        }
//                        dataController.save()
//                    }
//                }
//            }
//        }
//    }
//}
