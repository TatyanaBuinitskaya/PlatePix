//
//  PlateBox.swift
//  MyPlates
//
//  Created by Tatyana Buinitskaya on 23.12.2024.
//

import SwiftUI

struct PlateBox: View {
    @EnvironmentObject var dataController: DataController
    @ObservedObject var plate: Plate
    @State var imagePlateView: UIImage?
    
    var body: some View {
        VStack(spacing: 3) {
            Group{
                if let image = imagePlateView {
                    // Display the fetched or cached image
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(maxWidth: 200, maxHeight: 300)
                        .clipped()
                } else {
                    // Placeholder while fetching the image
                    Image(systemName: "fork.knife.circle.fill")
                        .resizable()
                        .scaledToFill()
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue)
                        .frame(maxWidth: 200, maxHeight: 300)
                        .clipShape(Rectangle())
                        .onAppear {
                            Task {
                                if let cloudRecordID = plate.cloudRecordID {
                                    // Try fetching from CloudKit
                                    if let fetchedImage = await dataController.fetchImageFromCloudKit(recordID: cloudRecordID) {
                                        imagePlateView = fetchedImage
                                    } else {
                                        print("Failed to fetch image from CloudKit. Attempting local load...")
                                    }
                                }
                                // If no CloudKit record or fetch failed, attempt to load locally
                                if imagePlateView == nil, let photoPath = plate.photo {
                                    if let localImage = dataController.fetchImageFromFileSystem(imagePath: photoPath) {
                                        imagePlateView = localImage
                                    } else {
                                        print("Failed to load image from local path: \(photoPath)")
                                    }
                                }
                            }
                        }
                }
            }
            .overlay{
                if dataController.showMealTime || dataController.showQuality {
                    VStack {
                        HStack{
                            if dataController.showMealTime {
                                HStack {
                                    if let displayMealtime = dataController.mealtimeDictionary[plate.plateMealtime] {
                                        Text(displayMealtime) // Show the user-friendly title
                                            .font(.footnote)
                                            .foregroundColor(.white)
                                    } else {
                                        Text("Unknown") // Fallback if no match is found
                                            .font(.footnote)
                                            .foregroundColor(.white)
                                    }
                                    Text(plate.plateCreationDate.formatted(date: .omitted, time: .shortened))
                                        .font(.footnote)
                                        .foregroundColor(.white)
                                }
                            }
                            
                            if dataController.showQuality {
                                Spacer()
                                Image(systemName: "star.fill")
                                    .foregroundColor(plate.quality == 0 ? .red : plate.quality == 1 ? .yellow : .green)
                                    .font(.subheadline)
                            }
                        }
                        .padding(.horizontal, 3)
                        .padding(3)
                        .background(dataController.showMealTime ? Color.black.opacity(0.5) : Color.white.opacity(0.0))
                        Spacer() // Pushes the content to the bottom
                        if dataController.showTags {
                            Text(plate.tags?.allObjects.compactMap { ($0 as? Tag)?.tagName }.joined(separator: ", ") ?? "No Tags")
                                .font(.footnote)
                                .foregroundColor(.white)
                                .background(Color.black.opacity(0.5))
                        }
                    }
                }
            }
            .frame(maxWidth: 200, maxHeight: 300)
        }
        .background(
            Rectangle()
                .stroke(Color.gray.opacity(0.5), lineWidth: 1) // Gray stroke
        )
    }
}




#Preview {
    PlateBox(plate: .example)
}
