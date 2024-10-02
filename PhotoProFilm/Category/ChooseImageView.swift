//
//  ChooseImageView.swift
//  PhotoProFilm
//
//  Created by QuangHo on 19/6/24.
//

import SwiftUI

struct ChooseImageView: View {
    
    @Environment(\.dismiss) var dismiss
    @State var showingImagePicker = false
    @State var showingEdittor = false
    
    @State private var inputImage: UIImage?
    @State private var image: Image?
    
    @State private var sourceType: UIImagePickerController.SourceType = .photoLibrary
    @State private var showActionSheet = false

    
    @State private var showAlert = false // State variable for showing alert
    @State private var showImageSourceSheet = false
    var dimensionWidth = 0.88
    var dimensionHeight = 0.7
    
    @Binding var path: NavigationPath
    var body: some View {
        ZStack {
            VStack {
                HStack (alignment: .center){
                    ZStack {
                        HStack {
                            Button(action: {
                                dismiss()
                            }, label: {
                                Image(systemName: "arrow.left")
                                    .padding()
                                    .foregroundColor(.black)
                            })
                            Spacer()
                        }
                        
                        HStack {
                            
                            Text(AppState.shared.titleCategory)
                                .font(.title)
                                .fontWeight(.bold)
                                .fontWidth(.condensed)
                        }
                    }
                    
                }
                .padding(.top, 10)
                
                HStack (alignment: .center) {
                    VStack (alignment: .leading){
                        Text("Upload your photo")
                            .font(.headline)
                            .padding(.top, 2)
                            .fontWidth(.condensed)
                        
                        Text(AppState.shared.currentStyle.description)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .padding(.top, 2)
                            .fontWidth(.condensed)
                    }
                    Spacer()
                }
                .padding()
                
                Spacer()
                
                VStack {
                    if let img = inputImage {
                        ZStack {
                            Image(uiImage: img)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 300, height: 400)
                                .clipShape(Rectangle())
                                .cornerRadius(10)
                                .shadow(radius: 5)
                            
                            Button(action: {
                                withAnimation(.easeInOut) {
                                    inputImage = nil
                                    showingImagePicker = false
                                }
                                
                            }) {
                                VStack {
                                    Image(systemName: "xmark.circle.fill")
                                        .font(.system(size: 30))
                                        .foregroundColor(.red)
                                }
                                .background(.white)
                                .clipShape(Circle())
                                    
                            }
                            .offset(x: 140, y: -190)
                        }
                    } else {
                        VStack {
                            Image(systemName: "arrow.up.circle")
                                .resizable()
                                .frame(width: 50, height: 50)
                                .foregroundColor(.purple)
                            Text("Upload")
                                .font(.headline)
                                .foregroundColor(.purple)
                        }
                        .frame(width: 300, height: 300)
                        .background(Color.purple.opacity(0.1))
                        .cornerRadius(20)
                    }
                    
                }
                .frame(width: UIScreen.main.bounds.width * dimensionWidth, height: UIScreen.main.bounds.width * dimensionHeight)
                .padding()
                .onTapGesture {
                    
                    sourceType = .photoLibrary
                    showingImagePicker = true
                }
//                .sheet(isPresented: $showImageSourceSheet) {
//                    // Your custom view with options
//                    ImageSourceSelectionView(sourceType: $sourceType, showingImagePicker: $showingImagePicker)
//                }
                Spacer()
                
                AnimButtonView(isPressed: showingEdittor,
                               title: "Choose") {
                    withAnimation {
                        if inputImage == nil {
                            showAlert = true
                            return
                        }
                        showingEdittor.toggle()
                    }
                }
            }
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text("No Image Selected"), message: Text("Please upload an image before proceeding."), dismissButton: .default(Text("OK")))
        }
//        .confirmationDialog("Select Image", isPresented: $showActionSheet, titleVisibility: .visible) {
//            Button("Photo Library") {
//                sourceType = .photoLibrary
//                showingImagePicker = true
//            }
//            Button("Camera") {
//                sourceType = .camera
//                showingImagePicker = true
//            }
//            Button("Cancel", role: .cancel) { }
//        } message: {
//            Text("Choose a source")
//        }
        .sheet(isPresented: $showingImagePicker, onDismiss: loadImage) {
            CymeImagePicker(image: $inputImage, sourceType: sourceType)
        }
        .navigationDestination(isPresented: $showingEdittor) {
            
            if AppState.shared.currentStyle == .neutral {
                EditPhotoView(image: self.inputImage)
                .navigationBarBackButtonHidden()
            } else {
                PhotoEditView(isDissmiss: $showingEdittor,
                                                         pickImage: $inputImage)
                .navigationBarBackButtonHidden()
                
            }
        }
        
    }
    
    func loadImage() {
        guard let inputImage = inputImage else { return }
        image = Image(uiImage: inputImage)
    }
}

struct WrapperChooseImage: View {
    @State private var path = NavigationPath()
    @State var title = "Noise"
    var body: some View {
        ChooseImageView(path: $path)
    }
}

#Preview {
    WrapperChooseImage()
}
