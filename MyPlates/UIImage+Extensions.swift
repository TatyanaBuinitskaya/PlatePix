//
//  UIImage+Extensions.swift
//  MyPlates
//
//  Created by Tatyana Buinitskaya on 27.01.2025.
//

import UIKit

// extension UIImage {
//    func fixedOrientation() -> UIImage {
//        guard let cgImage = self.cgImage else {
//            return self
//        }
//        if self.imageOrientation == .up {
//            return self
//        }
//        var transform = CGAffineTransform.identity
//        switch self.imageOrientation {
//        case .down, .downMirrored:
//            transform = transform.translatedBy(x: self.size.width, y: self.size.height)
//            transform = transform.rotated(by: .pi)
//        case .left, .leftMirrored:
//            transform = transform.translatedBy(x: self.size.width, y: 0)
//            transform = transform.rotated(by: .pi / 2)
//        case .right, .rightMirrored:
//            transform = transform.translatedBy(x: 0, y: self.size.height)
//            transform = transform.rotated(by: -.pi / 2)
//        default:
//            break
//        }
//        switch self.imageOrientation {
//        case .upMirrored, .downMirrored:
//            transform = transform.translatedBy(x: self.size.width, y: 0)
//            transform = transform.scaledBy(x: -1, y: 1)
//        case .leftMirrored, .rightMirrored:
//            transform = transform.translatedBy(x: self.size.height, y: 0)
//            transform = transform.scaledBy(x: -1, y: 1)
//        default:
//            break
//        }
//        guard let colorSpace = cgImage.colorSpace,
//              let context = CGContext(
//                data: nil,
//                width: Int(self.size.width),
//                height: Int(self.size.height),
//                bitsPerComponent: cgImage.bitsPerComponent,
//                bytesPerRow: 0,
//                space: colorSpace,
//                bitmapInfo: cgImage.bitmapInfo.rawValue
//              ) else {
//            return self
//        }
//        context.concatenate(transform)
//        switch self.imageOrientation {
//        case .left, .leftMirrored, .right, .rightMirrored:
//            context.draw(cgImage, in: CGRect(x: 0, y: 0, width: self.size.height, height: self.size.width))
//        default:
//            context.draw(cgImage, in: CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height))
//        }
//        guard let newCgImage = context.makeImage() else {
//            return self
//        }
//        return UIImage(cgImage: newCgImage)
//    }
//  }

extension UIImage {
    func fixedOrientation() -> UIImage {
        guard let cgImage = self.cgImage else { return self }
        if self.imageOrientation == .up { return self }
        let transform = computeTransform()
        guard let colorSpace = cgImage.colorSpace,
              let context = createDrawingContext(colorSpace: colorSpace, cgImage: cgImage)
        else { return self }
        context.concatenate(transform)
        drawImage(context: context, cgImage: cgImage)
        guard let newCgImage = context.makeImage() else { return self }
        return UIImage(cgImage: newCgImage)
    }
    /// Computes the transform needed for correcting orientation
    private func computeTransform() -> CGAffineTransform {
        var transform = CGAffineTransform.identity
        switch self.imageOrientation {
        case .down, .downMirrored:
            transform = transform.translatedBy(x: size.width, y: size.height).rotated(by: .pi)
        case .left, .leftMirrored:
            transform = transform.translatedBy(x: size.width, y: 0).rotated(by: .pi / 2)
        case .right, .rightMirrored:
            transform = transform.translatedBy(x: 0, y: size.height).rotated(by: -.pi / 2)
        default: break
        }
        if [.upMirrored, .downMirrored].contains(imageOrientation) {
            transform = transform.translatedBy(x: size.width, y: 0).scaledBy(x: -1, y: 1)
        } else if [.leftMirrored, .rightMirrored].contains(imageOrientation) {
            transform = transform.translatedBy(x: size.height, y: 0).scaledBy(x: -1, y: 1)
        }
        return transform
    }
    /// Creates a CGContext for drawing the corrected image
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
    /// Draws the image in the corrected orientation
    private func drawImage(context: CGContext, cgImage: CGImage) {
        let rect = (imageOrientation == .left || imageOrientation == .leftMirrored ||
                    imageOrientation == .right || imageOrientation == .rightMirrored)
                    ? CGRect(x: 0, y: 0, width: size.height, height: size.width)
                    : CGRect(x: 0, y: 0, width: size.width, height: size.height)
        context.draw(cgImage, in: rect)
    }
}
