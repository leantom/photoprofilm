//
//  CameraPreviewView.swift
//  PhotoProFilm
//
//  Created by QuangHo on 12/11/24.
//

import Foundation
import UIKit
import AVFoundation

class CameraPreviewView: UIView {
    var previewLayer: AVCaptureVideoPreviewLayer {
        return layer as! AVCaptureVideoPreviewLayer
    }

    var pinchGestureRecognizer: UIPinchGestureRecognizer?
    var currentDevice: AVCaptureDevice?
    var lastZoomFactor: CGFloat = 1.0 // Add this property
        
    override class var layerClass: AnyClass {
        return AVCaptureVideoPreviewLayer.self
    }

    // Initializer without session and device
    override init(frame: CGRect) {
        super.init(frame: frame)
        // Initial setup if needed
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    // Method to configure the view when session and device are ready
    func configure(session: AVCaptureSession, device: AVCaptureDevice) {
        self.currentDevice = device
        previewLayer.session = session
        previewLayer.videoGravity = .resizeAspectFill

        // Add gesture recognizer if not already added
        if pinchGestureRecognizer == nil {
            pinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch(_:)))
            self.addGestureRecognizer(pinchGestureRecognizer!)
        }
    }

    @objc func handlePinch(_ pinch: UIPinchGestureRecognizer) {
            guard let device = currentDevice else { return }
            
            switch pinch.state {
            case .began:
                // Store the initial zoom factor when the pinch begins
                lastZoomFactor = device.videoZoomFactor
            case .changed:
                do {
                    try device.lockForConfiguration()
                    
                    // Calculate the new zoom factor based on the initial zoom factor and pinch scale
                    var zoomFactor = lastZoomFactor * pinch.scale
                    
                    // Clamp the zoom factor to the device's permissible zoom range
                    zoomFactor = max(1.0, min(zoomFactor, device.activeFormat.videoMaxZoomFactor))
                    
                    device.videoZoomFactor = zoomFactor
                    device.unlockForConfiguration()
                } catch {
                    print("Error locking configuration: \(error)")
                }
            case .ended, .cancelled, .failed:
                // Gesture ended, update the last zoom factor to the current zoom
                lastZoomFactor = device.videoZoomFactor
            default:
                break
            }
        }
}
