import CoreML
import Vision
import UIKit
import PixelEnginePackage
enum StyleAI {
    case Vivid
    case Sketch
    case Renaissance
    case Film
    case Vintage
    case HighSatuation
    case None
}

class ImageClassifier {
    
    lazy var filmModel: FilmModel? = {
        let model = try? FilmModel(configuration: loadConfigModel())
        return model
    }()
    
    lazy var  vividModel: VividModel? = {
        let modelConfig = MLModelConfiguration()
        
        let model = try? VividModel(configuration: loadConfigModel())
        return model
    }()
    
    lazy var vintageModel: VintageModel? = {
        let modelConfig = MLModelConfiguration()
        
        let model = try? VintageModel(configuration: loadConfigModel())
        return model
    }()
    
    lazy var  sketchModel: SketchModel? = {
        let modelConfig = MLModelConfiguration()
        
        let model = try? SketchModel(configuration: loadConfigModel())
        return model
    }()
    lazy var  renaissanceModel: Renaissance? = {
        let modelConfig = MLModelConfiguration()
        
        let model = try? Renaissance(configuration: loadConfigModel())
        return model
    }()
    lazy var highSatuationModel: HighSatuation? = {
        let modelConfig = MLModelConfiguration()
        
        let model = try? HighSatuation(configuration: loadConfigModel())
        return model
    }()
    
    private func initializeHighSatuationModel() -> HighSatuation? {
        let modelConfig = MLModelConfiguration()
        return try? HighSatuation(configuration: loadConfigModel())
    }
    
    private func initializeFilmModel() -> FilmModel? {
        let modelConfig = MLModelConfiguration()
        return try? FilmModel(configuration: loadConfigModel())
    }
    
    private func initializeVividModel() -> VividModel? {
        let modelConfig = MLModelConfiguration()
        return try? VividModel(configuration: loadConfigModel())
    }
    
    private func initializeVintageModel() -> VintageModel? {
        let modelConfig = MLModelConfiguration()
        return try? VintageModel(configuration: loadConfigModel())
    }
    
    private func initializeSketchModel() -> SketchModel? {
        let modelConfig = MLModelConfiguration()
        return try? SketchModel(configuration: loadConfigModel())
    }
    
    private func initializeRenaissanceModelModel() -> Renaissance? {
        let modelConfig = MLModelConfiguration()
        return try? Renaissance(configuration: loadConfigModel())
    }
    
    
    func loadConfigModel() -> MLModelConfiguration {
        let modelConfig = MLModelConfiguration()
        modelConfig.computeUnits = .all
        return modelConfig
    }
    
    
    init() {
        // Replace `YourModel` with the name of your .mlmodel file's generated class
        
    }
    
    
    func applyModel(image: UIImage,
                    style: StyleAI) -> UIImage? {
        return autoreleasepool {
            let sizeOriginal = image.size
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
            
            guard let newSize = image.downsizedImage(by: nDownsize) else { return nil }
            guard let cvPixel = newSize.pixelBuffer() else {return nil}
            do {
                var ima :  UIImage?
                switch style {
                case .HighSatuation:
                    if highSatuationModel == nil {highSatuationModel = self.initializeHighSatuationModel()}
                    let result = try highSatuationModel?.prediction(image: cvPixel)
                    guard let styled = result?.stylizedImage else {
                        return nil
                    }
                    
                    let ciiImage = CIImage(cvPixelBuffer: styled)
                    
                    ima = createCGImageExample(inputImage: ciiImage)
                    
                    print(ima as Any)
                case .Vivid:
                    if vividModel == nil {vividModel = self.initializeVividModel()}
                    let result = try vividModel?.prediction(image: cvPixel)
                    guard let styled = result?.stylizedImage else {
                        return nil
                    }
                    
                    let ciiImage = CIImage(cvPixelBuffer: styled)
                    
                    ima = createCGImageExample(inputImage: ciiImage)
                    
                    print(ima as Any)
                case .Sketch:
                    if sketchModel == nil {sketchModel = self.initializeSketchModel()}
                    let result = try sketchModel?.prediction(image: cvPixel)
                    guard let styled = result?.stylizedImage else {
                        return nil
                    }
                    
                    let ciiImage = CIImage(cvPixelBuffer: styled)
                    
                    ima = createCGImageExample(inputImage: ciiImage)
                    
                    print(ima as Any)
                case .Renaissance:
                    if renaissanceModel == nil {renaissanceModel = self.initializeRenaissanceModelModel()}
                    let result = try renaissanceModel?.prediction(image: cvPixel)
                    guard let styled = result?.stylizedImage else {
                        return nil
                    }
                    
                    let ciiImage = CIImage(cvPixelBuffer: styled)
                    
                    ima = createCGImageExample(inputImage: ciiImage)
                    
                    print(ima as Any)
                case .Film:
                    if filmModel == nil {filmModel = self.initializeFilmModel()}
                    let result = try filmModel?.prediction(image: cvPixel)
                    guard let styled = result?.stylizedImage else {
                        return nil
                    }
                    
                    let ciiImage = CIImage(cvPixelBuffer: styled)
                    
                    ima = createCGImageExample(inputImage: ciiImage)
                    
                    print(ima as Any)
                case .Vintage:
                    if vintageModel == nil {vintageModel = self.initializeVintageModel()}
                    let result = try vintageModel?.prediction(image: cvPixel)
                    guard let styled = result?.stylizedImage else {
                        return nil
                    }
                    
                    let ciiImage = CIImage(cvPixelBuffer: styled)
                    
                    ima = createCGImageExample(inputImage: ciiImage)
                    
                    print(ima as Any)
                default : break
                }
                return ima
                
            } catch let err{
                print(err.localizedDescription)
            }
            return nil
        }
        
    }
    
    func releaseMemory() {
        self.vividModel = nil
        self.vintageModel = nil
        self.sketchModel = nil
        self.filmModel = nil
        self.renaissanceModel = nil
        self.highSatuationModel = nil
    }
    
    func createCGImageExample(inputImage: CIImage) -> UIImage{
        
        // Step 2: Create a CIContext
        let context = CIContext(options: nil)
        
        // Step 3: Create a CGImage from the CIImage
        if let cgImage = context.createCGImage(inputImage, from: inputImage.extent) {
            // Step 4: Use the CGImage (e.g., convert to UIImage and display in UIImageView)
            let uiImage = UIImage(cgImage: cgImage)
            return uiImage
        } else {
            fatalError("Unable to create CGImage")
        }
    }
    
    
    func applyFilter(image: CIImage?) -> UIImage?{
        if let cubeSourceCI: CIImage = image
        {
            let neutralLUT = UIImage(named: "lut-normal")!
            let neutralCube = FilterColorCube(
                name: "Neutral",
                identifier: "neutral",
                lutImage: neutralLUT,
                dimension: 64
            )
            
            let preview = PreviewFilterColorCube(sourceImage: cubeSourceCI, filter: neutralCube)
            return UIImage(cgImage: preview.cgImage)
        }
        return  nil
    }
    
    
    
    
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
}
