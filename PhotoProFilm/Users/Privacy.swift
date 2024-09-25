//
//  Privacy.swift
//  PhotoProFilm
//
//  Created by QuangHo on 16/7/24.
//

import SwiftUI


struct Privacy: View {
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
                        
                        Text("Privacy Policy")
                            .font(.largeTitle)
                            .padding()
                            .fontWeight(.bold)
                            .fontWidth(.condensed)
                    }
                }
                
            }
            .padding(.top, 10)
            WebView(htmlContent: viewModel.privacyPolicy)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .onAppear(perform: {
            viewModel.fetchHtml()
        })
    }
}

#Preview {
    Privacy()
}
