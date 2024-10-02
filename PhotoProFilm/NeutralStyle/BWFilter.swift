//
//  BWFilter.swift
//  PhotoProFilm
//
//  Created by QuangHo on 2/10/24.
//
import Foundation
import CoreImage

struct BWFilter {
    let name: String
    let brightness: Float
    let contrast: Float
    let exposure: Float
    
    // Function to apply the filter to a CIImage
    func apply(to image: CIImage) -> CIImage? {
        // Step 1: Apply B&W filter
        let bwFilter = CIFilter.photoEffectMono()
        bwFilter.inputImage = image
        
        guard let bwImage = bwFilter.outputImage else { return nil }
        
        // Step 2: Adjust brightness and contrast
        let brightnessAndContrastFilter = CIFilter.colorControls()
        brightnessAndContrastFilter.inputImage = bwImage
        brightnessAndContrastFilter.brightness = brightness
        brightnessAndContrastFilter.contrast = contrast
        
        guard let brightContrastImage = brightnessAndContrastFilter.outputImage else { return nil }
        
        // Step 3: Adjust exposure
        let exposureFilter = CIFilter.exposureAdjust()
        exposureFilter.inputImage = brightContrastImage
        exposureFilter.ev = exposure
        
        return exposureFilter.outputImage
    }
}
