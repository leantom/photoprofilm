//
//  SplashScreenView.swift
//  PhotoProFilm
//
//  Created by QuangHo on 1/7/24.
//

import SwiftUI
import NavigationTransitions

struct SplashScreenView: View {
    var screen: SplashScreen
    var actionStart: (() -> Void)
    var body: some View {
        ZStack {
            // Background Image
            GeometryReader { geometry in
                Image(screen.imageName)
                    .resizable()
                    .scaledToFill()
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .clipped()
            }
            .edgesIgnoringSafeArea(.all)
            // Gradient Overlay
            LinearGradient(
                gradient: Gradient(colors: [Color.black.opacity(0.7), Color.black.opacity(0.3), Color.black.opacity(0.7)]),
                startPoint: .top,
                endPoint: .bottom
            )
            .edgesIgnoringSafeArea(.all)
            // Content
            VStack {
                Spacer()
                
                VStack(alignment: .center, spacing: 20) {
                    Spacer()
                    Text(screen.title)
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .fontWidth(.condensed)
                    
                    Text(screen.description)
                        .font(.body)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .fontWidth(.condensed)
                    // Buttons
                    HStack(spacing: 20) {
                        Button(action: {
                            // Skip action
                        }) {
                            Text("Skip")
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.purple.opacity(0.3))
                                .foregroundColor(.white)
                                .fontWidth(.condensed)
                                .cornerRadius(10)
                        }
                        
                        Button(action: {
                            // Next action
                            if screen.typeSplash == .start {
                                actionStart()
                            }
                        }) {
                            Text(screen.buttonText)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.purple)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                                .fontWidth(.condensed)
                        }
                    }
                    .padding(.top, 10)
                    .padding(.bottom, 100)
                }
                .padding()
                
                Spacer()
            }
        }
        .background(.red)
    }
}


struct WrapperSplashScreen: View {
    
    let splashScreens = [
        SplashScreen(imageName: "film", title: "Relive the Classics", description: "Transform your photos with timeless elegance. Embrace the charm of classic film aesthetics and create lasting memories.", buttonText: "Next", typeSplash: .skip),
        SplashScreen(imageName: "cinematic", title: "Retro Creativity Unleashed", description: "Dive into a world of retro-inspired tools. Use our AI toolbox to give your photos a vintage touch and showcase your artistic flair.", buttonText: "Next", typeSplash: .skip),
        SplashScreen(imageName: "avatar", title: "Renaissance of Photography", description: "Explore the Renaissance style for your photography. Use advanced features to create inspiring works of art.", buttonText: "Get Started", typeSplash: .start)
    ]
    @State var isShowCategoryView: Bool = false
    
    
    var body: some View {
        NavigationStack {
            TabView {
                ForEach(splashScreens) { screen in
                    SplashScreenView(screen: screen, actionStart:  {
                        AppSetting.setFirstLogined(value: false)
                        isShowCategoryView.toggle()
                    })
                }
            }
            .tabViewStyle(PageTabViewStyle())
            .edgesIgnoringSafeArea(.all)
        }
        .navigationDestination(isPresented: $isShowCategoryView) {
            withAnimation {
                
                LoginView()
                    .navigationBarBackButtonHidden()
            }
        }
        .navigationTransition(.fade(.out))
        
        
        
    }
}

#Preview {
    WrapperSplashScreen()
}
