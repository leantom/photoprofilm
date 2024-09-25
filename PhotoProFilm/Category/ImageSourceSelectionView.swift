//
//  ImageSourceSelectionView.swift
//  PhotoProFilm
//
//  Created by QuangHo on 25/9/24.
//

import SwiftUI

struct ImageSourceSelectionView: View {
    @Binding var sourceType: UIImagePickerController.SourceType
    @Binding var showingImagePicker: Bool
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            List {
                Button("Photo Library") {
                    sourceType = .photoLibrary
                    showingImagePicker = true
                    dismiss()
                }
                Button("Camera") {
                    sourceType = .camera
                    showingImagePicker = true
                    dismiss()
                }
                Button("Cancel", role: .cancel) {
                    dismiss()
                }
            }
            .navigationTitle("Select Image Source")
        }
    }
}
