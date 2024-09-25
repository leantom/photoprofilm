//
//  AboutUs.swift
//  PhotoProFilm
//
//  Created by QuangHo on 16/7/24.
//

import SwiftUI

import SwiftUI
import WebKit

struct WebView: UIViewRepresentable {
    let htmlContent: String
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        webView.scrollView.showsVerticalScrollIndicator = false
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        uiView.loadHTMLString(htmlContent, baseURL: nil)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: WebView
        
        init(_ parent: WebView) {
            self.parent = parent
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            // Handle navigation finished if needed
        }
    }
}

struct AboutUs: View {
    @Environment(\.dismiss) var dismiss
    @StateObject var viewModel = SettingViewModel()
    
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
                        
                        Text("About Us")
                            .font(.largeTitle)
                            .padding()
                            .fontWeight(.bold)
                            .fontWidth(.condensed)
                    }
                }
                
            }
            .padding(.top, 10)
            
            WebView(htmlContent: viewModel.aboutus)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .onAppear {
            viewModel.fetchHtml()
        }
    }
}

#Preview {
    AboutUs()
}
