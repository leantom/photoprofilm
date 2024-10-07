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

// Enum for Aspect Ratios
enum AspectRatio {
    case ratio4_3
    case ratio9_16
    case ratio1_1
}
struct CameraApplyView: View {
    @State private var image: UIImage?
    @State private var inputImage: UIImage?
    
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
    
    @State private var sourceType: UIImagePickerController.SourceType = .photoLibrary
    
    let imageWidth = UIScreen.main.bounds.width * 0.11 // Set width to 20% of screen width
    @State var imageHeight = UIScreen.main.bounds.width * 0.11 // Calculate height based on 5:7 ratio
    @Binding var path: NavigationPath
    var body: some View {
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
                    
                }.overlay(
                    CameraView(image: $image,
                               cube: $cubeSelected,
                               isStopCamera: $isStopCamera,
                               isFrontCamera: $isFrontCamera,
                               isFlashOn: $isFlashOn)
                                .padding()
                                .allowsHitTesting(false)
                )
                .frame(width: UIScreen.main.bounds.width, height: getCameraViewHeight())
                .padding(.top, aspectRatio == .ratio1_1 ? 85 : 5)
                Spacer()
            }
            VStack(alignment: .center) {
                HStack {
                    // Flash button (left icon)
                    Button(action: {
                        // Flash action here
                        isEditPhoto = true
                    }) {

                        Text(isEditPhoto ? "Edit" : "Photo")
                            .font(.system(size: 13, weight: .regular, design: .monospaced))
                            .foregroundColor(isEditPhoto ? .yellow :.white)
                        
                    }
                    .frame(width: 50, height: 50)
                    Spacer()
                    
                    Button {
                        isSelectRatio.toggle()
                    } label: {
                        Image(systemName: isSelectRatio ? "chevron.down" : "chevron.up")
                            .font(.system(size: 20, weight: .regular))
                            .foregroundStyle(isSelectRatio ? .yellow : .white)
                    }
                    .frame(width: 50, height: 50)
                    
                    Spacer()
                    
                    // Right icon (right icon)
                    Button(action: {
                        // Right action here
                        isTurnOnFilter.toggle()
                        isSelectRatio = false
                    }) {
                        Image(systemName: "wand.and.rays")
                            .font(.system(size: 20))
                            .foregroundColor(isTurnOnFilter ? .yellow :.white)
                            .aspectRatio(contentMode: .fit)
                        
                    }
                    .frame(width: 50, height: 50)
                }
                .padding()
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
                                            }
                                            
                                        }
                                }
                            }
                            .padding([.leading, .trailing], 10)
                        }
                        .frame(width: UIScreen.main.bounds.width - 10, height: imageHeight * 1.15)
                    }
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
                
                
                HStack {
                    // Left section with the first button
                    HStack {
                        Button {
                            if AppState.shared.photoEdit == nil {
                                AppState.shared.photoEdit = UIImage(imageLiteralResourceName: "img_0013")
                            }
                            path.append("savePhoto")
                        } label: {
                            if let capture = imageCaptureFinal {
                                Image(uiImage: capture)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 50, height: 72)
                                    .clipped()
                                    .cornerRadius(10)
                            } else {
                                Image("img_0013")
                                    .resizable()
                                    .frame(width: 50, height: 72)
                                    .clipped()
                                    .cornerRadius(10)
                            }
                        }
                        .padding(.bottom, 20)
                        Spacer() // Adds space to push the button to the left
                    }
                    
                    // Center section with the Shutter button
                    Button {
                        // Trigger haptic feedback
                        if isTimeOn {
                            startCountdown(duration: self.countdownTime)
                            return
                        }
                        let impactFeedbackgenerator = UIImpactFeedbackGenerator(style: .medium)
                        impactFeedbackgenerator.impactOccurred()
                        
                        isLoading = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            isLoading = false
                        }
                        guard let image = self.image else { return }
                        imageCaptureFinal = image
                        let orientation = self.getCorrectImageOrientation()
                        let imageOrientation = UIImage(cgImage: image.cgImage!, scale: 1, orientation: orientation)
                        AppState.shared.photoEdit = cropImageToAspectRatio(image: imageOrientation, aspectRatio: aspectRatio)
                    } label: {
                        Image("Shutter")
                            .frame(width: 72, height: 72)
                    }
                    .padding(.bottom, 20)
                    
                    // Right section with camera toggle and media selection buttons
                    HStack {
                        Spacer() // Adds space to push the buttons to the right
                        Button {
                            isFrontCamera.toggle()
                        } label: {
                            Image("changeCamera")
                                .foregroundStyle(.white)
                                .frame(width: 40, height: 40)
                        }
                        .frame(width: 50, height: 50)
                        
                        Button(action: {
                            isSelectedPhoto.toggle()
                        }) {
                            Image("img_media")
                        }
                        .frame(width: 50, height: 50)
                    }
                    .padding(.bottom, 20)
                }
                .padding()
                
            }
            .frame(maxWidth: UIScreen.main.bounds.width, maxHeight: .infinity, alignment: .top)
            .onChange(of: aspectRatio) {  newValue in
                withAnimation {
                    isSelectRatio.toggle()
                }
                
            }
            if isCountingDown {
                Text("\(countdownTime)")
                    .font(.system(size: 140, weight: .regular))
                    .foregroundColor(.white)
                    .transition(.opacity)
                    .animation(.easeInOut(duration: 0.5), value: isCountingDown)
            }
            
        }
        .background(.black)
        .onAppear {
            isStopCamera = false
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
#if DEBUG
            image = UIImage(named: "lands")
#endif
        }
        .onDisappear(perform: {
            isStopCamera.toggle()
        })
        .sheet(isPresented: $isSelectedPhoto, onDismiss: loadImage) {
            CymeImagePicker(image: $inputImage, sourceType: sourceType)
        }
    }
    
    func loadImage() {
        guard let inputImage = inputImage else { return }
        image = inputImage
        AppState.shared.photoEdit = inputImage
        isLoading.toggle()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5){
            path.append(Screen.editPhoto.rawValue)
            isLoading.toggle()
        }
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
    
    func startCountdown(duration: Int) {
        countdownTime = duration
        isCountingDown = true
        
        // Create a timer that updates every second
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            if self.countdownTime > 0 {
                self.countdownTime -= 1
            } else {
                timer.invalidate()
                self.isCountingDown = false
                self.capturePhoto() // Call your photo capture logic here
            }
        }
    }
    
    func capturePhoto() {
        // Trigger haptic feedback
        let impactFeedbackgenerator = UIImpactFeedbackGenerator(style: .medium)
        impactFeedbackgenerator.impactOccurred()
        
        isLoading = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            isLoading = false
        }
        guard let image = self.image else { return }
        imageCaptureFinal = image
        let orientation = self.getCorrectImageOrientation()
        let imageOrientation = UIImage(cgImage: image.cgImage!, scale: 1, orientation: orientation)
        AppState.shared.photoEdit = cropImageToAspectRatio(image: imageOrientation, aspectRatio: aspectRatio)
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
struct WrapperCameraView : View {
    @State var path = NavigationPath()
    var body: some View {
        CameraApplyView(path: $path)
    }
}
#Preview {
    WrapperCameraView()
}
