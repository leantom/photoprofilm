//
//  CameraViewStyle.swift
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

let classicBW = BWFilter(name: "BW1", brightness: 0.0, contrast: 1.5, exposure: 0.0)
let highContrastBW = BWFilter(name: "BW2", brightness: 0.0, contrast: 3.0, exposure: 0.0)
let softDreamyBW = BWFilter(name: "BW3", brightness: 0.2, contrast: 1.2, exposure: 0.5)
let moodyDarkBW = BWFilter(name: "BW4", brightness: -0.2, contrast: 1.8, exposure: -0.5)
let filmNoirBW = BWFilter(name: "BW5", brightness: -0.1, contrast: 2.5, exposure: -0.3)
let filmNoirBW2 = BWFilter(name: "BW6", brightness: -0.1, contrast: 2.5, exposure: -0.5)

struct CameraView: UIViewRepresentable {
    @Binding var image: UIImage?
    @Binding var cube: FilterColorCube?
    @Binding var isStopCamera: Bool
    @Binding var isFrontCamera: Bool
    @Binding var isFlashOn: Bool
    
    var listBW: [BWFilter] = [classicBW, highContrastBW, softDreamyBW, moodyDarkBW, filmNoirBW, filmNoirBW2]
    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        
        // Set up the preview layer
        context.coordinator.previewLayer.frame = view.bounds
        view.layer.addSublayer(context.coordinator.previewLayer)
        
        // Start the camera session
        DispatchQueue.main.async {
            context.coordinator.startCamera(isFrontCamera: isFrontCamera) // Start the camera on the main thread
        }
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        context.coordinator.updateColorFilter(cube: cube)
        
        // Stop or start the camera based on isStopCamera
        if isStopCamera {
            context.coordinator.stopCamera()
        } else {
            context.coordinator.startCamera(isFrontCamera: isFrontCamera)
        }
        
        // Switch between front and back camera if changed
        if context.coordinator.isFrontCamera != isFrontCamera {
            context.coordinator.switchCamera(isFrontCamera: isFrontCamera)
        }
        context.coordinator.toggleFlash(isOn: isFlashOn)
        
    }
    
    class Coordinator: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
        var parent: CameraView
        var isFrontCamera: Bool = false
        var captureSession: AVCaptureSession!
        var previewLayer: AVCaptureVideoPreviewLayer!
        var videoOutput: AVCaptureVideoDataOutput!
        let context = CIContext()
        var currentDevice: AVCaptureDevice?
        var isFlasOn: Bool = false
        
        init(parent: CameraView) {
            self.parent = parent
            super.init()
            
            captureSession = AVCaptureSession()
            captureSession.sessionPreset = .photo
            previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            previewLayer.videoGravity = .resizeAspect
            videoOutput = AVCaptureVideoDataOutput()
        }
        
        func setupCamera(isFrontCamera: Bool) {
            captureSession.beginConfiguration()
            
            // Remove existing inputs
            if let currentInput = captureSession.inputs.first as? AVCaptureDeviceInput {
                captureSession.removeInput(currentInput)
            }
            
            // Setup the camera device (front or back)
            let cameraPosition: AVCaptureDevice.Position = isFrontCamera ? .front : .back
            guard let captureDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: cameraPosition),
                  let input = try? AVCaptureDeviceInput(device: captureDevice) else {
                captureSession.commitConfiguration()
                return
            }
            
            // Add the new input to the session
            if captureSession.canAddInput(input) {
                captureSession.addInput(input)
                currentDevice = captureDevice
            }
            
            // Add video output to the session
            videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
            if captureSession.canAddOutput(videoOutput) {
                captureSession.addOutput(videoOutput)
            }
            
            captureSession.commitConfiguration()
        }
        
        func switchCamera(isFrontCamera: Bool) {
            stopCamera()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                self.setupCamera(isFrontCamera: isFrontCamera)
                self.startCamera(isFrontCamera: isFrontCamera)
                self.isFrontCamera = isFrontCamera
            }
        }
        
        // Toggle the flash/torch mode based on the `isFlashOn` state
        func toggleFlash(isOn: Bool) {
            guard let device = currentDevice else { return }
            if !device.isFlashAvailable { return }
            
            if device.hasTorch {
                let modeCurrent = device.torchMode
                
                if modeCurrent == .on && isOn {
                    return
                }
                
                if modeCurrent == .off && !isOn {
                    return
                }
                
                
                do {
                    try device.lockForConfiguration()
                        
                    if isOn && device.isTorchAvailable {
                        device.torchMode = .on // Turn the torch on
                    } else {
                        device.torchMode = .off // Turn the torch off
                    }
                    
                    device.unlockForConfiguration()
                } catch {
                    print("Error while toggling flash: \(error)")
                }
            }
        }
        
        func startCamera(isFrontCamera: Bool) {
            if !captureSession.isRunning {
                setupCamera(isFrontCamera: isFrontCamera) // Ensure camera is configured before starting
                DispatchQueue.global(qos: .background).async {
                    self.captureSession.startRunning()
                }
            }
        }
        
        func stopCamera() {
            if captureSession.isRunning {
                captureSession.stopRunning()
            }
        }
        
        func updateColorFilter(cube: FilterColorCube?) {
            // Update color filter logic
        }
        
        func getCorrectImageOrientation() -> UIImage.Orientation {
            let deviceOrientation = UIDevice.current.orientation
            let isUsingFrontCamera = parent.isFrontCamera
            
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
        
        func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
            guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
            let cameraImage = CIImage(cvPixelBuffer: pixelBuffer)
            
            if let cube = parent.cube {
                
                if cube.name.contains("BW") {
                    // Apply the B&W filter (CIPhotoEffectMono)
                    let bwFilterObject = parent.listBW.first { $0.name == cube.name }
                    guard let bwFilterObject else { return }
                    
                    let bwFilter = CIFilter.photoEffectMono()
                    
                    bwFilter.inputImage = cameraImage
                    
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
                            
                            // Step 4: Get the final image
                            if let finalImage = exposureFilter.outputImage,
                               let cgImage = context.createCGImage(finalImage, from: finalImage.extent) {
                                DispatchQueue.main.async {
                                    let orientation = self.getCorrectImageOrientation()
                                    self.parent.image = UIImage(cgImage: cgImage, scale: 1, orientation: orientation)
                                }
                            }
                        }
                    }
                    return
                }
                
                let filteredImage = cube.apply(to: cameraImage, sourceImage: cameraImage)
                
                if let cgImage = context.createCGImage(filteredImage, from: filteredImage.extent) {
                    DispatchQueue.main.async {
                        let orientation = self.getCorrectImageOrientation()
                        self.parent.image = UIImage(cgImage: cgImage, scale: 1, orientation: orientation)
                    }
                }
            } else {
                // Display unfiltered camera image
                if let cgImage = context.createCGImage(cameraImage, from: cameraImage.extent) {
                    DispatchQueue.main.async {
                        let orientation = self.getCorrectImageOrientation()
                        self.parent.image = UIImage(cgImage: cgImage, scale: 1, orientation: orientation)
                    }
                }
            }
        }
    }
    // Function to get the correct orientation based on camera type and device orientation
    
}
