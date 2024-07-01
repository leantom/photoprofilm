//
//  EditPhotoView.swift
//  PhotoProFilm
//
//  Created by QuangHo on 27/6/24.
//

import SwiftUI
import SDWebImageSwiftUI

enum ProcessImage {
    case None
    case Processing
    case Done
}

struct EditPhotoView: View {
    @State var image: UIImage?
    @State var afterImage: UIImage?
    @Environment(\.dismiss) var dismiss
    @State var isDoneProcess: Bool = false
    @State var isShowSaveSheet: Bool = false
    @State var isExportedDone: Bool = false
    
    @State var currentProcess: ProcessImage = .None
    @State var currentStyle: StyleAI = .None {
        didSet {
            if currentStyle == .None {return}
            if currentProcess == .Processing {return}
            applyAIFilter()
        }
    }
    @State var ml : ImageClassifier?
    
    var body: some View {
        NavigationStack {
            ZStack {
                VStack {
                    HStack {
                        Button(action: {
                            // Action for back button
                            dismiss()
                        }) {
                            Image(systemName: "arrow.left")
                                .foregroundColor(.black)
                        }
                        Spacer()
                        Text("Edit Photo")
                            .font(.headline)
                            .foregroundColor(.black)
                            .fontWidth(.condensed)
                        Spacer()
                        Button(action: {
                            // Action for save button
                            self.isShowSaveSheet.toggle()
                        }) {
                            Image(systemName: "square.and.arrow.up")
                                .foregroundColor(.black)
                        }
                    }
                    .padding()
                    switch currentProcess {
                    case .None:
                        if let displayedImage = image {
                            Image(uiImage: displayedImage)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: UIScreen.main.bounds.width)
                        }
                    case .Processing:
                        if let path = Bundle.main.path(forResource: "loading", ofType: "gif") {
                            let url = URL(fileURLWithPath: path)
                            VStack {
                                WebImage(url: url)
                                    .resizable()
                                    .indicator(.activity)
                                    .scaledToFit()
                                    .frame(width: 64, height: 64)
                            }
                            .frame(height: 500)
                            
                        }
                    case .Done:
                        if let displayedImage = afterImage {
                            Image(uiImage: displayedImage)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: UIScreen.main.bounds.width)
                        }
                    }
                    
                    Spacer()
                    
                    ScrollView (.horizontal, showsIndicators: false){
                        HStack {
                                    ActionButton(imageName: "flame", title: "High Saturation", isSelected: currentStyle == .HighSatuation) {
                                        if currentStyle == .HighSatuation {return}
                                        self.currentStyle = .HighSatuation
                                    }
                                    ActionButton(imageName: "wand.and.stars", title: "Vivid", isSelected: currentStyle == .Vivid) {
                                        if currentStyle == .Vivid {return}
                                        self.currentStyle = .Vivid
                                    }
                                    ActionButton(imageName: "wind.snow", title: "Film", isSelected: currentStyle == .Film) {
                                        if currentStyle == .Film {return}
                                        self.currentStyle = .Film
                                    }
                                    ActionButton(imageName: "dial.high", title: "Sketch", isSelected: currentStyle == .Sketch) {
                                        if currentStyle == .Sketch {return}
                                        self.currentStyle = .Sketch
                                    }
                                    ActionButton(imageName: "snowflake", title: "Renaissance", isSelected: currentStyle == .Renaissance) {
                                        if currentStyle == .Renaissance {return}
                                        self.currentStyle = .Renaissance
                                    }
                                    ActionButton(imageName: "laurel.leading", title: "Monochrome", isSelected: currentStyle == .Vintage) {
                                        if currentStyle == .Vintage {return}
                                        self.currentStyle = .Vintage
                                    }
                                }
                        .padding()
                        .background(Color.white)
                    }
                }
                .background(Color.gray.opacity(0.1))
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
                                .transition(.opacity) // Add a transition for animation
                                .onAppear {
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                        withAnimation {
                                            self.isExportedDone.toggle()
                                        }
                                    }
                                }
                            }
                
            }
            
        }
        .sheet(isPresented: $isShowSaveSheet) {
            ExportChooseSizeView { size in
                withAnimation {
                    exportImage(size: size)
                    isShowSaveSheet.toggle()
                    isExportedDone.toggle()
                }
            }
        }
        
    }
    
    
    
    func applyAIFilter() {
        currentProcess = .Processing
        if self.ml == nil {
            self.ml = ImageClassifier()
        }
        DispatchQueue.global(qos: .utility).async {
            guard let image = self.image else { return }
            guard let ml = self.ml else { return }
            
            let now  = Date()
            var imageFilter: UIImage?
            
            switch currentStyle {
            case .HighSatuation:
                imageFilter = ml.applyModel(image: image, style: .HighSatuation)
            case .Vivid:
                imageFilter = ml.applyModel(image: image, style: .Vivid)
            case .Sketch:
                imageFilter = ml.applyModel(image: image, style: .Sketch)
            case .Renaissance:
                imageFilter = ml.applyModel(image: image, style: .Renaissance)
            case .Film:
                imageFilter = ml.applyModel(image: image, style: .Film)
            case .Vintage:
                imageFilter = ml.applyModel(image: image, style: .Vintage)
            default : break
            }
            guard let image1 = imageFilter else { return }
            print("Duration processing: \(Date().timeIntervalSince1970 - now.timeIntervalSince1970)")
            
            
            DispatchQueue.main.async {
                self.afterImage = image1
                self.currentProcess = .Done
                self.isDoneProcess.toggle()
                self.ml?.releaseMemory()
                self.ml = nil
            }
        }
    }
    
    func exportImage(size: CGSize) {
        
        guard let originalImage = self.afterImage else { return }
        let resizedImage = resizeImage(image: originalImage, targetSize: size)
        saveImageToPhotos(image: resizedImage)
    }
    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio, height: size.height * widthRatio)
        }
        
        let rect = CGRect(origin: .zero, size: newSize)
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
    func saveImageToPhotos(image: UIImage) {
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
    }
    
}

struct ActionButton: View {
    let imageName: String
    let title: String
    var isSelected: Bool
    var action: (() -> Void)
    var body: some View {
        VStack {
            Image(systemName: imageName )
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 24, height: 24)
                .foregroundColor(isSelected ?  Color.myPrimary : .black)
            Text(title)
                .font(.caption)
                .foregroundColor(.black)
                .fontWidth(.condensed)
        }
        .onTapGesture {
            withAnimation {
                action()
            }
        }
        .padding()
    }
}

struct WrapperEditPhoto: View {
    @State var image: UIImage? = UIImage(named: "img_0013")
    var body: some View {
        EditPhotoView(image: image)
    }
}


#Preview {
    WrapperEditPhoto()
}
