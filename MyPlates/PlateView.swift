//
//  PlateView.swift
//  MyPlates
//
//  Created by Tatyana Buinitskaya on 23.12.2024.
//

import PhotosUI
import SwiftUI

struct PlateView: View {
    @EnvironmentObject var dataController: DataController
    @ObservedObject var plate: Plate
    @Environment(\.dismiss) var dismiss
    @FetchRequest(sortDescriptors: [SortDescriptor(\.name)]) var tags: FetchedResults<Tag>
    @State private var pickerItems = [PhotosPickerItem]()
    @State private var imagePlateView: UIImage?
    @State private var isCameraPresented = false
    @State private var showICloudUnavailableAlert = false
    @State private var isPlateDeleted = false
    @State private var showTagList = false
    var body: some View {
        VStack {
            if isPlateDeleted {
                Text("This plate has been deleted")
                    .foregroundColor(.red)
            } else {
                ZStack {
                    ScrollView {
                        VStack {
                            HStack {
                                plateMealtimeView
                                Spacer()
                                plateQualityView
                            }
                            PlateImageView(
                                plate: plate,
                                imagePlateView: $imagePlateView,
                                maxWidth: UIScreen.main.bounds.width * 1, // Larger size
                                maxHeight: 600
                            )
                            .onTapGesture {
                                isCameraPresented = true
                            }
                            plateTagView
                            Divider()
                            plateNotesView
                            Spacer()
                        }
                        .padding(.horizontal)
                    }
                    cameraAndLibraryButtonsView
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .padding(.vertical)
        .navigationTitle($plate.plateTitle)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if dataController.checkAwards() {
                dataController.showCongratulations = true
            }
        }
        .onChange(of: plate) {
            isPlateDeleted = false
        }
        .onReceive(plate.objectWillChange) { _ in
            dataController.queueSave()
        }
        .onSubmit(dataController.save)
        .sheet(isPresented: $isCameraPresented) {
            ImagePicker(sourceType: .camera) { image in
                saveImageFromCamera(image: image)
            }
        }
        .sheet(isPresented: $dataController.showCongratulations) {
            AwardSheetView()
        }
        .toolbar {
            plateToolbar
        }
    }
    private var plateMealtimeView: some View {
        HStack {
            Image(systemName: "clock")
                .font(.title2)
            Menu {
                Picker("Mealtime", selection: $plate.mealtime) {
                    ForEach(dataController.mealtimeDictionary.keys.sorted(), id: \.self) { key in
                        Text(dataController.mealtimeDictionary[key] ?? key)
                            .tag(key)
                    }
                }
            } label: {
                let mealtime = plate.mealtime ?? ""
                if let selectedMealtime = dataController.mealtimeDictionary[mealtime] {
                    Text(selectedMealtime)
                        .font(.title3)
                } else {
                    Text("Select Mealtime")
                        .font(.title3)
                }
            }
        }
    }
    private var plateQualityView: some View {
        HStack {
            Image(systemName: "star.fill")
                .foregroundColor(plate.quality == 0 ? .red : plate.quality == 1 ? .yellow : .green)
                .font(.title2)
            Menu {
                Picker("Meal Quality", selection: $plate.quality) {
                    Text("Unhealthy").tag(Int16(0))
                    Text("Moderate").tag(Int16(1))
                    Text("Healthy").tag(Int16(2))
                }
            } label: {
                Text(plate.quality == 0 ? "Unhealthy" : plate.quality == 1 ? "Moderate" : "Healthy")
                    .font(.title3)
            }
        }
    }
    private var plateTagView: some View {
        VStack(alignment: .leading) {
            HStack {
                Button {
                    showTagList = true
                } label: {
                    Image(systemName: "tag")
                    Text("Select Food tag")
                        .font(.title3)
                }
                Spacer()
            }
            Text(plate.tags?.allObjects.compactMap { ($0 as? Tag)?.tagName }.joined(separator: ", ") ?? "No Tags")
        }
        .sheet(isPresented: $showTagList) {
            TagListView(plate: plate)
        }
    }
    private var plateNotesView: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Notes:")
                    .font(.title3)
            }
            TextField(
                "Enter the plate description here",
                text: $plate.plateNotes,
                axis: .vertical
            )
            .padding(8)
            .frame(maxWidth: .infinity, minHeight: 100, maxHeight: 150, alignment: .top) // Scales for larger devices
            .background(Color.white)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
            )
        }
    }
    private var cameraAndLibraryButtonsView: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                PhotosPicker(selection: $pickerItems, maxSelectionCount: 1, matching: .images) {
                    Image(systemName: "photo.stack")
                        .font(.title2)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue)
                        .clipShape(Circle())
                        .shadow(radius: 5)
                }
                .padding(.horizontal)
                .onChange(of: pickerItems) {
                    handleImageSelection()
                }
                Button {
                    isCameraPresented = true
                } label: {
                    Image(systemName: "camera")
                        .font(.title2)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue)
                        .clipShape(Circle())
                        .shadow(radius: 5)
                }
            }
            .padding(.horizontal)
        }
    }
    private var plateToolbar: some View {
        Button {
            dataController.delete(plate)
            isPlateDeleted = true
            dismiss()
        } label: {
            Image(systemName: "trash")
                .foregroundColor(.red)
        }
    }
    func saveImageFromCamera(image: UIImage) {
        let normalizedImage = image.fixedOrientation() // Correct orientation
        if let croppedImage = cropToSquare(image: normalizedImage) {
            let imageName = UUID().uuidString
            Task {
                do {
                    // Attempt to save the image to CloudKit
                    if let cloudRecordID = await dataController.saveImageToCloudKit(
                        image: croppedImage,
                        imageName: imageName
                    ) {
                        plate.cloudRecordID = cloudRecordID.recordName
                        plate.photo = imageName
                        imagePlateView = croppedImage
                    } else {
                        throw NSError(domain: "CloudKitSave", code: -1, userInfo: nil)
                    }
                } catch {
                    print("CloudKit save failed, attempting local save: \(error)")
                    if let localPath = dataController.saveImageToFileSystem(image: croppedImage) {
                        plate.photo = localPath
                        imagePlateView = croppedImage
                    } else {
                        print("Failed to save image locally.")
                    }
                }
                dataController.save()
            }
        }
    }
    func cropToSquare(image: UIImage) -> UIImage? {
        let imageWidth = image.size.width
        let imageHeight = image.size.height
        let sideLength = min(imageWidth, imageHeight)
        let xOffset = (imageWidth - sideLength) / 2
        let yOffset = (imageHeight - sideLength) / 2
        let cropRect = CGRect(x: xOffset, y: yOffset, width: sideLength, height: sideLength)
        guard let cgImage = image.cgImage?.cropping(to: cropRect) else {
            return nil
        }
        return UIImage(cgImage: cgImage)
    }
    func handleImageSelection() {
        guard let item = pickerItems.first else { return }
        Task {
            if let data = try? await item.loadTransferable(type: Data.self),
               let image = UIImage(data: data) {
                let normalizedImage = image.fixedOrientation() // Correct orientation
                if let croppedImage = cropToSquare(image: normalizedImage) {
                    let imageName = UUID().uuidString
                    do {
                        if let recordID = await dataController.saveImageToCloudKit(
                            image: croppedImage,
                            imageName: imageName
                        ) {
                            plate.cloudRecordID = recordID.recordName
                            plate.photo = imageName
                            imagePlateView = croppedImage
                        } else {
                            throw NSError(domain: "CloudKitSave", code: -1, userInfo: nil)
                        }
                    } catch {
                        print("CloudKit save failed, attempting local save: \(error)")
                        if let localPath = dataController.saveImageToFileSystem(image: croppedImage) {
                            plate.photo = localPath
                            imagePlateView = croppedImage
                        } else {
                            print("Failed to save image locally.")
                        }
                    }
                    dataController.save()
                }
            }
        }
    }
}

#Preview {
    PlateView(plate: .example)
        .environmentObject(DataController.preview)
}
