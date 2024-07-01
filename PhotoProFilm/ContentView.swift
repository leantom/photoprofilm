import SwiftUI
import CoreImage
import CoreImage.CIFilterBuiltins
import Firebase

struct ContentView: View {
    @State private var image: Image?
    @State private var showingImagePicker = false
    @State private var inputImage: UIImage?
    @State private var isShowPreviewImage = false
    @State var imageDetail: UIImage?
    
    let context = CIContext()
    
    var body: some View {
        NavigationStack {
            if AppSetting.checkisFirstLogined() {
                WrapperSplashScreen()
            } else if AppSetting.checkLogined() && Auth.auth().currentUser != nil {
                CategoryImageView()
            } else {
                LoginView()
            }
        }
        
    }
    
    func loadImage() {
        guard let inputImage = inputImage else { return }
        image = Image(uiImage: inputImage)
    }
    
    func applyFilter() {
        guard let inputImage = inputImage else { return }
        let beginImage = CIImage(image: inputImage)
        let filter = CIFilter.photoEffectNoir() // Using a Chrome effect for a film style
        filter.inputImage = beginImage
        
        guard let outputImage = filter.outputImage,
              let cgimg = context.createCGImage(outputImage, from: outputImage.extent) else { return }
        
        let processedImage = UIImage(cgImage: cgimg)
        image = Image(uiImage: processedImage)
    }
    
    func addSoftNoiseFilter(to inputImage: UIImage) -> UIImage? {
        // Convert UIImage to CIImage
        guard let ciInputImage = CIImage(image: inputImage) else {
            return nil
        }
        
        // Create the noise filter
        let noiseFilter = CIFilter(name: "CIRandomGenerator")!
        
        // Crop the noise image to match the input image size
        let noiseImage = noiseFilter.outputImage?.cropped(to: ciInputImage.extent)
        
        // Reduce the opacity of the noise image
        let alphaValue: CGFloat = 0.1 // Adjust this value to control the softness of the noise
        let transparentFilter = CIFilter(name: "CIConstantColorGenerator", parameters: [kCIInputColorKey: CIColor(red: 0, green: 0, blue: 0, alpha: alphaValue)])!
        let transparentImage = transparentFilter.outputImage?.cropped(to: ciInputImage.extent)
        let noiseWithOpacity = noiseImage?.applyingFilter("CISourceOverCompositing", parameters: [kCIInputBackgroundImageKey: transparentImage!])
        
        // Blend the noise with the original image
        let blendFilter = CIFilter(name: "CISoftLightBlendMode")!
        blendFilter.setValue(noiseWithOpacity, forKey: kCIInputImageKey)
        blendFilter.setValue(ciInputImage, forKey: kCIInputBackgroundImageKey)
        
        // Get the output image
        guard let outputCIImage = blendFilter.outputImage else {
            return nil
        }
        
        // Convert CIImage to UIImage
        let context = CIContext(options: nil)
        if let cgImage = context.createCGImage(outputCIImage, from: outputCIImage.extent) {
            let finalImage = UIImage(cgImage: cgImage)
            return finalImage
        }
        
        return nil
    }
    
    
    
    
    
    
    
    
}
