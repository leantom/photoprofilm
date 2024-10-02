//
//  LoginView.swift
//  PhotoProFilm
//
//  Created by QuangHo on 1/7/24.
//

import SwiftUI
import NavigationTransitions
import AuthenticationServices
import SDWebImageSwiftUI

struct LoginView: View {
    var loginViewModel = LoginViewModel.shared
    @State private var showSignInWithAppleSheet = false
    
    @State private var isShowComingSoon = false
    let appleSignInHandler = AppleSignInHandler()
    @State var currentNonce: String = ""
    @Binding var path: NavigationPath
    @State var isLoading = false
    @ObservedObject var appState: AppState
    
    var body: some View {
        ZStack {
            VStack(spacing: 20) {
                Spacer()
                
                // Logo
                Image("icon_app") // Replace with your logo
                    .resizable()
                    .frame(width: 100, height: 100)
                    .foregroundColor(.purple)
                    .cornerRadius(10)
                
                // App Name
                Text("ProFilm")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .fontWidth(.condensed)
                
                // Welcome Text
                Text("Welcome! Let's dive in into your account!")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                    .fontWidth(.condensed)
                
                // Social Media Login Buttons
                VStack(spacing: 10) {
                    SocialLoginButton(imageName: "gg_icon", text: "Continue with Google", color: Color(hue: 0.05, saturation: 0.807, brightness: 0.89), actionChooseMethod: {
                        self.performGoogleSignIn()
                    }, isSystemImage: false)
                    SocialLoginButton(imageName: "applelogo", text: "Continue with Apple", color: .black, actionChooseMethod: {
                        print("Continue with Apple")
                        self.performAppleSignIn()
                    })
    //                    SocialLoginButton(imageName: "moon.dust.fill", text: "Continue with Twitter", color: Color(red: 0.122, green: 0.621, blue: 0.943), actionChooseMethod: {
    //                        print("Continue with Twitter")
    //                        isShowComingSoon.toggle()
    //                    })
                    SocialLoginButton(imageName: "cloud.rain.fill", text: "Continue with Anonymous", color: Color(red: 0.122, green: 0.621, blue: 0.943), actionChooseMethod: {
                        print("Continue with Anonymous")
                        Task {
                            isLoading.toggle()
                            await loginViewModel.signinWithAnynomous()
                            isLoading.toggle()
                            path.append("photo")
                            appState.isLogined = AppSetting.checkLogined()
                        }
                    })
                }
                .padding(.horizontal)
                
//                // Sign in with Password Button
//                Button(action: {
//                    // Sign in with password action
//                }) {
//                    Text("Sign in with password")
//                        .frame(maxWidth: .infinity)
//                        .padding()
//                        .background(Color.purple)
//                        .foregroundColor(.white)
//                        .cornerRadius(10)
//                        .fontWidth(.condensed)
//                }
//                .padding(.horizontal)
//                .padding(.top, 20)
//                
//                // Sign up Text
//                HStack {
//                    Text("Don’t have an account?")
//                    Button(action: {
//                        // Sign up action
//                    }) {
//                        Text("Sign up")
//                            .foregroundColor(.myPrimary)
//                            .fontWidth(.condensed)
//                    }
//                }
//                .font(.footnote)
//                .padding(.bottom)
                
                Spacer()
            }
            .padding()
            
            if isLoading {
                if let path = Bundle.main.path(forResource: "loading", ofType: "gif") {
                    let url = URL(fileURLWithPath: path)
                    VStack {
                        WebImage(url: url)
                            .resizable()
                            .indicator(.activity)
                            .scaledToFit()
                            .frame(width: 64, height: 64)
                        
                        Text("Loging...")
                            .font(.headline)
                            .foregroundColor(.white)
                            .fontWidth(.condensed)
                    }
                    .frame(height: 500)
                    
                }
            }
        }
       
        
    }
    
    private func performGoogleSignIn() {
        Task {
            isLoading.toggle()
            loginViewModel.signInWithGoogle { result in
                isLoading.toggle()
                appState.isLogined = AppSetting.checkLogined()
                path.append("photo")
            }
        }
    }
    
    private func performAppleSignIn() {
        Task {
            let nonce = AppleSignInHandler.randomNonceString()
            currentNonce = nonce
            appleSignInHandler.currentNonce = currentNonce
            let appleIDProvider = ASAuthorizationAppleIDProvider()
            let request = appleIDProvider.createRequest()
            request.nonce = AppleSignInHandler.sha256(nonce)
            request.requestedScopes = [.fullName, .email]
            
            let authorizationController = ASAuthorizationController(authorizationRequests: [request])
            authorizationController.delegate = appleSignInHandler
            authorizationController.presentationContextProvider = appleSignInHandler
            authorizationController.performRequests()
            isLoading.toggle()
            appleSignInHandler.actionLoginSuccessfully = {
                print("actionLoginSuccessfully")
                DispatchQueue.main.async {
                    isLoading.toggle()
                    appState.isLogined = AppSetting.checkLogined()
                    appState.isFirstInstall = AppSetting.checkisFirstLogined()
                    path.append("photo")
                }
            }
        }
    }
    
}

struct SocialLoginButton: View {
    var imageName: String
    var text: String
    var color: Color
    var actionChooseMethod: (() -> Void)
    var isSystemImage: Bool = true
    
    var body: some View {
        Button(action: {
            // Social login action
            self.actionChooseMethod()
        }) {
            HStack {
                if isSystemImage {
                    Image(systemName: imageName)
                        .frame(width: 24, height: 24)
                        .foregroundStyle(color)
                } else {
                    Image(imageName)
                        .resizable()
                        .frame(width: 24, height: 24)
                        .clipped()
                }
                
                Text(text)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .fontWidth(.condensed)
            }
            .padding()
            .background(Color.white)
            .foregroundColor(.black)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.gray, lineWidth: 1)
            )
            .cornerRadius(10)
        }
    }
}

