//
//  PlateView.swift
//  PlatePix
//
//  Created by Tatyana Buinitskaya on 23.12.2024.
//

import PhotosUI
import SwiftUI
import CloudKit
import Combine

/// A view that displays detailed information about a specific plate.
struct PlateView: View {
    /// The data controller responsible for managing Core Data and related operations.
    @EnvironmentObject var dataController: DataController
    /// The plate object being displayed and edited.
    @ObservedObject var plate: Plate
    /// The environment property used to dismiss the current view..
    @Environment(\.dismiss) var dismiss
    /// An environment variable that manages the app's selected color.
    @EnvironmentObject var colorManager: AppColorManager
    /// The fetched results of tags, sorted by name.
    @FetchRequest(sortDescriptors: [SortDescriptor(\.name)]) var tags: FetchedResults<Tag>
    /// A list of selected photo picker items.
    @State var pickerItems = [PhotosPickerItem]()
    /// The image to display for the plate.
    @State var imagePlateView: UIImage?
    /// A Boolean value that tracks whether the camera view is presented.
    @State private var isCameraPresented = false
    /// A Boolean value indicating if iCloud is unavailable.
    @State private var showICloudUnavailableAlert = false
    /// A Boolean value that tracks whether the tag selection view is presented.
    @State private var showTagList = false
    /// A flag indicating whether the congratulations screen should be shown.
    @State var showCongratulations: Bool = false

    var body: some View {
        VStack {
                ZStack {
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
                            .padding(.vertical, 10)

                            plateTagView
                            Divider()
                            plateNotesView
                        }
                        .padding(.horizontal)
                        .onTapGesture {
                            hideKeyboard()
                        }
                    cameraAndLibraryButtonsView
                }
        }
        .padding(.vertical)
        .navigationTitle(NSLocalizedString("Plate", comment: "") + " - " + plate.plateTitle)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                if let newAward = dataController.checkForNewAward() {
                    print("New award earned: \(newAward.name)")
                    showCongratulations = true
                }
            }
        }
        .onChange(of: dataController.plateCount) {
            // Check for a new award
            if let newAward = dataController.checkForNewAward() {
                print("New award earned: \(newAward.name)")
                showCongratulations = true
            }
        }
        .onReceive(plate.objectWillChange) { _ in
            dataController.queueSave()
        }
        .onReceive(NotificationCenter.default.publisher(for: NSUbiquitousKeyValueStore.didChangeExternallyNotification)) { _ in
            NSUbiquitousKeyValueStore.default.synchronize()
        }
        .onSubmit(dataController.save)
        .sheet(isPresented: $isCameraPresented) {
            ImagePicker(sourceType: .camera) { image in
                saveImageFromCamera(image: image)
            }
        }
        .sheet(isPresented: $showCongratulations) {
            AwardSheetView()
        }
        .toolbar {
//            ToolbarItem(placement: .navigationBarLeading) {
//                Button {
//                    dataController.selectedPlate = nil
//                   // dismiss() // Dismiss the current view
//                } label: {
//                    HStack {
//                        Image(systemName: "chevron.left")
//                            .fontWeight(.bold)
//                        Text("Plates") // Back button label
//                    }
//                }
//                .accessibilityIdentifier("Plates") // Add accessibility identifier
//            }
            ToolbarItem(placement: .navigationBarTrailing) {
                plateToolbar // Existing delete button
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    dataController.selectedPlate = nil
                 //   dismiss() // Dismiss the current view
                } label: {
                    HStack {
                        Text("Done") // Back button label
                            .fontWeight(.bold)
                    }
                }
            }
        }
      //  .navigationBarBackButtonHidden(true) // Hide the default back button
    }

    /// Displays the mealtime selection view for the plate.
    private var plateMealtimeView: some View {
        HStack {
            Image(systemName: "clock")
                .font(.title2)
                .foregroundColor(colorManager.selectedColor.color)
            Menu {
                Picker("Mealtime", selection: $plate.mealtime) {
                    ForEach(dataController.mealtimeArray, id: \.self) { mealtime in
                        Text(NSLocalizedString(mealtime, comment: "Mealtime") )
                            .tag(mealtime)
                    }
                }
            } label: {
                let mealtime = plate.mealtime ?? ""
                let selectedMealtime = NSLocalizedString(mealtime, comment: "Mealtime")
                Text(selectedMealtime)
                    .font(.title3)
            }
            .buttonStyle(PlainButtonStyle())        }
    }

    /// Displays the meal quality selection view for the plate.
    private var plateQualityView: some View {
        HStack {
            Image(plate.quality == 0 ? "SadPDF" : (plate.quality == 1 ? "NeutralPDF" : "HappyPDF"))
                .resizable()
                .scaledToFit()
                .foregroundStyle(Color(colorManager.selectedColor.color))
                .frame(width: 23, height: 23)
                .font(.title2)
            Menu {
                Picker("Meal Quality", selection: $plate.quality) {
                    Group {
                        Text("Unhealthy").tag(Int16(0))
                        Text("Moderate").tag(Int16(1))
                        Text("Healthy").tag(Int16(2))
                    }
                }
            } label: {
                Text(plate.quality == 0 ? "Unhealthy" : plate.quality == 1 ? "Moderate" : "Healthy")
                    .font(.title3)
            }
            .buttonStyle(PlainButtonStyle())        }
    }

    /// Displays the tag selection and currently selected tags for the plate.
    private var plateTagView: some View {
        VStack(alignment: .leading) {
            HStack {
                Button {
                    showTagList = true
                } label: {
                    Image(systemName: "tag")
                        .foregroundColor(colorManager.selectedColor.color)
                    Text("Tags")
                        .font(.title3)
                }
                .buttonStyle(PlainButtonStyle())
                Spacer()
            }

            Text(
                plate.tags?.allObjects
                    .compactMap { $0 as? Tag } // Ensure type safety
                    .sorted { firstTag, secondTag in
                        let typePriority: [String] = ["My", "Food", "Emotion", "Reaction"]
                        let firstTypePriority = typePriority.firstIndex(of: firstTag.tagType) ?? Int.max
                        let secondTypePriority = typePriority.firstIndex(of: secondTag.tagType) ?? Int.max

                        if firstTypePriority == secondTypePriority {
                            // Use localized name for sorting based on current locale
                            let firstLocalized = NSLocalizedString(
                                firstTag.tagName,
                                tableName: dataController.tableNameForTagType(firstTag.type),
                                comment: ""
                            )
                            let secondLocalized = NSLocalizedString(
                                secondTag.tagName,
                                tableName: dataController.tableNameForTagType(secondTag.type),
                                comment: ""
                            )

                            return firstLocalized.localizedStandardCompare(secondLocalized) == .orderedAscending
                        }
                        return firstTypePriority < secondTypePriority
                    }
                    .map { tag in
                        NSLocalizedString(
                            tag.tagName,
                            tableName: dataController.tableNameForTagType(tag.type),
                            comment: ""
                        )
                    }
                    .joined(separator: ", ") ?? NSLocalizedString(
                        "No Tags",
                        comment: "Fallback text when no tags are assigned"
                    )
            )
            .fontWeight(.light)
            .padding(.top, 5)
        }
        .sheet(isPresented: $showTagList) {
            TagListView(plate: plate)
        }
    }

    /// Displays the notes section for the plate.
    private var plateNotesView: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .bottom) {
                Image(systemName: "square.and.pencil")
                    .foregroundStyle(colorManager.selectedColor.color)
                    .font(.title3)
                    .offset(y: -2)
                Text("Notes:")
                    .font(.title3)
            }
            Text("text will be searchable")
                .font(.footnote)
                .foregroundStyle(.secondary)
            TextField(plate.plateCreationDate.formatted(date: .abbreviated, time: .omitted), text: $plate.plateNotes, axis: .vertical)
                .padding(8)
                .frame(maxWidth: .infinity, minHeight: 80, maxHeight: 120, alignment: .top)
                .background(Color(uiColor: .systemBackground))
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
                .padding(.bottom, 50)
                .onSubmit {
                    hideKeyboard() // Hide keyboard when the user presses "Done"
                }
                .toolbar {
                    ToolbarItemGroup(placement: .keyboard) {
                        Spacer() // Moves the "Done" button to the right side
                        Button {
                            hideKeyboard() // Hide keyboard when the user taps "Done"
                        } label: {
                            Text("Done")
                                .fontWeight(.bold)
                        }
                    }
                }
        }
    }

    /// Displays the buttons for accessing the camera and photo library.
    private var cameraAndLibraryButtonsView: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                PhotosPicker(selection: $pickerItems, maxSelectionCount: 1, matching: .images) {
                    Image(systemName: "photo.stack")
                        .font(.title2)
                        .foregroundStyle(.white)
                        .padding(13)
                        .background(colorManager.selectedColor.color)
                        .clipShape(Circle())
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
                        .foregroundStyle(.white)
                        .padding(15)
                        .background(colorManager.selectedColor.color)
                        .clipShape(Circle())
                }
            }
            .padding(.horizontal)
        }
    }

    /// Displays the toolbar with actions for the plate.
    private var plateToolbar: some View {
        Button {
            dataController.delete(plate)
            dataController.selectedPlate = nil
        } label: {
            Image(systemName: "trash")
                .foregroundStyle(.red)
        }
    }

    /// Saves an image to the local filesystem.
    /// - Parameter image: The image to be saved.
    /// - Returns: The file path where the image was saved, or nil if the save failed.
    /// - Note: The image is saved as a JPEG with 80% quality compression.
    func saveImageToFileSystem(image: UIImage) -> String? {
        let photoDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let photoName = UUID().uuidString + ".jpg"
        let photoURL = photoDirectory.appendingPathComponent(photoName)
        if let imageData = image.jpegData(compressionQuality: 0.8) {
            do {
                try imageData.write(to: photoURL)
                print("Image successfully saved at path: \(photoURL.path)")
                return photoURL.path
            } catch {
                print("Error saving image: \(error.localizedDescription)")
            }
        } else {
            print("Failed to generate JPEG data for the image.")
        }
        return nil
    }

    /// Saves an image to CloudKit.
    /// - Parameters:
    ///   - image: The image to be saved.
    ///   - imageName: The name for the image file.
    /// - Returns: The CloudKit record ID of the saved record, or nil if the operation failed.
    /// - Note: The image is temporarily saved to the local filesystem before uploading to CloudKit to create a CKAsset.
    func saveImageToCloudKit(image: UIImage, imageName: String) async -> CKRecord.ID? {
        // Convert UIImage to Data (JPEG format)
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            print("Failed to convert image to JPEG data.")
            return nil
        }
        // Save the image data locally before uploading to CloudKit (in a temporary directory)
        let fileManager = FileManager.default
        let temporaryDirectoryURL = fileManager.temporaryDirectory
        let fileURL = temporaryDirectoryURL.appendingPathComponent(imageName).appendingPathExtension("jpg")
        do {
            // Write the image data to the file URL
            try imageData.write(to: fileURL)
            // Create a CKAsset from the image file URL
            let imageAsset = CKAsset(fileURL: fileURL)
            // Create a CloudKit record to save the asset
            let record = CKRecord(recordType: "Plate") // Adjust the record type as needed
            record["imageData"] = imageAsset
            // Save the record to CloudKit's private database
            let container = CKContainer.default()
            let privateDatabase = container.privateCloudDatabase
            // Save the record and await the result
            let savedRecord = try await privateDatabase.save(record)
            // Clean up the local file after uploading it to CloudKit
            try fileManager.removeItem(at: fileURL)
            // Return the recordID of the saved record
            return savedRecord.recordID
        } catch {
            print("Error saving image to CloudKit: \(error.localizedDescription)")
            return nil
        }
    }

    /// Saves an image captured from the camera.
    /// - Parameter image: The image captured from the camera.
    func saveImageFromCamera(image: UIImage) {
        let normalizedImage = image.fixedOrientation() // Correct orientation
        if let croppedImage = cropToSquare(image: normalizedImage) {
            let imageName = UUID().uuidString
            Task {
                do {
                    // Attempt to save the image to CloudKit
                    if let cloudRecordID = await saveImageToCloudKit(
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
                    if let localPath = saveImageToFileSystem(image: croppedImage) {
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

    /// Crops an image to a square format.
    /// - Parameter image: The image to be cropped.
    /// - Returns: A square-cropped version of the image, if successful.
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

    /// Handles the selection of images from the photo library.
    func handleImageSelection() {
        guard let item = pickerItems.first else { return }
        Task {
            if let data = try? await item.loadTransferable(type: Data.self),
               let image = UIImage(data: data) {
                let normalizedImage = image.fixedOrientation() // Correct orientation
                if let croppedImage = cropToSquare(image: normalizedImage) {
                    let imageName = UUID().uuidString
                    do {
                        if let recordID = await saveImageToCloudKit(
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
                        if let localPath = saveImageToFileSystem(image: croppedImage) {
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
    /// Dismiss the keyboard
       private func hideKeyboard() {
           UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
       }
}

#Preview("English") {
    PlateView(plate: .example)
        .environmentObject(DataController.preview)
        .environmentObject(AppColorManager())
        .environment(\.locale, Locale(identifier: "EN"))
}

#Preview("Russian") {
    PlateView(plate: .example)
        .environmentObject(DataController.preview)
        .environmentObject(AppColorManager())
        .environment(\.locale, Locale(identifier: "RU"))
}
