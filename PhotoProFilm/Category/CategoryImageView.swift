//
//  ChooseImageView.swift
//  PhotoProFilm
//
//  Created by QuangHo on 19/6/24.
//

import SwiftUI
import SDWebImageSwiftUI
import NavigationTransitions

struct CategoryImageView: View {
    @State var listCategory = [
        FeatureView(imageName: "avatar", title: "Neutral Style", style: .basic),
        FeatureView(imageName: "noise", title: "Noise", style: .scene),
        FeatureView(imageName: "contrast_1", title: "Contrast", style: .cinematic),
        FeatureView(imageName: "film", title: "Films", style: .film),
        FeatureView(imageName: "selfie", title: "Selfie", style: .selfie),
        FeatureView(imageName: "cinematic", title: "Cinematic", style: .film),
        FeatureView(imageName: "vivid", title: "Vivid", style: .basic)
    ]
    
    @State var featureSelected: FeatureView?
    @State var titleSetected: String = ""
    
    @State var user: NewUser?
    
    @State private  var isShowCategory: Bool = false
    
    var body: some View {
        NavigationStack {
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
                                    .fontWidth(.condensed)
                                Text(user?.username ?? "Anonymous")
                                    .font(.headline)
                                    .fontWidth(.condensed)
                            }
                            
                        }
                        .padding()
                        
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
                                                isShowCategory.toggle()
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
                                        DataColor.shared.style = category.style
                                        isShowCategory.toggle()
                                    }
                            }
                        }
                        .padding()
                    }
                }
            }
            .background(.white)
        }
        .navigationDestination(isPresented: $isShowCategory) {
            if let feature = self.featureSelected {
              
                ChooseImageView(title: $titleSetected, currentStyle: feature.style)
                    .navigationBarBackButtonHidden()
            } else {
                Text("No choose")
            }
            
            
        }
        .navigationTransition(.fade(.cross))
        .onAppear(perform: {
            Task {
                self.user = await LoginViewModel.shared.getUserDetail()
            }
            
        })
        
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
        }
    }
}


#Preview {
    CategoryImageView()
}

