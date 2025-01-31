//
//  PDFSheetShareView.swift
//  MyPlates
//
//  Created by Tatyana Buinitskaya on 20.01.2025.
//

import SwiftUI

struct PDFSheetShareView: View {
    @EnvironmentObject var dataController: DataController
    @FetchRequest(sortDescriptors: [SortDescriptor(\.name)]) var tags: FetchedResults<Tag>
    private var tagFilters: [Filter] {
        tags.map { tag in
            Filter(id: tag.tagID, name: tag.tagName, icon: "fork.knife.circle", tag: tag)
        }
    }
    @State var imagePlateView: UIImage?
    @State private var pdfURL: URL? // URL for the generated PDF
    private let maxColumns = 6 // Maximum columns for the grid
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
    // MARK: - Header View
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
    // MARK: - Grid Configuration
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
    // MARK: - PDF Generation Workflow
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
    // MARK: - Helper
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

#Preview {
    PDFSheetShareView()
}
