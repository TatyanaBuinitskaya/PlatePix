//
//  PlateImageView.swift
//  MyPlates
//
//  Created by Tatyana Buinitskaya on 28.01.2025.
//

import SwiftUI

struct PlateImageView: View {
    @EnvironmentObject var dataController: DataController
    @ObservedObject var plate: Plate
    @Binding var imagePlateView: UIImage?
    var placeholderIcon: String = "fork.knife.circle.fill"
    var backgroundColor: Color = .blue
    var maxWidth: CGFloat = UIScreen.main.bounds.width * 1
    var maxHeight: CGFloat = 600
    var body: some View {
        VStack {
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
        .onAppear {
            fetchImage()
        }
    }
   func fetchImage() {
           // Only fetch image if it's not already loaded
           if imagePlateView == nil {
               Task {
                   if let cloudRecordID = plate.cloudRecordID {
                       if let fetchedImage = await dataController.fetchImageFromCloudKit(recordID: cloudRecordID) {
                           imagePlateView = fetchedImage
                           return // Exit if image fetched from CloudKit
                       } else {
                           print("Failed to fetch image from CloudKit. Attempting local load...")
                       }
                   }
                   // If CloudKit fails or no `cloudRecordID`, try loading from local storage
                   if let localPath = plate.photo {
                       if let localImage = dataController.fetchImageFromFileSystem(imagePath: localPath) {
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
