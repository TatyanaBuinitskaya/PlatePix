//
//  PDFShareOneDayView.swift
//  MyPlates
//
//  Created by Tatyana Buinitskaya on 03.03.2025.
//
import SwiftUI

/// A view responsible for displaying plates and providing PDF sharing functionality.
struct PDFShareOneDayView: View {
    /// The shared data controller that manages plate data.
    @EnvironmentObject var dataController: DataController
    /// An environment variable that manages the app's selected color.
    @EnvironmentObject var colorManager: AppColorManager
    /// An environment variable used to dismiss the current view.
    @Environment(\.dismiss) var dismiss
    /// An environment variable used to dismiss the current view.
    @FetchRequest(sortDescriptors: [SortDescriptor(\.name)]) var tags: FetchedResults<Tag>
    /// The filters generated from the fetched tags.
    private var tagFilters: [Filter] {
        tags.map { tag in
            Filter(id: tag.tagID, name: tag.tagName, icon: "fork.knife.circle", tag: tag)
        }
    }
    /// The captured screenshot of the plate view to be included in the PDF.
    @State var imagePlateView: UIImage?
    /// The URL of the generated PDF for sharing.
    @State private var pdfURL: URL?
    /// The maximum number of columns allowed in the grid layout.
    private let maxColumns = 3
    /// Shared user preferences.
    @ObservedObject var userPreferences = UserPreferences.shared // Shared Preferences
    /// A variable that tracks if the save button was tapped.
    @State private var saveIsTapped = false
    /// A variable that controls the visibility of the save alert.
    @State private var showAlertSaved = false
    /// A variable that holds the message to display in the save alert.
    @State private var alertMessage = ""

    var body: some View {
        VStack (spacing: 2) {
            let plates = dataController.platesForSelectedFilter()
            let gridItems = generateGridItems(for: plates.count)
            let rowCount = calculateRowCount(for: plates.count, columns: gridItems.count)
            
//            if rowCount == 3 {
//                Spacer()
//            }
            Spacer()
            header
                .padding(.horizontal, rowCount == 4 ? 40 : 10)
                .padding(.top, 5)
            VStack {
                    LazyVGrid(columns: gridItems, spacing: 2) {
                        ForEach(plates) { plate in
                            NavigationLink(value: plate) {
                                PlateBox(plate: plate)
                            }
                        }
                    }
                    .padding(.horizontal, rowCount == 4 ? 40 : 10) // More horizontal padding for 4 rows
                  //  .padding(.vertical, rowCount == 6 ? 20 : 10)  // More vertical padding for 6 rows
                 //   .padding(.vertical, 0)
            }
            Spacer()
        }
       
        .frame(maxHeight: 750)
        .frame(maxWidth: 400)
        .alert(isPresented: $showAlertSaved) {
            Alert(title: Text("Save Status"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
           }
        }

    /// A header view displaying the dynamic title and a GPEG saving button
    private var header: some View {
        HStack {
            Text(dataController.dynamicTitle)
                .font(.title3)
                .fontWeight(.bold)
            Spacer()
            if !saveIsTapped {  // Hide button when tapped
                Button {
                    saveIsTapped = true
                    
                    // Delay screenshot slightly so button disappears first
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        captureAndSaveAsJPEG()
                        showAlertSaved = true
                        
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        saveIsTapped = false
                        
                    }
                } label: {
                    Text("Save")
                }
                .tint(Color(colorManager.selectedColor.color))
                
            }
        }
    }


    /// Generates an array of grid items based on the number of plates.
        ///
        /// This helps to dynamically adjust the layout depending on the plate count.
        /// - Parameter itemCount: The total number of plates.
        /// - Returns: An array of `GridItem` for the grid layout.
    private func generateGridItems(for itemCount: Int) -> [GridItem] {
        let columnCount: Int
        switch itemCount {
        case 1...8:
            columnCount = 2
        default:
            columnCount = maxColumns
        }
        return Array(repeating: GridItem(.flexible(), spacing: 2), count: columnCount)
    }

    /// Captures a screenshot of the currently presented sheet view and saves it as a JPEG image in the Photo Library.
    private func captureAndSaveAsJPEG() {
        // Capture the screenshot of the current view
        guard let screenshotImage = captureSheetScreenshot() else {
            print("Failed to capture screenshot.")
            return
        }
        
        // Convert the UIImage to JPEG data
        guard let jpegData = screenshotImage.jpegData(compressionQuality: 0.8) else {
            print("Failed to convert image to JPEG.")
            return
        }

        // Save the JPEG image to the Photo Library
        saveJPEGToPhotoLibrary(jpegData: jpegData)
    }

    /// Captures a screenshot of the currently presented sheet view.
    /// - Returns: A `UIImage` representing the captured screenshot of the sheet, or `nil` if no sheet is found.
    private func captureSheetScreenshot() -> UIImage? {
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = scene.windows.first(where: { $0.isKeyWindow }),
              let topViewController = window.rootViewController?.presentedViewController else {
            print("Error: No active sheet found.")
            return nil
        }
        
        let sheetView = topViewController.view
        UIGraphicsBeginImageContextWithOptions(sheetView?.bounds.size ?? .zero, false, 0)
        sheetView?.drawHierarchy(in: sheetView!.bounds, afterScreenUpdates: true)
        let screenshot = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return screenshot
    }
    

    /// Saves JPEG image data to the user's Photo Library.
    /// - Parameter jpegData: The image data in JPEG format.
    private func saveJPEGToPhotoLibrary(jpegData: Data) {
        // Convert the data back to a UIImage
        if let image = UIImage(data: jpegData) {
            // Save the image to the Photo Library
            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
            print("JPEG saved to photo library.")
            // Show an alert with a success message
            alertMessage = NSLocalizedString("JPEG with day plates saved successfully!", comment: "")
            showAlertSaved = true
        } else {
            print("Failed to create image from JPEG data.")
            // Show an alert with an error message
            alertMessage = NSLocalizedString("Failed to save JPEG.", comment: "")
            showAlertSaved = true
        }
    }
    
    /// Function to update user preferences based on grid item count
        private func updateUserPreferences(for count: Int) {
            let shouldShowPreferences = (count == 2)
            userPreferences.showMealTime = shouldShowPreferences
            userPreferences.showQuality = shouldShowPreferences
            userPreferences.showTags = shouldShowPreferences
        }
    
    /// Calculates the number of rows needed for the given number of plates and columns.
    /// - Parameters:
    ///   - plates: The total number of plates.
    ///   - columns: The number of columns in each row.
    /// - Returns: The number of rows required.
    private func calculateRowCount(for plates: Int, columns: Int) -> Int {
        return Int(ceil(Double(plates) / Double(columns)))
    }

   
}

#Preview("English") {
    PDFShareOneDayView()
        .environmentObject(DataController.preview)
        .environmentObject(AppColorManager())
        .environment(\.locale, Locale(identifier: "EN"))
}

#Preview("Russian") {
    PDFShareOneDayView()
        .environmentObject(DataController.preview)
        .environmentObject(AppColorManager())
        .environment(\.locale, Locale(identifier: "RU"))
}
