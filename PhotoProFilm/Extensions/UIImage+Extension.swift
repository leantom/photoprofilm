//
//  UIImage+Extension.swift
//  PhotoProFilm
//
//  Created by QuangHo on 1/7/24.
//

import Foundation
import UIKit

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
