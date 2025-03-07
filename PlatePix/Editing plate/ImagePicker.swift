//
//  ImagePicker.swift
//  PlatePix
//
//  Created by Tatyana Buinitskaya on 27.01.2025.
//

import SwiftUI

/// A view that presents a UIImagePickerController to allow the user to pick an image from their device.
struct ImagePicker: UIViewControllerRepresentable {

    /// The source type of the image picker (e.g., camera or photo library).
    /// This defines where the image should come from.
    var sourceType: UIImagePickerController.SourceType

    /// The closure is passed the picked image, allowing the parent view to handle it.
    var onImagePicked: (UIImage) -> Void

    /// Creates the UIImagePickerController and sets its properties.
    /// This method is called to initialize the view controller.
    /// - Parameter context: The context passed by SwiftUI that contains necessary information for coordinating the view.
    /// - Returns: The UIImagePickerController configured with the appropriate source type and delegate.
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType // Sets the source for the picker (camera or photo library).
        picker.delegate = context.coordinator // Sets the coordinator as the delegate to handle actions.
        return picker
    }

    /// Updates the UIViewController when changes happen in the SwiftUI view.
    /// This method doesn't need to do anything here, as there is no need to update the picker in this case.
    /// - Parameter uiViewController: The UIImagePickerController to update.
    /// - Parameter context: The context passed by SwiftUI that contains necessary information for coordinating the view.
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    /// Creates and returns the Coordinator that will manage the UIImagePickerControllerDelegate methods.
    /// - Returns: A Coordinator object that handles the interactions between the UIImagePickerController and the SwiftUI view.
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    /// A helper class that acts as the delegate for UIImagePickerController.
    /// This class handles image selection and cancellation events.
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        /// The parent ImagePicker instance to communicate back with the view.
        let parent: ImagePicker
        /// Initializes the Coordinator with the parent ImagePicker instance.
        /// - Parameter parent: The parent ImagePicker to handle the interactions.
        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        /// Handles the selection of an image by the user.
        /// When the user picks an image, this method is called to pass the image back to the parent.
        /// - Parameters:
        ///   - picker: The UIImagePickerController instance.
        ///   - info: A dictionary containing information about the selected media.
        func imagePickerController(
            _ picker: UIImagePickerController,
            didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
        ) {
            // Extracts the selected image from the info dictionary and passes it to the parent view.
            if let image = info[.originalImage] as? UIImage {
                parent.onImagePicked(image) // Calls the callback to handle the picked image.
            }
            
            picker.dismiss(animated: true) // Dismisses the picker after the image is selected.
        }

        /// Handles the cancellation of the image picking process.
        /// If the user cancels the image selection, this method is called to dismiss the picker.
        /// - Parameter picker: The UIImagePickerController instance.
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true) // Dismisses the picker if the user cancels.
        }
    }
}
