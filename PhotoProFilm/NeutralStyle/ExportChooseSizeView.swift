//
//  ExportChooseSizeView.swift
//  PhotoProFilm
//
//  Created by QuangHo on 30/6/24.
//

import SwiftUI



struct ExportChooseSizeView: View {
    let resolutions = [
        ("360 x 640", CGSize(width: 360, height: 640), false),
        ("480 x 854", CGSize(width: 480, height: 854), false),
        ("720 x 1280", CGSize(width: 720, height: 1280), false),
        ("1080 x 1920", CGSize(width: 1080, height: 1920), true),
        ("1440 x 2560", CGSize(width: 1440, height: 2560), true),
        ("2160 x 3840", CGSize(width: 2160, height: 3840), true),
        ("4320 x 7680", CGSize(width: 4320, height: 7680), true)
    ]
    var onSizeChosen: (CGSize) -> Void
    
    var body: some View {
        VStack {
            Text("Save Results")
                .font(.headline)
                .padding()
            
            List(resolutions, id: \.0) { resolution, size, isPro in
                Button(action: {
                    withAnimation {
                        onSizeChosen(size)
                    }
                    print(resolution)
                    //exportImage(size: size)
                }) {
                    HStack {
                        Text(resolution)
                        Spacer()
                        if isPro {
                            Text("Recommended")
                                .foregroundColor(.white)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .background(Color.purple)
                                .cornerRadius(10)
                        }
                    }
                    .frame(height: 45)
                    .padding(.vertical, 5)
                }
                .buttonStyle(PlainButtonStyle())
            }
            .listStyle(PlainListStyle())
        }
        .padding()
        .background(Color(UIColor.systemGray6))
        .cornerRadius(20)
        .shadow(radius: 10)
        .padding()
    }
    
    

}

struct WrapperExportView: View {
    
    var body: some View {
        ExportChooseSizeView { size in
            print(size)
        }
    }
}

#Preview {
    WrapperExportView()
}

