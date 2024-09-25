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
    case AbstractArt
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
    lazy var  renaissanceModel: ModifiedStyleTransferModel? = {
        let modelConfig = MLModelConfiguration()
        
        let model = try? ModifiedStyleTransferModel(configuration: loadConfigModel())
        return model
    }()
    lazy var highSatuationModel: HighSatuation? = {
        let modelConfig = MLModelConfiguration()
        
        let model = try? HighSatuation(configuration: loadConfigModel())
        return model
    }()
    
    private func initializeHighSatuationModel() -> HighSatuation? {
        return try? HighSatuation(configuration: loadConfigModel())
    }
    
    private func initializeFilmModel() -> FilmModel? {
        return try? FilmModel(configuration: loadConfigModel())
    }
    
    private func initializeVividModel() -> VividModel? {
        return try? VividModel(configuration: loadConfigModel())
    }
    
    private func initializeVintageModel() -> VintageModel? {
        return try? VintageModel(configuration: loadConfigModel())
    }
    
    private func initializeSketchModel() -> SketchModel? {
        return try? SketchModel(configuration: loadConfigModel())
    }
    
    private func initializeRenaissanceModelModel() -> ModifiedStyleTransferModel? {
        return try? ModifiedStyleTransferModel(configuration: loadConfigModel())
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
            guard let newImage = resizeAndCompressImage(image: image) else {return nil}
            
            guard let cvPixel = newImage.pixelBuffer() else {return nil}
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
