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
    /// The binding to the UIImage that represents the image for the plate.
    /// This binding allows updates to the image from either the CloudKit fetch or local fetch.
    @Binding var imagePlateView: UIImage?
    /// A system image name used as a placeholder when the plate image is not available.
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
            // The conditional ensures that either the actual image or a placeholder is shown.
            if let image = imagePlateView {
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
        .accessibilityIdentifier("plateView") 
        .onAppear {
            // Fetches the image when the view appears if it's not already loaded.
            fetchImage()
        }
        .onChange(of: plate.platePhoto){
            fetchImage()
        }
    }

    /// Fetches the image for the plate from CloudKit or local storage.
    /// This method ensures that the image is only fetched once when needed.
    /// - It first tries to fetch the image from CloudKit using the `cloudRecordID`.
    /// - If CloudKit fails or the `cloudRecordID` is unavailable, it tries to load the image from local storage.
    func fetchImage() {
        // Only fetch image if it's not already loaded
            Task {
                // Fetches image from CloudKit if the plate has a `cloudRecordID`.
                if let cloudRecordID = plate.cloudRecordID {
                    if let fetchedImage = await fetchImageFromCloudKit(recordID: cloudRecordID) {
                        // Successfully fetched image from CloudKit.
                        imagePlateView = fetchedImage
                        return // Exit if image fetched from CloudKit
                    } else {
                        print("Failed to fetch image from CloudKit. Attempting local load...")
                    }
                }
                // If CloudKit fetch fails or there is no `cloudRecordID`, attempts to load from local storage.
                if let localPath = plate.photo {
                    if let localImage = fetchImageFromFileSystem(imagePath: localPath) {
                        // Successfully fetched image from local storage.
                        imagePlateView = localImage
                    } else {
                        print("Failed to load image from local storage.")
                    }
                } else {
                    print("No CloudKit record ID or local photo path available.")
                }
            }
    }

    /// Fetches an image from CloudKit using the provided record ID.
    /// - Parameter recordID: The CloudKit record ID of the image.
    /// - Returns: The fetched image, or nil if the operation failed.
    /// - Note: The image is fetched as a CKAsset and then converted back into a UIImage.
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

    /// Fetches an image from the local filesystem using the given image path.
    /// - Parameter imagePath: The path of the image to be fetched.
    /// - Returns: The fetched image, or nil if the image is not found.
    /// - Note: The method attempts to find the image file within the app's document directory.
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
}
