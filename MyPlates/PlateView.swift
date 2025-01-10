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
    @Environment(\.dismiss) var dismiss
    @ObservedObject var plate: Plate
    @State private var pickerItems = [PhotosPickerItem]()
    @State var imagePlateView: UIImage?
    @State var isCameraPresented = false
    @State private var showingICloudUnavailableAlert = false
    @State private var isDeleted = false
    
    var body: some View {
        ZStack{
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(radius: 10)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                )
                .padding()
            VStack{
                if isDeleted {
                    Text("This plate has been deleted.")
                        .foregroundColor(.red)
                } else {
                    HStack{
                        Button {
                            isCameraPresented = true
                        } label: {
                            Image(systemName: "camera")
                                .font(.title2)
                            Text("Camera")
                                .font(.title2)
                        }
                        Spacer()
                        
                        PhotosPicker(selection: $pickerItems, maxSelectionCount: 1, matching: .images) {
                            Image(systemName: "photo.stack")
                                .font(.title2)
                            Text("Library")
                                .font(.title2)
                        }
                        .onChange(of: pickerItems) {
                            guard let item = pickerItems.first else { return }
                            
                            Task {
                                if let data = try? await item.loadTransferable(type: Data.self),
                                   let image = UIImage(data: data) {
                                    let normalizedImage = image.fixedOrientation() // Correct orientation
                                    
                                    if let croppedImage = cropToSquare(image: normalizedImage) {
                                        let imageName = UUID().uuidString
                                        
                                        do {
                                            // Attempt to save the image to CloudKit
                                            if let recordID = await dataController.saveImageToCloudKit(image: croppedImage, imageName: imageName) {
                                                plate.cloudRecordID = recordID.recordName
                                                plate.photo = imageName
                                                imagePlateView = croppedImage
                                            } else {
                                                throw NSError(domain: "CloudKitSave", code: -1, userInfo: nil)
                                            }
                                        } catch {
                                            print("CloudKit save failed, attempting local save: \(error)")
                                            
                                            if let localPath = dataController.saveImageToFileSystem(image: croppedImage) {
                                                plate.photo = localPath // Save local path
                                                imagePlateView = croppedImage
                                            } else {
                                                print("Failed to save image locally.")
                                            }
                                        }
                                        
                                        // Save changes to Core Data
                                        dataController.save()
                                    }
                                }
                            }
                        }
                    }
                    Group {
                        if let image = imagePlateView {
                            // Show image if it's already loaded
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFill()
                                .frame(maxWidth: 300, maxHeight: 300)
                                .clipped()
                        } else {
                            // Fallback system image while loading or if no image is available
                            Image(systemName: "photo")
                                .resizable()
                                .scaledToFit()
                                .foregroundColor(.blue)
                                .frame(maxWidth: .infinity, minHeight: 300)
                                .onAppear {
                                    Task {
                                        // Attempt to fetch the image from CloudKit
                                        if let cloudRecordID = plate.cloudRecordID {
                                            if let fetchedImage = await dataController.fetchImageFromCloudKit(recordID: cloudRecordID) {
                                                // Successfully fetched image from CloudKit
                                                imagePlateView = fetchedImage
                                            } else {
                                                print("Failed to fetch image from CloudKit. Attempting local load...")
                                                
                                                // If CloudKit fails, try loading the image locally
                                                if let localPath = plate.photo {
                                                    if let localImage = dataController.fetchImageFromFileSystem(imagePath: localPath) {
                                                        imagePlateView = localImage
                                                    } else {
                                                        print("Failed to load image from local storage.")
                                                    }
                                                }
                                            }
                                        } else if let localPath = plate.photo {
                                            // If no CloudKit record, directly try local storage
                                            if let localImage = dataController.fetchImageFromFileSystem(imagePath: localPath) {
                                                imagePlateView = localImage
                                            } else {
                                                print("Failed to load image from local storage.")
                                            }
                                        }
                                    }
                                }
                        }
                    }
                    
                    .onTapGesture {
                        isCameraPresented = true
                    }
                    HStack{
                        Spacer()
                        Text("Meal quality:")
                        Group{
                            Image(systemName: "star.fill")
                        }
                        .foregroundColor(plate.quality == 0 ? .red : plate.quality == 1 ? .yellow : .green)
                        Spacer()
                    }
                    .font(.title3)
                    Picker("Meal Quality", selection: $plate.quality) {
                        Text("Unhealthy").tag(Int16(0))
                        Text("Moderate ").tag(Int16(1))
                        Text("Healthy").tag(Int16(2))
                    }
                    .pickerStyle(.segmented)
                    // 1 tag
                    Menu {
                        if let currentTag = plate.tag {
                            Button {
                                plate.tag = nil // Remove the current tag
                            } label: {
                                Label(currentTag.tagName, systemImage: "checkmark")
                            }
                        }
                        
                        let otherTags = dataController.missingTags(from: plate)
                        
                        if !otherTags.isEmpty {
                            Divider()
                            
                            Section("Add Tag") {
                                ForEach(otherTags, id: \.self) { tag in
                                    Button(tag.tagName) {
                                        plate.tag = tag // Assign the selected tag
                                    }
                                }
                            }
                        }
                    } label: {
                        Text(plate.tag?.tagName ?? "No Tag")
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .animation(nil, value: plate.tag?.tagName)
                    }
                    Spacer()
                    Text("Notes")
                        .font(.title2)
                        .foregroundStyle(.secondary)
                    
                    TextField("Notes", text: $plate.plateNotes, prompt: Text("Enter the plate description here"), axis: .vertical)
                    Spacer()
                }
            }
            .padding(40)
            .navigationTitle($plate.plateTitle)
            .navigationBarTitleDisplayMode(.inline)
        }
        .sheet(isPresented: $isCameraPresented) {
            ImagePicker(sourceType: .camera) { image in
                let normalizedImage = image.fixedOrientation() // Correct orientation
                if let croppedImage = cropToSquare(image: normalizedImage) {
                    let imageName = UUID().uuidString
                    
                    Task {
                        do {
                            // Attempt to save the image to CloudKit
                            if let cloudRecordID = await dataController.saveImageToCloudKit(image: croppedImage, imageName: imageName) {
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
                        
                        // Save changes to Core Data
                        dataController.save()
                    }
                }
            }
        }
        
        .sheet(isPresented: $dataController.showCongratulations) {
            AwardSheetView()
        }
        
            .onChange(of: plate) {
                isDeleted = false
            }
//        .onChange(of: plate) {
//            if plate.isDeleted || plate.photo == nil {
//                imagePlateView = nil // Reset the image view
//            } else {
//                // Reload the image for the new plate
//                if let cloudRecordID = plate.cloudRecordID {
//                    Task {
//                        if let fetchedImage = await dataController.fetchImageFromCloudKit(recordID: cloudRecordID) {
//                            imagePlateView = fetchedImage
//                        } else {
//                            print("Failed to fetch image from CloudKit.")
//                        }
//                    }
//                } else if let photoPath = plate.photo {
//                    if let fetchedImage = dataController.fetchImageFromFileSystem(imagePath: photoPath) {
//                        imagePlateView = fetchedImage
//                    } else {
//                        print("Failed to fetch image from local storage.")
//                    }
//                }
//            }
//        }
        .onReceive(plate.objectWillChange) { _ in
            dataController.queueSave()
        }
        .onSubmit(dataController.save)
        .toolbar {
            Button(action: {
                dataController.delete(plate)
                isDeleted = true
                dismiss()
            }) {
                Image(systemName: "trash")
                    .foregroundColor(.red)
            }
        }
        .onAppear {
            if dataController.checkAwards() {
                dataController.showCongratulations = true
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
    
}

// ImagePicker for Capturing Photos
struct ImagePicker: UIViewControllerRepresentable {
    var sourceType: UIImagePickerController.SourceType
    var onImagePicked: (UIImage) -> Void
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.delegate = context.coordinator
        //   picker.modalPresentationStyle = .fullScreen
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.onImagePicked(image)
            }
            picker.dismiss(animated: true)
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }
        
        
    }
}

extension UIImage {
    func fixedOrientation() -> UIImage {
        guard let cgImage = self.cgImage else {
            return self
        }
        
        if self.imageOrientation == .up {
            return self
        }
        
        var transform = CGAffineTransform.identity
        
        switch self.imageOrientation {
        case .down, .downMirrored:
            transform = transform.translatedBy(x: self.size.width, y: self.size.height)
            transform = transform.rotated(by: .pi)
        case .left, .leftMirrored:
            transform = transform.translatedBy(x: self.size.width, y: 0)
            transform = transform.rotated(by: .pi / 2)
        case .right, .rightMirrored:
            transform = transform.translatedBy(x: 0, y: self.size.height)
            transform = transform.rotated(by: -.pi / 2)
        default:
            break
        }
        
        switch self.imageOrientation {
        case .upMirrored, .downMirrored:
            transform = transform.translatedBy(x: self.size.width, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
        case .leftMirrored, .rightMirrored:
            transform = transform.translatedBy(x: self.size.height, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
        default:
            break
        }
        
        guard let colorSpace = cgImage.colorSpace,
              let context = CGContext(
                data: nil,
                width: Int(self.size.width),
                height: Int(self.size.height),
                bitsPerComponent: cgImage.bitsPerComponent,
                bytesPerRow: 0,
                space: colorSpace,
                bitmapInfo: cgImage.bitmapInfo.rawValue
              ) else {
            return self
        }
        
        context.concatenate(transform)
        
        switch self.imageOrientation {
        case .left, .leftMirrored, .right, .rightMirrored:
            context.draw(cgImage, in: CGRect(x: 0, y: 0, width: self.size.height, height: self.size.width))
        default:
            context.draw(cgImage, in: CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height))
        }
        
        guard let newCgImage = context.makeImage() else {
            return self
        }
        
        return UIImage(cgImage: newCgImage)
    }
}

#Preview {
    PlateView(plate: .example)
        .environmentObject(DataController.preview)
}
