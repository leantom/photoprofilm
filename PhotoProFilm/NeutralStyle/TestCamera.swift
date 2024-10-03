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
    @State private var selectedImage: UIImage? = UIImage(named: "IMG_0795_1") // Placeholder image
    @State private var textureImage: UIImage? = UIImage(named: "yel_light")
    @State private var textureImage2: UIImage? = UIImage(named: "yel_light")
    
    // Your texture image
    @State var isChange: Bool = false
    @State var issoft: Bool = false
    
    var body: some View {
        VStack {
            if let selectedImage = selectedImage, let textureImage = textureImage, isChange {
                // Show the blended result of the photo and texture
                
                Image(uiImage: selectedImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .overlay(
                        Image(uiImage: textureImage)
                            .resizable()
                            .blendMode(issoft ? .softLight : .multiply )
                            .clipped()
                    )
            } else {
                Image(uiImage: selectedImage!)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            }
            HStack {
                Button {
                    issoft.toggle()
                } label: {
                    Text("soft light")
                }
                
                Button {
                    isChange.toggle()
                } label: {
                    Text("change")
                }
            }

        }
        .padding()
    }
}

#Preview {
    TestCameraView()
}
