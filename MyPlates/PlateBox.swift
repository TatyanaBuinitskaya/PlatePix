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
        
        
//        ZStack{
//            RoundedRectangle(cornerRadius: 10)
//                .fill(Color.white)
//                .shadow(radius: 5, x: 3, y: 3)
//                .overlay(
//                    RoundedRectangle(cornerRadius: 10)
//                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
//                )
            
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
                                Spacer() // Pushes the content to the bottom
                                HStack{
                                    if dataController.showMealTime {
                                        HStack {
                                            Text(plate.plateTagList)
                                                .font(.subheadline)
                                                .foregroundColor(.black)
                                            Text(plate.plateCreationDate.formatted(date: .omitted, time: .shortened))
                                                .font(.subheadline)
                                                .foregroundColor(.black)
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
                                .background(dataController.showMealTime ? Color.white.opacity(0.5) : Color.white.opacity(0.0))
                            }
                        }
                    }
                    .frame(maxWidth: 200, maxHeight: 300)
                
                if dataController.showNotes {
                       VStack(alignment: .leading, spacing: 5) {
                           Text(plate.notes ?? "No notes")
                               .foregroundColor(.black)
                               .font(.caption2)
                               .lineLimit(5) // Limits the number of lines to 3
                               .minimumScaleFactor(0.5)
                               .frame(maxWidth: .infinity, minHeight: 50, maxHeight: 50, alignment: .topLeading)
                       }
                   }
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
