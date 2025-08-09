//
//  TestCameraView.swift
//  PhotoProFilm
//
//  Created by QuangHo on 12/11/24.
//

import SwiftUI
import AVFoundation
import CoreImage
import CoreImage.CIFilterBuiltins
import PixelEnginePackage
import CoreMotion

struct TestCameraApplyView: View {
    @State private var image: UIImage?
    @State private var cubeSelected: FilterColorCube?
    @State private var isStopCamera = false
    @State private var isFrontCamera = true
    @State private var isFlashOn: Bool = false
    @State private var zoomFactor: CGFloat = 1.0

    var body: some View {
        CameraView(image: $image,
                   cube: $cubeSelected,
                   isStopCamera: $isStopCamera,
                   isFrontCamera: $isFrontCamera,
                   isFlashOn: $isFlashOn,
                   zoomFactor: $zoomFactor)
            .edgesIgnoringSafeArea(.all)
    }
}

#Preview {
    TestCameraApplyView()
}
