//
//  SavePhotos.swift
//  PhotoProFilm
//
//  Created by QuangHo on 2/10/24.
//

import SwiftUI
import UIKit
import GoogleMobileAds
import CoreGraphics

struct ShareSheet: UIViewControllerRepresentable {
    var items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: items, applicationActivities: nil)
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
        // No need to update the controller
    }
}

struct SavePhotosView: View {
    @Environment(\.dismiss) var dismiss
    @State var photo: UIImage?
    @State var isSaving: Bool = false
    @State var isShareSheetPresented: Bool = false
    @State private var adsShownToday: Int = 0
    @State private var showAlert = false
    @State private var hasShownAlert = false // New state to track alert
    @State var isExportedDone: Bool = false
    @State private var isShowAds: Bool = false
    
    var body: some View {
        GeometryReader { geometry in
            let adSize = GADCurrentOrientationAnchoredAdaptiveBannerAdSizeWithWidth(geometry.size.width)
            ZStack {
                
                VStack(spacing: 20) {
                    // Top bar with "Save" text
                    HStack {
                        Text("Save")
                            .font(.headline)
                            .fontWidth(.compressed)
                            .foregroundColor(.white)
                        Spacer()
                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "xmark.app")
                                .font(.title)
                                .foregroundStyle(.white)
                        }
                        
                    }
                    .padding()
                    
                    // Image section
                    if let photo = self.photo {
                        Image(uiImage: photo) // Replace with your image asset name
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 300, height: 450)
                            .clipped()
                            .cornerRadius(10)
                    }
                    
                    // Add to photos button
                    Button(action: {
                        if adsShownToday < 2 {
                            showAdAlertIfNeeded() // Check if alert needs to be shown
                        } else {
                            dismiss()
                            if let photo = self.photo {
                                saveImageToPhotoAlbum(image: photo)
                            }
                        }
                    }) {
                        HStack {
                            Image("Import_light")
                                .foregroundStyle(.white)
                            Text("Add to photos")
                                .foregroundStyle(.white)
                                .fontWidth(.compressed)
                        }
                    }
                    .padding()
                    
                    // Social media sharing options
                    HStack(spacing: 20) {
                        Text("Share your friends")
                            .font(.subheadline)
                            .fontWidth(.condensed)
                            .foregroundColor(.gray)
                        
                        Button(action: {
                            // Twitter action
                            isShareSheetPresented.toggle()
                        }) {
                            Image(systemName: "arrow.turn.down.right")
                                .foregroundStyle(.white)
                                .font(.system(size: 20))
                        }
                        .frame(width: 50, height: 50)
                        
                    }
                    if isShowAds {
                        BannerView(adSize)
                          .frame(height: 50)
                    }
                    
                }
                .padding()
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
                    .transition(.opacity)
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
        .background(Color.black)
        .onAppear {
            guard let photo = AppState.shared.photoEdit else {
                return
            }
            
            self.photo = photo.addText(atPoint: CGPoint(x: photo.size.width * 0.6, y: photo.size.height * 0.9), color: .yellow)
            resetAdCounterIfNeeded()
            InterstitialViewModel.shared.adDismissedHandler = {
                isExportedDone = true
            }
            
#if RELEASE
            GoogleMobileAdsConsentManager.shared.gatherConsent { consentError in
                if let consentError {
                    print("Error: \(consentError.localizedDescription)")
                }
                GoogleMobileAdsConsentManager.shared.startGoogleMobileAdsSDK()
                self.isShowAds = true
            }
            GoogleMobileAdsConsentManager.shared.startGoogleMobileAdsSDK()
#endif
        }
        .sheet(isPresented: $isShareSheetPresented) {
            if let photo = self.photo {
                ShareSheet(items: [
                    "Check out this cool image!",
                    photo,
                    "https://apps.apple.com/us/app/photoprofilm/id6505014197"
                ])
            } else {
                Text("No photo to share.")
            }
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Notice"),
                message: Text("Sorry for showing ads, but we need revenue to maintain the server. We only show ads 2 times per day. Thank you for understanding."),
                dismissButton: .default(Text("OK"), action: {
                    showAd()
                })
            )
        }
    }

    func resetAdCounterIfNeeded() {
        let today = Date()
        let calendar = Calendar.current
        let lastResetDate = UserDefaults.standard.object(forKey: "adLastResetDate") as? Date ?? Date.distantPast
        if !calendar.isDate(today, inSameDayAs: lastResetDate) {
            UserDefaults.standard.set(0, forKey: "adsShownToday")
            UserDefaults.standard.set(today, forKey: "adLastResetDate")
        }
        adsShownToday = UserDefaults.standard.integer(forKey: "adsShownToday")
    }

    // New function to handle alert showing only once
    func showAdAlertIfNeeded() {
        let hasSeenAlert = UserDefaults.standard.bool(forKey: "hasSeenAdAlert")
        if !hasSeenAlert {
            showAlert = true
            UserDefaults.standard.set(true, forKey: "hasSeenAdAlert")
        } else {
            showAd()
        }
    }

    func showAd() {
        adsShownToday += 1
        UserDefaults.standard.set(adsShownToday, forKey: "adsShownToday")
#if DEBUG
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            isExportedDone = true
            if let photo = self.photo {
                saveImageToPhotoAlbum(image: photo)
            }
        }
#endif

#if RELEASE
        DispatchQueue.main.async {
            InterstitialViewModel.shared.showAd()
        }
#endif
    }
}

struct WrapperSavePhotos: View {
    var image : UIImage = UIImage(imageLiteralResourceName: "img_0013")
    var body: some View {
        SavePhotosView(photo: image)
    }
}

struct SavePhotosView_Previews: PreviewProvider {
   
    static var previews: some View {
        WrapperSavePhotos()
    }
}
