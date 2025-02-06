//
//  PlateImageView.swift
//  MyPlates
//
//  Created by Tatyana Buinitskaya on 28.01.2025.
//

import SwiftUI

/// A view that displays the image for a plate, with support for loading from both CloudKit and local storage.
struct PlateImageView: View {
    /// The environment object that provides data for the plate.
    @EnvironmentObject var dataController: DataController
    /// The observed plate object that holds the data for the specific plate.
    @ObservedObject var plate: Plate
    /// The binding to the UIImage that represents the image for the plate.
    /// This binding allows updates to the image from either the CloudKit fetch or local fetch.
    @Binding var imagePlateView: UIImage?
    /// A system image name used as a placeholder when the plate image is not available.
    /// Default value is "fork.knife.circle.fill" to signify a plate-related icon.
    var placeholderIcon: String = "fork.knife.circle.fill"
    /// The background color of the placeholder image when the plate image is not available.
    var backgroundColor: Color = .blue
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
                    .foregroundColor(.white)
                    .padding()
                    .background(backgroundColor)
                    .frame(maxWidth: maxWidth, maxHeight: maxHeight)
                    .clipShape(Rectangle())
            }
        }
        .accessibilityIdentifier("plateView") 
        .onAppear {
            // Fetches the image when the view appears if it's not already loaded.
            fetchImage()
        }
    }

    /// Fetches the image for the plate from CloudKit or local storage.
    /// This method ensures that the image is only fetched once when needed.
    /// - It first tries to fetch the image from CloudKit using the `cloudRecordID`.
    /// - If CloudKit fails or the `cloudRecordID` is unavailable, it tries to load the image from local storage.
   func fetchImage() {
           // Only fetch image if it's not already loaded
           if imagePlateView == nil {
               Task {
                   // Fetches image from CloudKit if the plate has a `cloudRecordID`.
                   if let cloudRecordID = plate.cloudRecordID {
                       if let fetchedImage = await dataController.fetchImageFromCloudKit(recordID: cloudRecordID) {
                           // Successfully fetched image from CloudKit.
                           imagePlateView = fetchedImage
                           return // Exit if image fetched from CloudKit
                       } else {
                           print("Failed to fetch image from CloudKit. Attempting local load...")
                       }
                   }
                   // If CloudKit fetch fails or there is no `cloudRecordID`, attempts to load from local storage.
                   if let localPath = plate.photo {
                       if let localImage = dataController.fetchImageFromFileSystem(imagePath: localPath) {
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
       }
   }
