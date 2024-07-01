//
//  ButtonView.swift
//  PhotoProFilm
//
//  Created by QuangHo on 22/6/24.
//

import SwiftUI

struct AnimButtonView: View {
    var isPressed = false
    @State var title: String = "Done"
    let actionDone: () -> Void
    
    var body: some View {
        Button(action: {
            // Action when button is pressed
            withAnimation {
                actionDone()
            }
        }) {
            Text(title)
                .padding()
                .font(.headline)
                .foregroundColor(.white)
                .frame(width: 300, height: 50)
                .background(Color.purple)
                .cornerRadius(isPressed ? 30 : 10)
                .scaleEffect(isPressed ? 0 : 1.0)
                .animation(.easeInOut, value: isPressed)
        }
        
    }
}

#Preview {
    AnimButtonView( actionDone: {})
}


