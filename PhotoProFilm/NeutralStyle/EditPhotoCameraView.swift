//
//  EditPhotoCameraView.swift
//  PhotoProFilm
//
//  Created by QuangHo on 7/10/24.
//

//
//  CameraView.swift
//  PhotoProFilm
//
//  Created by QuangHo on 1/10/24.
//

import SwiftUI
import AVFoundation
import CoreImage
import CoreImage.CIFilterBuiltins
import CoreML
import Vision
import PixelEnginePackage
import GoogleMobileAds
struct EditPhotoCameraView: View {
    @State private var image: UIImage?
    @State private var inputImage: UIImage?
    @State private var afterFilterImage: UIImage?
    
    @State var listCubeCollection: [Collection] = []
    @State var listCinematic: [FilterColorCubeInfo] = []
    @State var cubeSelected: FilterColorCube?
    @State var styleSelected: Collection?
    @State var aspectRatio: AspectRatio = .ratio9_16 // Default aspect ratio
    
    @State var isStopCamera = false
    @State var isSelectRatio = false
    @State var isFlashOn: Bool = false
    @State var isTimeOn: Bool = false
    
    @State var isTurnOnFilter = false
    @State var isFrontCamera = true
    @State var imageCaptureFinal: UIImage?
    @State var isLoading: Bool = false
    @State var countdownTime: Int = 0
    @State var isCountingDown: Bool = false
    @State var isEditPhoto: Bool = false
    @State var isSelectedPhoto: Bool = false
    @State private var isShowAds: Bool = false
    @State private var sourceType: UIImagePickerController.SourceType = .photoLibrary
    @State var isExportedDone: Bool = false
    var listBW: [BWFilter] = [classicBW, highContrastBW, softDreamyBW, moodyDarkBW, filmNoirBW, filmNoirBW2]
    
    let imageWidth = UIScreen.main.bounds.width * 0.11 // Set width to 20% of screen width
    @State var imageHeight = UIScreen.main.bounds.width * 0.11 // Calculate height based on 5:7 ratio
    @Binding var path: NavigationPath
    var body: some View {
        GeometryReader { geometry in
            let adSize = GADCurrentOrientationAnchoredAdaptiveBannerAdSizeWithWidth(geometry.size.width)
            ZStack {
                VStack {
                    VStack {
                        if let image = image, isLoading == false {
                            Image(uiImage: image)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .clipped()
                        } else {
                            
                            LoadingView()
                        }
                        
                    }
                    .frame(width: UIScreen.main.bounds.width, height: getCameraViewHeight())
                    .padding(.top, aspectRatio == .ratio1_1 ? 85 : 5)
                    Spacer()
                }
                VStack(alignment: .center) {
                    HStack {
                        // Flash button (left icon)
                        Button(action: {
                            // Flash action here
                            path.removeLast()
                        }) {

                            Text("Close")
                                .font(.system(size: 13, weight: .regular, design: .monospaced))
                                .foregroundColor(isEditPhoto ? .yellow :.white)
                            
                        }
                        .frame(width: 70, height: 40)
                        Spacer()
                        
                        Button {
                           //MARK: -- download
                            if let photo = self.afterFilterImage {
                                saveImageToPhotoAlbum(image: photo)
                            }
                            isExportedDone = true
                            
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                isExportedDone = false
                            }
                        } label: {
                            Image("icon-download")
                                .resizable()
                                .frame(width: 30, height: 30)
                        }
                        .frame(width: 50, height: 40)
                        
                        Spacer()
                        
                        // Right icon (right icon)
                        Button(action: {
                            // Right action here
                            isTurnOnFilter.toggle()
                            isSelectRatio = false
                            if isTurnOnFilter {
                                image = inputImage
                            } else {
                                image = afterFilterImage
                            }
                        }) {
                            Image(systemName: "paintbrush.fill")
                                .font(.system(size: 18))
                                .foregroundColor(isTurnOnFilter ? .yellow :.white)
                                .aspectRatio(contentMode: .fit)
                            
                        }
                        .frame(width: 50, height: 40)
                    }
                    Spacer()
                    if isSelectRatio == false {
                        VStack {
                            ScrollView(.horizontal, showsIndicators: false) {
                                LazyHGrid(rows: [GridItem(.fixed(100))],  spacing: 20) {
                                    ForEach(listCubeCollection) { collection in
                                        Text(collection.name)
                                            .foregroundColor(styleSelected?.name == collection.name ? .yellow : .white)
                                            .font(.system(size: 15, weight: .medium))
                                            .fontWidth(.compressed)
                                            .padding([.leading, .trailing],  5)
                                            .cornerRadius(10)
                                            .onTapGesture {
                                                listCinematic = collection.cubeInfos
                                                styleSelected = collection
                                                AppState.shared.currentStyle = ColorStyle(rawValue: collection.name) ?? .retro
                                            }
                                    }
                                }
                                .padding([.leading, .trailing], 10)
                            }
                            .frame(width: UIScreen.main.bounds.width - 10, height: 30)
                            ScrollView(.horizontal, showsIndicators: false) {
                                LazyHGrid(rows: [GridItem(.fixed(100))],  spacing: 20) {
                                    
                                    
                                    ForEach(listCinematic) { cinematic in
                                        ZStack {
                                            Image(cinematic.name)
                                                .resizable()
                                                .foregroundColor(.white)
                                                .frame(width: imageWidth, height: imageHeight)
                                                .cornerRadius(10)
                                                .clipped()
                                                .scaleEffect(cubeSelected?.name == cinematic.name ? 1.1 : 1.0)
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 10)
                                                        .stroke(cubeSelected?.name == cinematic.name ? Color.yellow : Color.clear, lineWidth: 1)
                                                )
                                            
                                                .onTapGesture {
                                                    var cube = FilterColorCube(name: cinematic.name, identifier: cinematic.identifier, lutImage: UIImage(named: cinematic.lutImage)!, dimension: 64)
                                                    if cube.name.contains("BW") {
                                                        cube.amount = 0.5
                                                    }
                                                    withAnimation {
                                                        self.cubeSelected = cube
                                                        AppState.shared.cubeSelected = cube
                                                        applyPhoto()
                                                    }
                                                    
                                                }
                                            if cinematic.isHot {
                                                Text("H")
                                                    .font(.system(size: 10, weight: .bold))
                                                    .frame(width: 20, height: 20)
                                                    .background(.red.opacity(0.65))
                                                    .clipShape(Circle())
                                                    .foregroundStyle(.white)
                                                    .offset(x: 15,y: -25)
                                            }
                                        }
                                        
                                    }
                                }
                                .padding([.leading, .trailing], 10)
                            }
                            .frame(width: UIScreen.main.bounds.width - 10, height: imageHeight * 1.15)
                        }
                        .padding(.bottom, 30)
                    } else {
                        VStack {
                            Spacer()
                            
                            ControlPanelView(flashAction: {
                                
                            }, timerAction: { duration in
                                self.countdownTime = duration
                            }, aspectRatio: $aspectRatio, isTimerOn: $isTimeOn)
                            .frame(maxWidth: UIScreen.main.bounds.width)
                            .transition(.move(edge: .bottom))
                        }
                        
                    }
                    
                    if isShowAds {
                        BannerView(adSize)
                          .frame(height: 50)
                    }
                   
                }
                .frame(maxWidth: UIScreen.main.bounds.width, maxHeight: .infinity, alignment: .top)
                .onChange(of: aspectRatio) {  newValue in
                    withAnimation {
                        isSelectRatio.toggle()
                    }
                }
                if isExportedDone {
                    Button(action: {
                        // Action for the button
                    }) {
                        HStack {
                            Image(systemName: "checkmark")
                                .foregroundColor(.white)
                            Text("Saved to gallery")
                                .foregroundColor(.white)
                                .font(.system(size: 16, weight: .semibold))
                        }
                        .padding()
                        .background(Color.purple)
                        .cornerRadius(12)
                        .shadow(radius: 5)
                    }
                    .transition(.opacity)
                }
            }
        }
        .background(.black)
        .onAppear {
            listCubeCollection = DataColor.shared.collections
            imageHeight = imageWidth * (7 / 5)
            if self.styleSelected != nil {
                return
            }
            
            if let listCinematic = DataColor.shared.collections.filter({ collection in
                return collection.colorType == .retro
            }).first?.cubeInfos {
                self.listCinematic = listCinematic
                if let item = self.listCinematic.first {
                    let cube = FilterColorCube(name: item.name, identifier: item.identifier, lutImage: UIImage(named: item.lutImage)!, dimension: 64)
                    self.cubeSelected = cube
                    AppState.shared.cubeSelected = cube
                    
                }
            }
            
            styleSelected = listCubeCollection.first
            AppState.shared.currentStyle = ColorStyle(rawValue: styleSelected?.name ?? "retro") ?? .retro
            image = AppState.shared.photoEdit
            inputImage = image
#if RELEASE
            GoogleMobileAdsConsentManager.shared.gatherConsent { consentError in
                if let consentError {
                    print("Error: \(consentError.localizedDescription)")
                }
                GoogleMobileAdsConsentManager.shared.startGoogleMobileAdsSDK()
                self.isShowAds = true
            }
            GoogleMobileAdsConsentManager.shared.startGoogleMobileAdsSDK()
#endif
        }
        .sheet(isPresented: $isSelectedPhoto, onDismiss: loadImage) {
            CymeImagePicker(image: $image, sourceType: sourceType)
        }
    }
    
    func loadImage() {
        guard let inputImage = inputImage else { return }
        image = inputImage
    }
    
    // Function to calculate the height of the camera view based on the aspect ratio
    private func getCameraViewHeight() -> CGFloat {
        let screenWidth = UIScreen.main.bounds.width
        switch aspectRatio {
        case .ratio4_3:
            if UIDevice.current.userInterfaceIdiom == .pad {
                return screenWidth * 1.1
            }
            return screenWidth * (4 / 3) // Height for 4:3
        case .ratio9_16:
            if UIDevice.current.userInterfaceIdiom == .pad {
                return screenWidth * 1.2
            }
            return screenWidth * 1.6 // Height for 9:16
        case .ratio1_1:
            return screenWidth
        }
    }

    
    func applyPhoto() {
        // Trigger haptic feedback
        let impactFeedbackgenerator = UIImpactFeedbackGenerator(style: .medium)
        impactFeedbackgenerator.impactOccurred()
        
        isLoading = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            isLoading = false
        }
        guard let image = self.inputImage else { return }
        
        guard let cube = cubeSelected else {return}
        
        let convertCiimage = convertUItoCI(from: image)
        var newImage: UIImage?
        
        if cube.name.contains("retro") {
           newImage = applyPhotoToRetro(ciiImage: convertCiimage)
        } else if cube.name.contains("BW") {
            newImage = applyPhotoToBW(ciiImage: convertCiimage)
        } else {
            let ciiImage = cube.apply(to: convertCiimage, sourceImage: convertCiimage)
            guard  let cgImage = convertCIImageToCGImage(ciImage: ciiImage) else {return}
            newImage = UIImage(cgImage: cgImage)
            
        }
        
        guard let newImage = newImage else {return}
       
        self.image = newImage
        self.afterFilterImage = newImage
    }
    
    func applyPhotoToRetro(ciiImage: CIImage) -> UIImage? {
        guard let cube = cubeSelected else {return nil}
        guard let textUIImage = UIImage(named: cube.name + "_texture") else { return nil }
        let textureImage: CIImage? = CIImage(image: textUIImage)
        if let textureImage = textureImage {
            // Resize texture image to match the camera frame size
            let cameraImageSize = ciiImage.extent.size
            let resizedTexture = textureImage.transformed(by: CGAffineTransform(scaleX: cameraImageSize.width / textureImage.extent.width, y: cameraImageSize.height / textureImage.extent.height))
            
            // Apply the blending filter (multiply blend mode in this case)
            let blendFilter = CIFilter.multiplyCompositing()
            blendFilter.inputImage = ciiImage
            blendFilter.backgroundImage = resizedTexture
            
            if let blendedImage = blendFilter.outputImage {
                // Create final image after blending
                //let finalImage = cube.apply(to: blendedImage, sourceImage: blendedImage)
                let context = CIContext()
                
                if let cgImage = context.createCGImage(blendedImage, from: blendedImage.extent) {
                    return  UIImage(cgImage: cgImage)
                }
                
            }
            return nil
        }
        return nil
    }
    
    func applyPhotoToBW(ciiImage: CIImage) -> UIImage? {
        guard let cube = cubeSelected else {return nil}
        let bwFilterObject = listBW.first { $0.name == cube.name }
        guard let bwFilterObject else { return nil}
        
        let bwFilter = CIFilter.photoEffectMono()
        
        bwFilter.inputImage = ciiImage
        
        if let bwImage = bwFilter.outputImage {
            // Step 2: Adjust Brightness and Contrast
            let brightnessAndContrastFilter = CIFilter.colorControls()
            brightnessAndContrastFilter.inputImage = bwImage
            brightnessAndContrastFilter.brightness = bwFilterObject.brightness // Adjust brightness (-1.0 to 1.0)
            brightnessAndContrastFilter.contrast = bwFilterObject.contrast  // Adjust contrast (0.0 to 4.0)
            
            if let brightContrastImage = brightnessAndContrastFilter.outputImage {
                // Step 3: Adjust Exposure
                let exposureFilter = CIFilter.exposureAdjust()
                exposureFilter.inputImage = brightContrastImage
                exposureFilter.ev = bwFilterObject.exposure // Adjust exposure (-10.0 to 10.0)
                let context = CIContext()
                // Step 4: Get the final image
                if let finalImage = exposureFilter.outputImage,
                   let cgImage = context.createCGImage(finalImage, from: finalImage.extent) {
                   let image =  UIImage(cgImage: cgImage)
                    return image
                }
            }
        }
        return nil
    }
    
    func getCorrectImageOrientation() -> UIImage.Orientation {
        let deviceOrientation = UIDevice.current.orientation
        let isUsingFrontCamera = isFrontCamera
        
        switch deviceOrientation {
        case .portrait:
            return isUsingFrontCamera ? .leftMirrored : .right
        case .portraitUpsideDown:
            return isUsingFrontCamera ? .rightMirrored : .left
        case .landscapeLeft:
            return isUsingFrontCamera ? .downMirrored : .up
        case .landscapeRight:
            return isUsingFrontCamera ? .upMirrored : .down
        default:
            // Default to portrait if orientation is not recognized
            return isUsingFrontCamera ? .leftMirrored : .right
        }
    }
    
}
struct WrapperEditPhotoCameraView : View {
    @State var path = NavigationPath()
    var body: some View {
        EditPhotoCameraView(path: $path)
    }
}
#Preview {
    WrapperEditPhotoCameraView()
}
