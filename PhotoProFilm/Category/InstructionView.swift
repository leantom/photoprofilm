//
//  InstructionView.swift
//  PhotoProFilm
//
//  Created by QuangHo on 25/9/24.
//

import SwiftUI


struct InstructionView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var path: NavigationPath
    @State var painting: PaintingStyle = PaintingStyle()
    
    
    var body: some View {
        ScrollView {
            ZStack {
               
                VStack(spacing: 20) {
                    HStack {
                        Button(action: {
                            dismiss()
                        }, label: {
                            Image(systemName: "arrow.left")
                                .foregroundColor(.black)
                        })
                        .padding(.leading, 20)
                        Spacer()
                    }
                    // Title Text
                    Text(painting.title ?? "")
                        .font(.title)
                        .fontWeight(.bold)
                        .fontWidth(.condensed)
                        .multilineTextAlignment(.center)
                        .padding(.top, 20)
                    
                    // Description Text
                    Text(painting.description ?? "")
                        .font(.subheadline)
                        .fontWidth(.condensed)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    // Read More Button
                    HStack {
                        Text("Try More")
                            .fontWeight(.bold)
                        Image(systemName: "arrow.right")
                        Spacer()
                    }
                    .onTapGesture {
                        withAnimation {
                            path.append(Screen.choosePicker.rawValue)
                        }
                    }
                    .padding(.vertical, 10)
                    .padding(.horizontal)
                    
                    // Image with red cover
                    AsyncImage(url: URL(string: painting.imageUrl ?? "")) { phase in
                        if let image = phase.image {
                            image.resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(height: 350)
                                .cornerRadius(100)
                                .overlay(Circle().stroke(Color.gray, lineWidth: 1))
                                .shadow(radius: 5)
                        } else {
                            ProgressView()
                        }
                    }
                    
                    // Photographer Info
                    HStack() {
                        Text(painting.outstandingAuthor ?? "")
                            .font(.headline)
                            .fontWeight(.semibold)
                        Spacer()
                        Text("01")
                            .font(.headline)
                            .fontWidth(.condensed)
                                .foregroundColor(.gray)
                    }
                    .padding([.leading, .trailing], 20)
                    VStack {
                        Text(painting.introductoryArticle ?? "")
                            .font(.headline)
                            .fontWeight(.regular)
                            .fontWidth(.condensed)
                            .lineSpacing(5)
                    }
                    .padding()
                    
                    Spacer()
                }
                
            }
        }
        .background(LinearGradient(gradient: Gradient(colors: [Color.purple.opacity(0.2), Color.gray.opacity(0.1)]), startPoint: .top, endPoint: .bottom))
        .onAppear {
            
            if let staticPaintingStyle = staticPaintingStyle,
               let obj = staticPaintingStyle.filter({ painting in
                   let style = painting.style ?? ""
                   return style == AppState.shared.currentStyle.rawValue
                   
               }).first {
                painting = obj
            } 
        }
    }
}

struct WrapperInstructionView:View {
    @State var path = NavigationPath()
    var body: some View {
        InstructionView(path: $path)
    }
}
#Preview {
    WrapperInstructionView()
}
