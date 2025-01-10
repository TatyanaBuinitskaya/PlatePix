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
        // for list navigationLink
        //  NavigationLink(value: plate){
        ZStack{
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(radius: 10)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                )
            
            VStack(alignment: .leading, spacing: 3) {
                Text(plate.plateTagList)
                    .font(.title3)

                Group {
                    if let image = imagePlateView {
                        // Display the fetched or cached image
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(maxWidth: 200, maxHeight: 200)
                            .clipped()
                    } else {
                        // Placeholder while fetching the image
                        Image(systemName: "photo")
                            .resizable()
                            .scaledToFill()
                            .frame(maxWidth: 200, maxHeight: 200)
                            .clipped()
                            .foregroundColor(.secondary)
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
                
                HStack{
                    Text(plate.plateCreationDate.formatted(date: .omitted, time: .shortened))
                        .font(.subheadline)
                    Spacer()
                    Image(systemName: "star.fill")
                        .foregroundColor(plate.quality == 0 ? .red : plate.quality == 1 ? .yellow : .green)
                }
                .frame(maxWidth: 200, maxHeight: 200)
                Text(plate.plateNotes)
            }
            .padding(10)
        }
        .frame(maxWidth: 250, maxHeight: 300)
    }
   
}




#Preview {
    PlateBox(plate: .example)
}
