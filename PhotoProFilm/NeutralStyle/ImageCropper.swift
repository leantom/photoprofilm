//
//  ImageCropper.swift
//  PhotoProFilm
//
//  Created by QuangHo on 11/10/24.
//

import SwiftUI
import Mantis

struct ImageCropper: UIViewControllerRepresentable {
    @Binding var image: UIImage?

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIViewController(context: Context) -> Mantis.CropViewController {
        let cropViewController = Mantis.cropViewController(image: image ?? UIImage())
        cropViewController.config.cropVisualEffectType = .dark
        cropViewController.delegate = context.coordinator
        return cropViewController
    }

    func updateUIViewController(_ uiViewController: Mantis.CropViewController, context: Context) {
        // No need to update anything here
    }

    class Coordinator: NSObject, CropViewControllerDelegate {
        func cropViewControllerDidCrop(_ cropViewController: Mantis.CropViewController, cropped: UIImage, transformation: Mantis.Transformation, cropInfo: Mantis.CropInfo) {
            parent.image = cropped
            cropViewController.dismiss(animated: true)
        }
        
        func cropViewControllerDidFailToCrop(_ cropViewController: Mantis.CropViewController, original: UIImage) {
            parent.image = original
            cropViewController.dismiss(animated: true)
        }
        
        func cropViewControllerDidBeginResize(_ cropViewController: Mantis.CropViewController) {
            
        }
        
        func cropViewControllerDidEndResize(_ cropViewController: Mantis.CropViewController, original: UIImage, cropInfo: Mantis.CropInfo) {
            
        }
        
        var parent: ImageCropper

        init(_ parent: ImageCropper) {
            self.parent = parent
        }

        func cropViewControllerDidCrop(_ cropViewController: CropViewController, cropped: UIImage, transformation: Transformation) {
            parent.image = cropped
            cropViewController.dismiss(animated: true)
        }

        func cropViewControllerDidCancel(_ cropViewController: CropViewController, original: UIImage) {
            cropViewController.dismiss(animated: true)
        }
    }
}
