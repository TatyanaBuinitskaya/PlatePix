//
//  PDFSheetShareView.swift
//  MyPlates
//
//  Created by Tatyana Buinitskaya on 20.01.2025.
//

import SwiftUI

/// A view responsible for displaying plates and providing PDF sharing functionality.
struct PDFSheetShareView: View {
    /// The shared data controller that manages plate data.
    @EnvironmentObject var dataController: DataController
    /// The fetched tags sorted by name to be used as filters.
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
    private let maxColumns = 6

    var body: some View {
        VStack {
            header
                .padding()
            if let pdfURL = pdfURL {
                ShareLink(item: pdfURL) {
                    Label("Share PDF", systemImage: "square.and.arrow.up")
                        .padding()
                }
            }
            GeometryReader {_ in
                let plates = dataController.platesForSelectedFilter()
                let gridItems = generateGridItems(for: plates.count)
                LazyVGrid(columns: gridItems, spacing: 10) {
                    ForEach(plates) { plate in
                        NavigationLink(value: plate) {
                            PlateBox(plate: plate, showOverlay: false)
                        }
                    }
                }
                .padding()
            }
        }
    }

    /// A header view displaying the dynamic title and a PDF sharing button.
    private var header: some View {
        HStack {
            Text(dataController.dynamicTitle)
                .font(.title3)
                .fontWeight(.bold)
            Spacer()
            Button(action: captureAndCreatePDF) {
                Label("Share PDF", systemImage: "square.and.arrow.up")
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
        case 1...6:
            columnCount = 2
        case 7...18:
            columnCount = 3
        case 19...28:
            columnCount = 4
        case 29...40:
            columnCount = 5
        default:
            columnCount = maxColumns
        }
        return Array(repeating: GridItem(.flexible()), count: columnCount)
    }

    /// Captures a screenshot of the current view and initiates PDF creation.
    private func captureAndCreatePDF() {
        guard let screenshotImage = captureScreenshot() else {
            print("Failed to capture screenshot.")
            return
        }
        let pdfData = createPDF(from: screenshotImage, withText: "Plates for \(formattedDate(Date()))")
        savePDF(pdfData: pdfData) { url in
            DispatchQueue.main.async {
                self.pdfURL = url
                print("PDF ready to share at \(url)")
            }
        }
    }

    /// Captures a screenshot of the app's root view.
       /// - Returns: A `UIImage` representing the captured screenshot.
    private func captureScreenshot() -> UIImage? {
        guard let rootView = UIApplication.shared
                .connectedScenes
                .compactMap({ ($0 as? UIWindowScene)?.keyWindow?.rootViewController?.view })
                .first else {
            print("Error: Root view not found.")
            return nil
        }
        UIGraphicsBeginImageContextWithOptions(rootView.bounds.size, false, 0)
        rootView.drawHierarchy(in: rootView.bounds, afterScreenUpdates: true)
        let screenshot = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return screenshot
    }

    /// Creates a PDF from a provided image with additional text.
       /// - Parameters:
       ///   - image: The image to be included in the PDF.
       ///   - text: The descriptive text to appear below the image.
       /// - Returns: The generated PDF data.
    private func createPDF(from image: UIImage, withText text: String) -> Data {
        let pdfData = NSMutableData()
        let pageBounds = CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height + 50)
        UIGraphicsBeginPDFContextToData(pdfData, pageBounds, nil)
        UIGraphicsBeginPDFPage()
        // Draw the image
        image.draw(in: CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height))
        // Draw the text at the bottom
        let textAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 18),
            .foregroundColor: UIColor.black
        ]
        let textRect = CGRect(
            x: 20,
            y: image.size.height + 10, // Adjust placement for text below the image
            width: image.size.width - 40,
            height: 30
        )
        text.draw(in: textRect, withAttributes: textAttributes)
        UIGraphicsEndPDFContext()
        return pdfData as Data
    }

    /// Saves the generated PDF data to a temporary file and provides the file URL.
        /// - Parameters:
        ///   - pdfData: The PDF data to be saved.
        ///   - completion: A closure that returns the URL of the saved PDF.
    private func savePDF(pdfData: Data, completion: @escaping (URL) -> Void) {
        let fileManager = FileManager.default
        let tempDirectory = fileManager.temporaryDirectory
        let pdfURL = tempDirectory.appendingPathComponent("plates_and_date.pdf")
        do {
            try pdfData.write(to: pdfURL)
            completion(pdfURL)
        } catch {
            print("Error saving PDF: \(error.localizedDescription)")
        }
    }

    /// Formats a given date to a medium-style string.
        /// - Parameter date: The date to be formatted.
        /// - Returns: A formatted date string.
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

#Preview {
    PDFSheetShareView()
}
