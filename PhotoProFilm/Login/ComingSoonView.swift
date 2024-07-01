//
//  ComingSoonView.swift
//  PhotoProFilm
//
//  Created by QuangHo on 1/7/24.
//

import SwiftUI

import SwiftUI

struct ComingSoonView: View {
    @Environment(\.dismiss) var dismiss
    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.black)
                        .padding()
                }
                Spacer()
            }
            .padding(.leading)
            .padding(.top, 10)
            
            Spacer()
            
            VStack(spacing: 20) {
               
                Image("comming_soon") // Replace with your image name
                    .resizable()
                    .scaledToFill()
                    .frame(width: 300, height: 500)
            }
            
            Spacer()
            
        }
        .background(
            LinearGradient(gradient: Gradient(colors: [Color.white, Color.blue.opacity(0.1)]), startPoint: .top, endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)
        )
    }
}



#Preview {
    ComingSoonView()
}
