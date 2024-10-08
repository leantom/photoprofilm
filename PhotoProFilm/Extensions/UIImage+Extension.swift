//
//  UIImage+Extension.swift
//  PhotoProFilm
//
//  Created by QuangHo on 1/7/24.
//

import Foundation
import UIKit
import FirebaseStorage
import SwiftUI
import PixelEnginePackage
import AVFoundation
import CoreMedia
import Vision
import VideoToolbox

func uploadImageToFirebase(image: UIImage, imageName: String, completion: @escaping (Result<String, Error>) -> Void) {
    // Convert the UIImage to JPEG data with compression quality
    guard let imageData = image.jpegData(compressionQuality: 0.8) else {
        completion(.failure(NSError(domain: "ImageConversion", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to convert UIImage to JPEG"])))
        return
    }
    
    // Create a reference to Firebase Storage
    let storageRef = Storage.storage().reference().child("images/\(imageName).jpg")
    
    // Upload the image data to Firebase Storage
    let metadata = StorageMetadata()
    metadata.contentType = "image/jpeg"
    
    storageRef.putData(imageData, metadata: metadata) { metadata, error in
        if let error = error {
            // Handle error
            print(error.localizedDescription)
            completion(.failure(error))
        } else {
            // Get the download URL
            storageRef.downloadURL { url, error in
                if let error = error {
                    print(error.localizedDescription)
                    completion(.failure(error))
                } else if let downloadURL = url {
                    // Return the download URL as a string
                    print(downloadURL)
                    completion(.success(downloadURL.absoluteString))
                }
            }
        }
    }
}


extension UIImage{
    
    func saveImageToPhotoAlbum(image: UIImage) {
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(imageSaveCompletion(_:didFinishSavingWithError:contextInfo:)), nil)
    }
    
    // Selector to handle the save result
    @objc func imageSaveCompletion(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            // Handle the error case
            print("Error saving image: \(error.localizedDescription)")
        } else {
            // Handle the success case
            print("Image saved successfully!")
        }
    }
}

extension UIImage {
    func resizedImage(newSize: CGSize) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        self.draw(in: CGRect(origin: .zero, size: newSize))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return resizedImage
    }
    
    func downsizedImage(by factor: CGFloat) -> UIImage? {
        let newSize = CGSize(width: self.size.width / factor, height: self.size.height / factor)
        return resizedImage(newSize: newSize)
    }
    
    func calculateResize() -> CGFloat{
        let sizeOriginal = self.size
        var nDownsize: CGFloat = 1
        if sizeOriginal.width > 1500 {
            nDownsize = 2
        }
        
        if sizeOriginal.width > 2500 {
            nDownsize = 2.5
        }
        
        if sizeOriginal.width > 3500 {
            nDownsize = 4
        }
        
        if sizeOriginal.width > 4000 {
            nDownsize = 5
        }
        return nDownsize
    }
    
}

extension UIImage {
    func resized(toMaxSize maxSize: CGSize) -> UIImage? {
        let aspectRatio = size.width / size.height
        var newSize = maxSize
        
        if aspectRatio > 1 { // Landscape
            newSize.height = maxSize.width / aspectRatio
        } else { // Portrait
            newSize.width = maxSize.height * aspectRatio
        }
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        draw(in: CGRect(origin: .zero, size: newSize))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return resizedImage
    }
    
    func compressed(toMaxFileSize maxSizeKB: Int) -> Data? {
        var compression: CGFloat = 1.0
        let maxFileSize = maxSizeKB * 1024
        
        guard var imageData = self.pngData() else {
            return nil
        }
        
        while imageData.count > maxFileSize && compression > 0 {
            compression -= 0.1
            if let newData = self.jpegData(compressionQuality: compression) {
                imageData = newData
            } else {
                return nil
            }
        }
        
        return imageData
    }
}

// Function to get font based on the name format "colorStyle-1", "colorStyle-2", etc.
func getFont(from filterColorCube: FilterColorCube) -> String {
    // Extract the colorStyle part (before the dash) from the name
    let components = filterColorCube.name.split(separator: "-")
    guard let colorStyleRawValue = components.first else {
        return "VCROSDMono"  // Default font if the format is not correct
    }
    
    // Attempt to convert the extracted part to a ColorStyle enum
    if let colorStyle = ColorStyle(rawValue: String(colorStyleRawValue)) {
        switch colorStyle {
        case .film:
            return "Calculatrix-7"
        case .retro:
            return "Minolta-Classic"
        default:
            return "VCROSDMono"
        }
    } else {
        // Default font if no matching ColorStyle is found
        return "VCROSDMono"
    }
}

extension UIImage {
    func addText(atPoint point: CGPoint, color: UIColor) -> UIImage {
        let scale = UIScreen.main.scale
        UIGraphicsBeginImageContextWithOptions(self.size, false, scale)
        
        // Adjust font size based on the width of the image
        let fontSize = self.size.width * 0.05 // Adjust the proportion as needed

        var fontString = ""
        if let cube = AppState.shared.cubeSelected {
            fontString = getFont(from: cube)
        }
        
        // Ensure the font is valid, fallback to system font if not available
        var fontCustom = UIFont(name: fontString, size: fontSize)
        if fontCustom == nil {
            fontCustom = .systemFont(ofSize: fontSize, weight: .bold)
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMM yy"  // Classic print style example
        let text = dateFormatter.string(from: Date())
        
        // Draw the original image as the base
        self.draw(in: CGRect(origin: .zero, size: self.size))
        
        // Define the text's attributes
        let textFontAttributes = [
            NSAttributedString.Key.font: fontCustom as Any,
            NSAttributedString.Key.foregroundColor: color
        ] as [NSAttributedString.Key: Any]
        
        // Calculate the bounding box for the text
        let textSize = text.size(withAttributes: textFontAttributes)
        
        // Position text near the specified point
        let textRect = CGRect(x: point.x, y: point.y, width: textSize.width, height: textSize.height)
        
        // Draw the text onto the image
        text.draw(in: textRect, withAttributes: textFontAttributes)
        
        // Get the new image with the text added
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage ?? self
    }
}

func fixImageOrientation(image: UIImage) -> UIImage {
    if image.imageOrientation == .up {
        return image // Image is already in correct orientation
    }

    // Start a graphics context of the correct size
    UIGraphicsBeginImageContextWithOptions(image.size, false, image.scale)
    image.draw(in: CGRect(origin: .zero, size: image.size))

    // Create new UIImage from the context
    let normalizedImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()

    return normalizedImage ?? image
}

func cropImageToAspectRatio(image: UIImage, aspectRatio: AspectRatio) -> UIImage? {
    // Step 1: Fix the image orientation
    let rotatedImage = fixImageOrientation(image: image)
    
    let originalSize = rotatedImage.size
    var targetAspectRatio: CGFloat
    
    // Define aspect ratios and check orientation
    switch aspectRatio {
    case .ratio4_3:
        targetAspectRatio = 4.0 / 3.0
    case .ratio9_16:
        targetAspectRatio = 16.0 / 9.0
    case .ratio1_1:
        targetAspectRatio = 1
        
    }
    if targetAspectRatio == 1 {return image}
    // Step 2: Handle portrait or landscape mode
    let isPortrait = originalSize.height >= originalSize.width
    if isPortrait {
        // Swap aspect ratio if in portrait
        targetAspectRatio = 1.0 / targetAspectRatio
    }
    
    // Calculate the target width and height based on the aspect ratio
    let targetWidth: CGFloat
    let targetHeight: CGFloat
    
    if originalSize.width / originalSize.height > targetAspectRatio {
        // Image is wider than the target aspect ratio
        targetHeight = originalSize.height
        targetWidth = originalSize.height * targetAspectRatio
    } else {
        // Image is taller than the target aspect ratio
        targetWidth = originalSize.width
        targetHeight = originalSize.width / targetAspectRatio
    }
    
    // Step 3: Calculate the cropping rectangle
    let x = (originalSize.width - targetWidth) / 2.0
    let y = (originalSize.height - targetHeight) / 2.0
    let cropRect = CGRect(x: x, y: y, width: targetWidth, height: targetHeight)
    
    // Step 4: Crop the image
    guard let cgImage = rotatedImage.cgImage?.cropping(to: cropRect) else {
        return nil
    }
    
    // Step 5: Return the final cropped and oriented image
    let imageFinal = UIImage(cgImage: cgImage)
    return imageFinal
}

func resizeAndCompressImage(image: UIImage, maxSize: CGSize = CGSize(width: 2048, height: 2048), maxFileSizeMB: Int = 3) -> UIImage? {
    let resizedImage = image.resized(toMaxSize: maxSize)
    
    return resizedImage
}

extension UIImage {
    public func pixelBuffer() -> CVPixelBuffer? {
        let width = Int(self.size.width)
        let height = Int(self.size.height)
        let attrs = [kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue!,
             kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue!]
        var pixelBuffer: CVPixelBuffer?
        let status = CVPixelBufferCreate(kCFAllocatorDefault,
                                         width,
                                         height,
                                         kCVPixelFormatType_32ARGB,
                                         attrs as CFDictionary,
                                         &pixelBuffer)
        guard status == kCVReturnSuccess, let buffer = pixelBuffer else {
            return nil
        }
        
        CVPixelBufferLockBaseAddress(buffer, CVPixelBufferLockFlags(rawValue: 0))
        let data = CVPixelBufferGetBaseAddress(buffer)
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let context = CGContext(data: data,
                                width: width,
                                height: height,
                                bitsPerComponent: 8,
                                bytesPerRow: CVPixelBufferGetBytesPerRow(buffer),
                                space: colorSpace,
                                bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue)
        
        guard let cgImage = self.cgImage else {
            return nil
        }
        context?.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
        
        CVPixelBufferUnlockBaseAddress(buffer, CVPixelBufferLockFlags(rawValue: 0))
        return buffer
        
    }
    func cropped(to targetSize: CGSize) -> UIImage? {
        let width = min(self.size.width, targetSize.width)
        let height = min(self.size.height, targetSize.height)
        let cropRect = CGRect(x: (self.size.width - width) / 2,
                              y: (self.size.height - height) / 2,
                              width: width,
                              height: height)
        
        guard let cgImage = self.cgImage?.cropping(to: cropRect) else { return nil }
        return UIImage(cgImage: cgImage, scale: self.scale, orientation: self.imageOrientation)
    }
    
    func resized(to targetSize: CGSize) -> UIImage? {
        let renderer = UIGraphicsImageRenderer(size: targetSize)
        return renderer.image { _ in
            self.draw(in: CGRect(origin: .zero, size: targetSize))
        }
    }
    
    
    func resizeMaintainingAspectRatio(targetSize: CGSize) -> UIImage? {
        let widthRatio = targetSize.width / size.width
        let heightRatio = targetSize.height / size.height
        let scaleFactor = min(widthRatio, heightRatio)
        
        let scaledImageSize = CGSize(width: size.width * scaleFactor, height: size.height * scaleFactor)
        
        let renderer = UIGraphicsImageRenderer(size: scaledImageSize)
        return renderer.image { _ in
            self.draw(in: CGRect(origin: .zero, size: scaledImageSize))
        }
    }
    
    func padToSquare(targetSize: CGSize) -> UIImage? {
        let renderer = UIGraphicsImageRenderer(size: targetSize)
        return renderer.image { context in
            let originX = (targetSize.width - size.width) / 2
            let originY = (targetSize.height - size.height) / 2
            self.draw(in: CGRect(x: originX, y: originY, width: size.width, height: size.height))
        }
    }
    
    func resizedAndPadded(to targetSize: CGSize) -> UIImage? {
        guard let resizedImage = self.resizeMaintainingAspectRatio(targetSize: targetSize) else { return nil }
        return resizedImage.padToSquare(targetSize: targetSize)
    }
    
}
extension UIImage {
    static func initFrom(pixelBuffer: CVPixelBuffer,orientation:  UIImage.Orientation) -> UIImage? {
        var cgImage: CGImage?
        VTCreateCGImageFromCVPixelBuffer(pixelBuffer, options: nil, imageOut: &cgImage)
        
        if let cgImage = cgImage {
            let image = UIImage(cgImage: cgImage, scale: 1, orientation: orientation)
            return image
        } else {
            return nil
        }
    }
}
