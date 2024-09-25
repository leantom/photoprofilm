//
//  PhotoEditorView.swift
//  colorful-room
//
//  Created by macOS on 7/8/20.
//  Copyright © 2020 PingAK9. All rights reserved.
//

import SwiftUI
import SDWebImageSwiftUI

struct PhotoEditorView: View {
    
    @EnvironmentObject  var shared:PECtl
    @Binding var isExportedDone: Bool
    
    var body: some View {
        ZStack{
            VStack(spacing: 0){
                if let image = shared.previewImage {
                    ImagePreviewView(image: image)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .clipped()
                }else{
                    if let path = Bundle.main.path(forResource: "loading", ofType: "gif") {
                        let url = URL(fileURLWithPath: path)
                        VStack {
                            WebImage(url: url)
                                .resizable()
                                .indicator(.activity)
                                .scaledToFit()
                                .frame(width: 64, height: 64)
                            
                            Text("Analyzing Neutral Style Model, Wait a second ...")
                                .font(.headline)
                                .foregroundColor(.white)
                                .fontWidth(.condensed)
                        }
                        .frame(height: 500)
                        
                    }
                }
                
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
                    .transition(.opacity) // Add a transition for animation
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            withAnimation {
                                self.isExportedDone.toggle()
                            }
                        }
                    }
                }
                
                EditMenuView()
                    .frame(height: 250)
            }
        }
    }
}
