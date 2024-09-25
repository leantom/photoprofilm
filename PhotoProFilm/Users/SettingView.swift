//
//  SettingView.swift
//  PhotoProFilm
//
//  Created by QuangHo on 7/7/24.
//

import SwiftUI
import NavigationTransitions
struct SettingsView: View {
    
    @State var isShowPersonal: Bool = false
    @State var username = "QuangHo"
    @State var title = "Settings"
    @Environment(\.dismiss) var dismiss
    @Binding var path: NavigationPath
    
    var body: some View {
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
                        
                        Text(title)
                            .font(.title)
                            .fontWeight(.bold)
                            .fontWidth(.condensed)
                    }
                }
                
            }
            .padding(.top, 10)
            ProfileHeader(username: username)
            
            List {
                Section(header: Text("General")) {
                    SettingsRow(icon: "person", text: "Personal Info")
                        .onTapGesture {
                            print("choose personal info")
                            path.append("PersonalInfo")
                        }
                }
                
                Section(header: Text("About")) {
                    SettingsRow(icon: "ellipsis.message", text: "Follow us on Social Media")
                        .onTapGesture {
                            openTwitter()
                        }
                    SettingsRow(icon: "shield", text: "Privacy Policy")
                        .onTapGesture {
                            path.append("Privacy")
                        }
                    SettingsRow(icon: "info.circle", text: "About PhotoProFilm")
                        .onTapGesture {
                            path.append("AboutUs")
                        }
                    SettingsRow(icon: "trash", text: "Delete Account")
                        .onTapGesture {
                            Task {
                                await LoginViewModel.shared.deleteUser()
                                path.removeLast(path.count)
                            }
                        }
                }
                
                Button(action: {
                    // Handle logout action
                    if !path.isEmpty {
                        LoginViewModel.shared.logOut()
                        path.removeLast(path.count)
                    }
                }) {
                    HStack {
                        Spacer()
                        Text("Logout")
                            .foregroundColor(.red)
                        Spacer()
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())
        }
    }
    
    func openTwitter() {
            let twitterURL = URL(string: "twitter://PhotoProFilm")!
            if UIApplication.shared.canOpenURL(twitterURL) {
                UIApplication.shared.open(twitterURL, options: [:], completionHandler: nil)
            } else {
                // Twitter app is not installed, open Twitter in a web browser
                let webURL = URL(string: "https://x.com/PhotoProFilm")!
                UIApplication.shared.open(webURL, options: [:], completionHandler: nil)
            }
        }
}

struct ProfileHeader: View {
    var username: String
    
    var body: some View {
        let colors: [Color] = [.red, .green, .blue, .orange, .purple]
        let randomColor = colors.randomElement()!
        let initial = username.prefix(1)
        
        return ZStack {
            Circle()
                .fill(randomColor)
                .frame(width: 100, height: 100)
            Text(initial)
                .font(.largeTitle)
                .foregroundColor(.white)
        }
    }
}

struct SettingsRow: View {
    var icon: String
    var text: String
    
    var body: some View {
        HStack (spacing: 25){
            Image(systemName: icon)
                .frame(width: 20, height: 40)
                .foregroundColor(Color.myPrimary)
            Text(text)
                .fontWidth(.condensed)
        }
    }
}

struct SocialMediaView: View {
    var body: some View {
        Text("Social Media View")
            .navigationTitle("Follow us on Social Media")
    }
}
struct PrivacyPolicyView: View {
    var body: some View {
        Text("Privacy Policy View")
            .navigationTitle("Privacy Policy")
    }
}
struct AboutPhotofyView: View {
    var body: some View {
        Text("About Photofy View")
            .navigationTitle("About Photofy")
    }
}
struct DeleteAccountView: View {
    var body: some View {
        Text("Delete Account View")
            .navigationTitle("Delete Account")
    }
}

