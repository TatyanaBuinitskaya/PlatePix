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
    var tagFilters: [Filter] {
        tags.map { tag in
            Filter(id: tag.tagID, name: tag.tagName, icon: "fork.knife.circle", tag: tag)
        }
    }
    @State private var pdfURL: URL?
    private let maxColumns = 6
    
    var body: some View {
        VStack {
            HStack{
                Text(dataController.dynamicTitle)
                    .font(.title3)
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
                
                LazyVGrid(columns: gridItems, spacing: 5) {
                    ForEach(dataController.platesForSelectedFilter()) { plate in
                        NavigationLink(value: plate){
                            PlateBox(plate: plate)
                        }
                    }
                }
            }
        }
    }
    
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
    }


#Preview {
    PDFSheetShareView()
}
