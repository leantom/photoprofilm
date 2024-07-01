//
//  ScrollNumberView.swift
//  PhotoProFilm
//
//  Created by QuangHo on 24/6/24.
//

import SwiftUI


struct ScrollNumberView: View {
    @State private var brightness: Double = 50
    
    var body: some View {
        VStack {
            Spacer()
            
            
            HStack {
                
                VStack {
                    
                    Slider(value: $brightness, in: 0...100, step: 1)
                        .accentColor(.yellow)
                }
                
            }
            
            HStack {
                Button(action: {
                    // Action for adjustment
                }) {
                    VStack {
                        Image(systemName: "sun.max")
                            .font(.title)
                        Text("Điều chỉnh")
                    }
                }
                .padding()
                
                Button(action: {
                    // Action for filter
                }) {
                    VStack {
                        Image(systemName: "circle.grid.3x3")
                            .font(.title)
                        Text("Bộ lọc")
                    }
                }
                .padding()
                
                Button(action: {
                    // Action for crop
                }) {
                    VStack {
                        Image(systemName: "crop")
                            .font(.title)
                        Text("Cắt xén")
                    }
                }
                .padding()
            }
            .padding(.top, 20)
            
            Spacer()
        }
        .padding()
    }
}


#Preview {
    ScrollNumberView()
}
