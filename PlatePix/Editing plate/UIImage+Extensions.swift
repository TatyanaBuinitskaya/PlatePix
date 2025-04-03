//
//  UIImage+Extensions.swift
//  PlatePix
//
//  Created by Tatyana Buinitskaya on 27.01.2025.
//

import UIKit

extension UIImage {
    /// Fixes the orientation of the image based on its metadata.
    /// This method adjusts the image's orientation by applying the correct transformation.
    /// - Returns: A new UIImage with the corrected orientation.
    func fixedOrientation() -> UIImage {
        // Ensure the image has a valid cgImage to work with.
        guard let cgImage = self.cgImage else { return self }
        // If the orientation is already correct (up), return the original image.
        if self.imageOrientation == .up { return self }
        // Compute the transformation matrix for the image's orientation.
        let transform = computeTransform()
        // Ensure the color space is available and create the drawing context.
        guard let colorSpace = cgImage.colorSpace,
              let context = createDrawingContext(colorSpace: colorSpace, cgImage: cgImage)
        else { return self }
        // Apply the transformation to the context and draw the image in its corrected orientation.
        context.concatenate(transform)
        drawImage(context: context, cgImage: cgImage)
        // Create a new cgImage from the context and return a UIImage with the corrected orientation.
        guard let newCgImage = context.makeImage() else { return self }
        return UIImage(cgImage: newCgImage)
    }

    /// Computes the transformation required to correct the image's orientation.
    /// This method generates a transform that accounts for rotation and mirroring based on the image's orientation.
    /// - Returns: The CGAffineTransform used to correct the image's orientation.
    private func computeTransform() -> CGAffineTransform {
        var transform = CGAffineTransform.identity
        // Apply rotation and translation for different orientation cases.
        switch self.imageOrientation {
        case .down, .downMirrored:
            transform = transform.translatedBy(x: size.width, y: size.height).rotated(by: .pi)
        case .left, .leftMirrored:
            transform = transform.translatedBy(x: size.width, y: 0).rotated(by: .pi / 2)
        case .right, .rightMirrored:
            transform = transform.translatedBy(x: 0, y: size.height).rotated(by: -.pi / 2)
        default: break
        }
        // Apply mirroring for orientations that require it (upMirrored, downMirrored, etc.)
        if [.upMirrored, .downMirrored].contains(imageOrientation) {
            transform = transform.translatedBy(x: size.width, y: 0).scaledBy(x: -1, y: 1)
        } else if [.leftMirrored, .rightMirrored].contains(imageOrientation) {
            transform = transform.translatedBy(x: size.height, y: 0).scaledBy(x: -1, y: 1)
        }
        return transform
    }

    /// Creates a CGContext for drawing the image in its corrected orientation.
    /// This method sets up a drawing context with the correct color space and dimensions based on the image size.
    /// - Parameters:
    ///   - colorSpace: The CGColorSpace that should be used for the context.
    ///   - cgImage: The CGImage of the image that needs to be drawn.
    /// - Returns: A CGContext set up for drawing the image, or nil if it couldn't be created.
    private func createDrawingContext(colorSpace: CGColorSpace, cgImage: CGImage) -> CGContext? {
        return CGContext(
            data: nil,
            width: Int(size.width),
            height: Int(size.height),
            bitsPerComponent: cgImage.bitsPerComponent,
            bytesPerRow: 0,
            space: colorSpace,
            bitmapInfo: cgImage.bitmapInfo.rawValue
        )
    }

    /// Draws the image in the corrected orientation on the provided CGContext.
    /// This method determines the appropriate drawing rectangle based on the image’s orientation.
    /// - Parameters:
    ///   - context: The CGContext on which the image should be drawn.
    ///   - cgImage: The CGImage to be drawn in the context.
    private func drawImage(context: CGContext, cgImage: CGImage) {
        // Adjust the drawing rectangle dimensions based on the image's orientation.
        let rect = (imageOrientation == .left || imageOrientation == .leftMirrored ||
                    imageOrientation == .right || imageOrientation == .rightMirrored)
        ? CGRect(x: 0, y: 0, width: size.height, height: size.width)
        : CGRect(x: 0, y: 0, width: size.width, height: size.height)
        // Draw the image into the context in the calculated rectangle.
        context.draw(cgImage, in: rect)
    }
}
