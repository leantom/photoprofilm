//
//  TestCamera.swift
//  PhotoProFilm
//
//  Created by QuangHo on 2/10/24.
//
import SwiftUI

struct TestCameraView: View {
    @State private var image: UIImage?
    @State private var isStopCamera = false
    @State private var isFrontCamera = false
    
    var body: some View {
        VStack {
            
            CameraView(image: $image, cube: .constant(nil), isStopCamera: $isStopCamera, isFrontCamera: $isFrontCamera, isFlashOn: $isFrontCamera)
                .frame(height: 400)
            Button(action: {
                // Toggle between front and back camera
                isFrontCamera.toggle()
            }) {
                Text("Switch Camera")
            }
        }
        .overlay {
            
        }
    }
}
