//
//  ChooseImageView.swift
//  PhotoProFilm
//
//  Created by QuangHo on 19/6/24.
//

import SwiftUI
import SDWebImageSwiftUI
import NavigationTransitions
import GoogleMobileAds

struct CategoryImageView: View {
    @State var listCategory = [
        FeatureView(imageName: "avatar", title: "Neutral Style", style: .neutral),
        FeatureView(imageName: "noise", title: "Noise", style: .scene),
        FeatureView(imageName: "contrast_1", title: "Contrast", style: .cinematic),
        FeatureView(imageName: "film", title: "Films", style: .film),
        FeatureView(imageName: "selfie", title: "Selfie", style: .selfie),
        FeatureView(imageName: "cinematic", title: "Cinematic", style: .cinematic),
        FeatureView(imageName: "vivid", title: "Vivid", style: .basic),
        FeatureView(imageName: "BW", title: "B&W", style: .BW)
    ]
    
    @State var featureSelected: FeatureView?
    @State var titleSetected: String = ""
    
    @State var user: NewUser?
    
    @State private  var isShowCategory: Bool = false
    @State private  var isShowPersonalInfo: Bool = false
    @Binding var path: NavigationPath
    var actionSettingView:(() -> Void)
    @State private  var isShowAds: Bool = false
    
    var body: some View {
        GeometryReader { geometry in
            let adSize = GADCurrentOrientationAnchoredAdaptiveBannerAdSizeWithWidth(geometry.size.width)
            VStack {
                ScrollView {
                    VStack(alignment: .leading) {
                       
                        HStack(spacing: 10) {
                            if let filePath = Bundle.main.path(forResource: "icons8-avatar", ofType: "gif") {
                                            let url = URL(fileURLWithPath: filePath)
                                            AnimatedImage(url: url)
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 40, height: 40)
                                                
                                        }
                            VStack(alignment: .leading) {
                                Text("Welcome back 👋")
                                    .foregroundStyle(.black)
                                    .fontWidth(.condensed)
                                Text(user?.username ?? "Anonymous")
                                    .font(.headline)
                                    .foregroundStyle(.black)
                                    .fontWidth(.condensed)
                            }
                            
                        }
                        .padding()
                        .onTapGesture {
                            
                            actionSettingView()
                        }
                        
                        HStack (alignment: .center){
                            ZStack {
                                Image("texture")
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .opacity(0.5)
                                        .frame(height: 200)
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text("Edit Photo")
                                            .font(.title)
                                            .fontWeight(.bold)
                                            .foregroundStyle(Color.white)
                                            .fontWidth(.condensed)
                                            .padding(.top)
                                            
                                        Text("Unleash your creativity ")
                                            .font(.subheadline)
                                            .fontWidth(.condensed)
                                            .foregroundStyle(Color.white)
                                            .padding(.bottom)
                                        
                                        Button(action: {
                                            withAnimation {
                                                self.featureSelected = listCategory.first
                                                self.titleSetected = self.featureSelected?.title ?? "Basic"
                                                guard let featureSelected = self.featureSelected else {return}
                                                AppState.shared.currentStyle = featureSelected.style
                                                AppState.shared.titleCategory = featureSelected.title
                                                path.append("ChoosePicker")
                                            }
                                        }) {
                                            Text("Select Photo")
                                                .frame(width: 120, height: 44)
                                                .foregroundColor(.purple)
                                                .background(Color.white)
                                                .cornerRadius(10)
                                                .font(.title3)
                                                .fontWidth(.condensed)
                                        }
                                    }
                                    .padding()
                                    Spacer()
                                }
                            }
                            
                            
                        }
                        .background(Color.purple.opacity(0.4))
                        .cornerRadius(10)
                        .padding()
                        
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                            ForEach(listCategory) { category in
                                FeatureView(imageName: category.imageName, title: category.title)
                                    .onTapGesture {
                                        print(category.title)
                                        self.featureSelected = category
                                        self.titleSetected = category.title
                                        AppState.shared.currentStyle = category.style
                                        AppState.shared.titleCategory = category.title
                                        DataColor.shared.style = category.style
                                        path.append(Screen.instruction.rawValue)
                                        //path.append("ChoosePicker")
                                    }
                            }
                        }
                        .padding()
                    }
                    
                }
                
                if isShowAds {
                    BannerView(adSize)
                      .frame(height: 50)
                }
            }
            .background(.white)
            .onAppear(perform: {
                Task {
                    self.user = await LoginViewModel.shared.getUserDetail()
                    do {
                        staticPaintingStyle = try await getStylePainting()
                    } catch let err{
                        print(err.localizedDescription)
                    }
                }
#if RELEASE
                GoogleMobileAdsConsentManager.shared.gatherConsent { consentError in
                    if let consentError {
                        // Consent gathering failed.
                        print("Error: \(consentError.localizedDescription)")
                    }
                    GoogleMobileAdsConsentManager.shared.startGoogleMobileAdsSDK()
                    self.isShowAds = true
                }

                // This sample attempts to load ads using consent obtained in the previous session.
                GoogleMobileAdsConsentManager.shared.startGoogleMobileAdsSDK()
#endif
            })
        }
        
        
    }
    
}

struct FeatureView: View, Identifiable {
    var imageName: String
    var title: String
    var id: String = UUID().uuidString
    var style: ColorStyle = .basic
    
    var body: some View {
        VStack {
            Image(imageName)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: (UIScreen.main.bounds.width - 35 - 5)/2, height: 180)
                .clipped()
                .cornerRadius(10)
            Text(title)
                .font(.caption)
                .fontWidth(.condensed)
                .multilineTextAlignment(.center)
                .padding(.top, 4)
                .foregroundColor(.black)
        }
    }
}

