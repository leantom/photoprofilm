//
//  Utils+Extension.swift
//  PhotoProFilm
//
//  Created by QuangHo on 1/10/24.
//
import UIKit
import AVFoundation
import CoreImage
import CoreImage.CIFilterBuiltins
import CoreML
import Vision
import PixelEnginePackage
func filterAll() {
    
    guard let ci = UIImage(named: "sample") else {return}
    guard let newSize = ci.resizedImage(newSize: CGSize(width: 200, height: 250)) else {return}
    
    var cubeInfos:[FilterColorCubeInfo] = []
    for collection in DataColor.shared.collections {
        for cube in collection.cubeInfos {
            cubeInfos.append(cube)
            let cube = FilterColorCube(name: cube.name, identifier: cube.identifier, lutImage: UIImage(named: cube.lutImage)!, dimension: 64)
            if let cubeSourceCI = convertToCIImage(from: newSize) {
                let preview = PreviewFilterColorCube(sourceImage: cubeSourceCI, filter: cube)
                guard let cgimage = convertCIImageToCGImage(ciImage: preview.image) else {
                    print("Error: Unable to convert CIImage to CGImage")
                    return
                }
                let processedImage = UIImage(cgImage: cgimage)
                uploadImageToFirebase(image: processedImage, imageName: cube.name) { result in
                    
                }
            }
            
        }
    }
}

func convertCIImageToCGImage(ciImage: CIImage) -> CGImage? {
    // Create a CIContext to render the CIImage
    let context = CIContext()
    
    // Render the CIImage to a CGImage
    if let cgImage = context.createCGImage(ciImage, from: ciImage.extent) {
        return cgImage
    }
    
    // If conversion fails, return nil
    return nil
}

func saveImageToPhotoAlbum(image: UIImage) {
    image.saveImageToPhotoAlbum(image: image)
}


func convertToCIImage(from uiImage: UIImage) -> CIImage? {
    // Try to use the UIImage's existing CIImage if available
    if let ciImage = uiImage.ciImage {
        return ciImage
    }
    
    // If the UIImage doesn't contain a CIImage, create a new CIImage from its CGImage
    if let cgImage = uiImage.cgImage {
        return CIImage(cgImage: cgImage)
    }
    
    // If neither CIImage nor CGImage is available, return nil
    return nil
}
