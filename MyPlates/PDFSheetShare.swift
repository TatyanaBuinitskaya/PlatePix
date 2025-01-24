//
//  PDFSheetShare.swift
//  MyPlates
//
//  Created by Tatyana Buinitskaya on 08.01.2025.
//

import SwiftUI

struct PDFSheetShare: View {
    @EnvironmentObject var dataController: DataController
    @State private var pdfURL: URL?
    @State private var plateImages: [UUID: UIImage] = [:]

    
    // Maximum number of columns for the grid
    private let maxColumns = 6
    
    var body: some View {
        VStack {
            HStack{
              //  Text(dataController.dynamicTitle)
              //      .font(.title3)
                Spacer()
                Button {
                    captureAndCreatePDF()
                } label: {
                    Label("Share PDF", systemImage: "square.and.arrow.up")
                }
            }
            .padding()
           
                if let pdfURL = pdfURL {
                    ShareLink(item: pdfURL) {
                        Label("Share PDF", systemImage: "square.and.arrow.up")
                            .padding()
                    }
                }
            
            GeometryReader { geometry in
                let plates = dataController.platesForSelectedFilter()
                let gridItems = generateGridItems(for: plates.count)
//                let cellSize = calculateCellSize(geometry: geometry, itemCount: plates.count, columnCount: gridItems.count)
                
                
                   
                       
               
                
                    LazyVGrid(columns: gridItems, spacing: 10) {
                        ForEach(plates, id: \.id) { plate in
//                            let key = String(describing: ObjectIdentifier(plate))
//
//                            if let image = plateImages[key] {
//                                // Use the fetched image
//                                Image(uiImage: image)
//                                    .resizable()
//                                    .aspectRatio(contentMode: .fill)
//                                    .frame(width: 100, height: 100)
//                                    .clipShape(RoundedRectangle(cornerRadius: 8))
//                            } else {
//                                // Placeholder while loading image
//                                Rectangle()
//                                    .fill(Color.gray.opacity(0.3))
//                                    .frame(width: 100, height: 100)
//                                    .overlay(Text("Loading..."))
//                                    .onAppear {
//                                        Task {
//                                            // Fetch image logic
//                                            if let imagePath = plate.photo,
//                                               let fetchedImage = UIImage(contentsOfFile: imagePath) {
//                                                DispatchQueue.main.async {
//                                                    plateImages[key] = fetchedImage
//                                                }
//                                            }
//                                        }
//                                    }
//                            }
                        
                            
                            if let photoPath = plate.photo, let image = loadImage(from: photoPath) {
                                Image(uiImage: image)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: (UIScreen.main.bounds.width - (CGFloat(gridItems.count + 1) * 10)) / CGFloat(gridItems.count),
                                           height: (UIScreen.main.bounds.width - (CGFloat(gridItems.count + 1) * 10)) / CGFloat(gridItems.count)) // Ensures square shape
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                            } else {
                                // Placeholder for missing or invalid images
                                Rectangle()
                                    .fill(Color.gray.opacity(0.3))
                                    .frame(width: (UIScreen.main.bounds.width - (CGFloat(gridItems.count + 1) * 10)) / CGFloat(gridItems.count),
                                           height: (UIScreen.main.bounds.width - (CGFloat(gridItems.count + 1) * 10)) / CGFloat(gridItems.count)) // Square placeholder
                                    .overlay(
                                        Text("No Image")
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                    )
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                            }
                        }
                    }
                    .padding()
                
            }
        }
    }
    
    func loadImage(from path: String) -> UIImage? {
        let fileURL = URL(fileURLWithPath: path)
        if FileManager.default.fileExists(atPath: fileURL.path) {
            return UIImage(contentsOfFile: fileURL.path)
        } else {
            print("Image not found at path: \(path)")
            return nil
        }
    }
    // Function to generate grid items based on the number of plates
//    private func generateGridItems(for itemCount: Int) -> [GridItem] {
//        let columnCount = min(itemCount, maxColumns) // Max 4 columns, but fewer if fewer plates
//        return Array(repeating: GridItem(.flexible()), count: columnCount)
//    }
    
    private func generateGridItems(for itemCount: Int) -> [GridItem] {
           // Set column count dynamically based on the number of items
           let columnCount: Int
           
        if itemCount <= 6 {
            // If there are 6 or fewer items, use 2 columns
            columnCount = 2
        } else if itemCount <= 18{
            columnCount = 3
        } else if itemCount <= 28{
            columnCount = 4
        } else if itemCount <= 40{
            columnCount = 5
           } else {
               // If there are more than 6 items, calculate the number of columns
               columnCount = min(itemCount, maxColumns)  // Limits to max 4 columns
           }
           
           return Array(repeating: GridItem(.flexible()), count: columnCount)
       }
    
    // Function to calculate cell size dynamically
    private func calculateCellSize(geometry: GeometryProxy, itemCount: Int, columnCount: Int) -> CGSize {
        let totalWidth = geometry.size.width
        let totalHeight = geometry.size.height
        let cellWidth = (totalWidth - CGFloat(columnCount - 1) * 10) / CGFloat(columnCount)
        let cellHeight = totalHeight / CGFloat((itemCount + columnCount - 1) / columnCount) // Rows count
        return CGSize(width: cellWidth, height: cellHeight)
    }
    
    // Capture, create PDF, and save logic
    private func captureAndCreatePDF() {
        print("Attempting to capture screenshot...")
        
        // Capture screenshot of the current view
        guard let screenshotImage = captureScreenshot() else {
            print("Failed to capture screenshot.")
            return
        }
        
        // Create PDF from the screenshot and add text
        let pdfData = createPDF(from: screenshotImage, withText: "Plates for 2025-01-07")
        
        // Save the PDF
        savePDF(pdfData: pdfData) { url in
            DispatchQueue.main.async {
                self.pdfURL = url
                print("PDF ready to share.")
            }
        }
    }
    
    private func captureScreenshot() -> UIImage? {
        print("Capturing screenshot...")
        
        let window = UIApplication.shared.connectedScenes
            .compactMap { ($0 as? UIWindowScene)?.windows.first(where: { $0.isKeyWindow }) }
            .first
        
        guard let rootView = window?.rootViewController?.view else {
            print("Error: Root view not found.")
            return nil
        }
        
        UIGraphicsBeginImageContextWithOptions(rootView.bounds.size, false, 0)
        rootView.drawHierarchy(in: rootView.bounds, afterScreenUpdates: true)
        let screenshot = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return screenshot
    }
    
    private func createPDF(from image: UIImage, withText text: String) -> Data {
        print("Creating PDF from image...")
        
        let pdfData = NSMutableData()
        UIGraphicsBeginPDFContextToData(pdfData, CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height), nil)
        
        UIGraphicsBeginPDFPage()
        image.draw(in: CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height))
        
        let textAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 18),
            .foregroundColor: UIColor.black
        ]
        
        let textRect = CGRect(x: 20, y: image.size.height - 40, width: image.size.width - 40, height: 30)
        text.draw(in: textRect, withAttributes: textAttributes)
        
        UIGraphicsEndPDFContext()
        
        return pdfData as Data
    }
    
    private func savePDF(pdfData: Data, completion: @escaping (URL) -> Void) {
        print("Saving PDF...")
        
        let fileManager = FileManager.default
        let tempDirectory = fileManager.temporaryDirectory
        let pdfURL = tempDirectory.appendingPathComponent("plates_and_date.pdf")
        
        do {
            try pdfData.write(to: pdfURL)
            completion(pdfURL)
            print("PDF saved to \(pdfURL)")
        } catch {
            print("Error saving PDF: \(error)")
        }
    }
    
//    private func loadImageForPlate(_ plate: Plate) async {
//        let key = UUID(uuidString: "\(ObjectIdentifier(plate))") ?? UUID()
//   
//        if let cloudRecordID = plate.cloudRecordID {
//            // Try fetching from CloudKit
//            if let fetchedImage = await dataController.fetchImageFromCloudKit(recordID: cloudRecordID) {
//                DispatchQueue.main.async {
//                    plateImages[plate.key] = fetchedImage
//                }
//                return
//            } else {
//                print("Failed to fetch image from CloudKit.")
//            }
//        }
//        
//        // Attempt to load locally if CloudKit fetch failed
//        if let photoPath = plate.photo {
//            if let localImage = dataController.fetchImageFromFileSystem(imagePath: photoPath) {
//                DispatchQueue.main.async {
//                    plateImages[plate.id] = localImage
//                }
//            } else {
//                print("Failed to load image from local path: \(photoPath)")
//            }
//        }
//    }
}

#Preview {
    PDFSheetShare()
}
