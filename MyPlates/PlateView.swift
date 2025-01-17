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
        
//       VStack{
//            if isDeleted {
//                Text("This plate has been deleted.")
//                    .foregroundColor(.red)
//            } else {
//                
//                
//                ZStack{
//                    VStack{
//                        
//                        if let image = imagePlateView {
//                            // Show image if it's already loaded
//                            Image(uiImage: image)
//                                .resizable()
//                                .scaledToFill()
//                                .frame(maxWidth: 500, maxHeight: 500)
//                                .clipShape(Rectangle())
//                              .padding()
//                                .onTapGesture {
//                                    isCameraPresented = true
//                                }
//                            
//                        } else {
//                            // Fallback system image while loading or if no image is available
//                            Image(systemName: "fork.knife.circle.fill")
//                                .resizable()
//                                .scaledToFill()
//                                .foregroundColor(.white)
//                                .padding(30)
//                                .background(Color.blue)
//                                .frame(maxWidth: 500, maxHeight: 500)
//                                .clipShape(Rectangle())
//                             .padding()
//                                .onTapGesture {
//                                    isCameraPresented = true
//                                }
//                                .onAppear {
//                                    Task {
//                                        // Attempt to fetch the image from CloudKit
//                                        if let cloudRecordID = plate.cloudRecordID {
//                                            if let fetchedImage = await dataController.fetchImageFromCloudKit(recordID: cloudRecordID) {
//                                                // Successfully fetched image from CloudKit
//                                                imagePlateView = fetchedImage
//                                            } else {
//                                                print("Failed to fetch image from CloudKit. Attempting local load...")
//                                                
//                                                // If CloudKit fails, try loading the image locally
//                                                if let localPath = plate.photo {
//                                                    if let localImage = dataController.fetchImageFromFileSystem(imagePath: localPath) {
//                                                        imagePlateView = localImage
//                                                    } else {
//                                                        print("Failed to load image from local storage.")
//                                                    }
//                                                }
//                                            }
//                                        } else if let localPath = plate.photo {
//                                            // If no CloudKit record, directly try local storage
//                                            if let localImage = dataController.fetchImageFromFileSystem(imagePath: localPath) {
//                                                imagePlateView = localImage
//                                            } else {
//                                                print("Failed to load image from local storage.")
//                                            }
//                                        }
//                                    }
//                                }
//                        }
//                        
//                        
//                        
//                        //                    .onTapGesture {
//                        //                        isCameraPresented = true
//                        //                    }
//                        
//                        
//                        HStack {
//                            Image(systemName: "clock")
//                                .font(.title2)
//                            
//                            Menu {
//                                if let currentTag = plate.tag {
//                                    Button {
//                                        plate.tag = nil // Remove the current tag
//                                    } label: {
//                                        Label(currentTag.tagName, systemImage: "checkmark")
//                                    }
//                                }
//                                
//                                let otherTags = dataController.missingTags(from: plate)
//                                
//                                if !otherTags.isEmpty {
//                                    Divider()
//                                    
//                                    Section("Add Tag") {
//                                        ForEach(otherTags, id: \.self) { tag in
//                                            Button(tag.tagName) {
//                                                plate.tag = tag // Assign the selected tag
//                                            }
//                                        }
//                                    }
//                                } else {
//                                    Divider()
//                                    Section("No Tags Available") {
//                                        VStack{
//                                            Button("Create default tags") {
//                                                // Action to navigate to tag creation or create one inline
//                                                dataController.createDefaultTags(context: dataController.container.viewContext)
//                                            }
//                                        }
//                                    }
//                                }
//                            } label: {
//                                Text(plate.tag?.tagName ?? "No Tag")
//                                    .font(.title3)
//                            }
//                            
//                            Spacer()
//                            
//                            Image(systemName: "star.fill")
//                                .foregroundColor(plate.quality == 0 ? .red : plate.quality == 1 ? .yellow : .green)
//                                .font(.title2)
//                            
//                            
//                            Menu {
//                                Picker("Meal Quality", selection: $plate.quality) {
//                                    Text("Unhealthy").tag(Int16(0))
//                                    Text("Moderate").tag(Int16(1))
//                                    Text("Healthy").tag(Int16(2))
//                                }
//                                .labelsHidden() // Hide the default labels
//                            } label: {
//                                Text(plate.quality == 0 ? "Unhealthy" : plate.quality == 1 ? "Moderate" : "Healthy")
//                                    .font(.title3) // Customize font size here
//                            }
//                        }
//                        .padding(.bottom, 10)
//                        
//                        
//                        
//                        HStack{
//                            //                        Image(systemName: "pencil.and.list.clipboard")
//                            //                            .font(.title3)
//                            Text("Notes:")
//                                .font(.title3)
//                                .padding(.leading, 3)
//                            
//                            Spacer()
//                        }
//                        
//                        TextField(
//                            "Notes",
//                            text: $plate.plateNotes,
//                            prompt: Text("Enter the plate description here").foregroundColor(.gray),
//                            axis: .vertical
//                        )
//                        
//                        .padding(8)
//                       // .frame(maxWidth: .infinity, height: 200, alignment: .top)
//                      
//                        .background(.white)
//                        .cornerRadius(8)
//                        .overlay(
//                            RoundedRectangle(cornerRadius: 8)
//                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
//                        )
//                        .font(.body)
//                        .lineLimit(5)
//                        
//                        Spacer()
//                    }
//                    .padding(10) // Inner padding for better usability
//                    // .frame(maxWidth: .infinity, minHeight: 100, alignment: .top)
//                    .background(.gray.opacity(0.2)) // Subtle background for input area
//                    .cornerRadius(8) // Rounded corners for modern look
//                    .padding()
//                    
//                    
//                    
//                 
//                    
//                    VStack{
//                        Spacer()
//                        HStack{
//                            Spacer()
//                            
//                            PhotosPicker(selection: $pickerItems, maxSelectionCount: 1, matching: .images) {
//                                
//                                Image(systemName: "photo.stack")
//                                    .font(.title2)
//                                    .foregroundColor(.white)
//                                    .padding()
//                                    .background(Color.blue)
//                                    .clipShape(Circle())
//                                    .shadow(radius: 5)
//                                    .padding(.horizontal)
//                                
//                                
//                            }
//                            .onChange(of: pickerItems) {
//                                guard let item = pickerItems.first else { return }
//                                
//                                Task {
//                                    if let data = try? await item.loadTransferable(type: Data.self),
//                                       let image = UIImage(data: data) {
//                                        let normalizedImage = image.fixedOrientation() // Correct orientation
//                                        
//                                        if let croppedImage = cropToSquare(image: normalizedImage) {
//                                            let imageName = UUID().uuidString
//                                            
//                                            do {
//                                                // Attempt to save the image to CloudKit
//                                                if let recordID = await dataController.saveImageToCloudKit(image: croppedImage, imageName: imageName) {
//                                                    plate.cloudRecordID = recordID.recordName
//                                                    plate.photo = imageName
//                                                    imagePlateView = croppedImage
//                                                } else {
//                                                    throw NSError(domain: "CloudKitSave", code: -1, userInfo: nil)
//                                                }
//                                            } catch {
//                                                print("CloudKit save failed, attempting local save: \(error)")
//                                                
//                                                if let localPath = dataController.saveImageToFileSystem(image: croppedImage) {
//                                                    plate.photo = localPath // Save local path
//                                                    imagePlateView = croppedImage
//                                                } else {
//                                                    print("Failed to save image locally.")
//                                                }
//                                            }
//                                            
//                                            // Save changes to Core Data
//                                            dataController.save()
//                                        }
//                                    }
//                                }
//                            }
//                            
//                            Button {
//                                isCameraPresented = true
//                            } label: {
//                                
//                                Image(systemName: "camera")
//                                    .font(.title2)
//                                    .foregroundColor(.white)
//                                    .padding()
//                                    .background(Color.blue)
//                                    .clipShape(Circle())
//                                    .shadow(radius: 5)
//                                    
//                                
//                            }
//                            
//                        }
//                        
//                    }
//                    .padding()
//                }
//              
//            }
//              
//            
//        }
//       .padding()
        
        VStack {
            if isDeleted {
                Text("This plate has been deleted.")
                    .foregroundColor(.red)
            } else {
                ZStack{
                    ScrollView { // Allow scrolling for smaller devices
                        
                        VStack {
                            // Image Section
                            if let image = imagePlateView {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFit() // Adapt to available space
                                    .frame(maxWidth: UIScreen.main.bounds.width * 1, maxHeight: 600) // Scales with device width
                                    .clipShape(Rectangle())
                                    .onTapGesture {
                                        isCameraPresented = true
                                    }
                            } else {
                                Image(systemName: "fork.knife.circle.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .foregroundColor(.white)
                                    .padding()
                                    .background(Color.blue)
                                    .frame(maxWidth: UIScreen.main.bounds.width * 1, maxHeight: 600)
                                    .clipShape(Rectangle())
                                    .onTapGesture {
                                        isCameraPresented = true
                                    }
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
                        
                        // Metadata Section (Tag and Quality)
                          
                                HStack {
                                    Image(systemName: "clock")
                                        .font(.title2)
                                    Menu {
                                        // Tag Selection Menu
                                        if let currentTag = plate.tag {
                                            Button {
                                                plate.tag = nil // Remove the current tag
                                            } label: {
                                                Label(currentTag.tagName, systemImage: "checkmark")
                                            }
                                        }
                                        let otherTags = dataController.missingTags(from: plate)
                                        if !otherTags.isEmpty {
                                            Section("Add Tag") {
                                                ForEach(otherTags, id: \.self) { tag in
                                                    Button(tag.tagName) {
                                                        plate.tag = tag // Assign the selected tag
                                                    }
                                                }
                                            }
                                        } else {
                                            Section("No Tags Available") {
                                                Button("Create default tags") {
                                                    dataController.createDefaultTags(context: dataController.container.viewContext)
                                                }
                                            }
                                        }
                                    } label: {
                                        Text(plate.tag?.tagName ?? "No Tag")
                                            .font(.title3)
                                    }
                                    Spacer()
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
                                .padding(.top, 8)
                                
                            // Notes Section
                            VStack(alignment: .leading) {
                                HStack{
                                    Text("Notes:")
                                        .font(.title3)
                                }
                                TextField(
                                    "Enter the plate description here",
                                    text: $plate.plateNotes,
                                    axis: .vertical
                                )
                                .padding(8)
                                .frame(maxWidth: .infinity, minHeight: 100, maxHeight: 200, alignment: .top) // Scales for larger devices
                                .background(Color.white)
                                .cornerRadius(8)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                )
                            }
                      
                            
                            Spacer()
                        }
                        .padding(.horizontal)
                    }
                    VStack{
                        Spacer()
                        // Button Section
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
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .padding(.vertical)
            
            .navigationTitle($plate.plateTitle)
            .navigationBarTitleDisplayMode(.inline)
        
        
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
