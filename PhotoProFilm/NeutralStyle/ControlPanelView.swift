//
//  ControlPanelView.swift
//  PhotoProFilm
//
//  Created by QuangHo on 1/10/24.
//

import SwiftUI

struct CircularButtonView: View {
    var systemImageName: String
    var action: () -> Void // Closure to handle button tap
    
    var body: some View {
        Button(action: {
            // Call the action closure when the button is tapped
            action()
        }) {
            Circle()
                .fill(Color.black) // Background color for the button
                .frame(width: 45, height: 45)
                .overlay(
                    Image(systemName: systemImageName)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 30, height: 30)
                        .foregroundColor(.white) // Icon color
                        .clipped()
                )
        }
    }
}

struct ControlPanelView: View {
    // Define callbacks for each button
    var flashAction: () -> Void
    var timerAction: (Int) -> Void
    @State var isFlashOn: Bool = false
    @Binding var aspectRatio: AspectRatio
    @Binding var isTimerOn: Bool
    @State var isShowTimerBar: Bool = false
    
    @State var timerDuration: Int = 0
    @State var remainingTime: Int = 0
    @State var isCountingDown: Bool = false
    
    var body: some View {
        VStack {
            if isShowTimerBar {
                barTimer
                    .frame(height: 50)
                    .transition(.move(edge: .trailing))
                                    .animation(.easeInOut(duration: 0.5), value: isShowTimerBar)
            } else {
                HStack(spacing: 20) {
                    // Flash button
                    Button(action: {
                        // Call the action closure when the button is tapped
                        flashAction()
                        withAnimation {
                            isFlashOn.toggle()
                        }
                        
                    }) {
                        Circle()
                            .fill(Color.clear) // Background color for the button
                            .frame(width: 45, height: 45)
                            .overlay(
                                Image(systemName: isFlashOn ? "bolt" : "bolt.slash")
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 30, height: 30)
                                    .foregroundColor(isFlashOn ? .yellow :.white) // Icon color
                                    .clipped()
                            )
                    }
                    Spacer()
                    // Ratio button (4:3 as text)
                    Button(action: {
                        
                        aspectRatio = .ratio4_3
                    }) {
                        
                        Text("4:3")
                            .font(.headline)
                            .frame(width: 30, height: 30)
                            .foregroundColor(.white)
                            .padding([.leading, .trailing], 10)
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(aspectRatio == .ratio4_3 ? Color.yellow : .white, lineWidth: 1)
                            )
                        
                    }
                    Spacer()
                    Button(action: {
                        aspectRatio = .ratio9_16
                    }) {
                        
                        Text("9:16")
                            .font(.headline)
                            .frame(width: 50, height: 30)
                            .foregroundColor(.white)
                            .padding([.leading, .trailing], 10)
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(aspectRatio == .ratio9_16 ? .yellow : .white, lineWidth: 1)
                            )
                        
                    }
                    
                    Spacer()
                    // Timer button
                    
                    Button(action: {
                        // Call the action closure when the button is tapped
                        timerAction(3)
                        withAnimation {
                            isShowTimerBar.toggle()
                        }
                        
                    }) {
                        Circle()
                            .fill(Color.clear) // Background color for the button
                            .frame(width: 45, height: 45)
                            .overlay(
                                Image(systemName: "timer")
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 30, height: 30)
                                    .foregroundColor(.white) // Icon color
                                    .clipped()
                            )
                    }
                }
                .padding()
            }
        }
        .transition(.move(edge: .leading)) // Add transition when it disappears
        .animation(.easeInOut(duration: 0.5), value: isShowTimerBar)
    
        
    }
    
    // Timer logic
    func startTimer(duration: Int) {
        // Set the timer duration
        self.timerDuration = duration
        self.remainingTime = duration
        self.isCountingDown = true
        
        // Start countdown
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            if self.remainingTime > 0 {
                self.remainingTime -= 1
            } else {
                timer.invalidate()
                self.isCountingDown = false
                // Trigger the photo capture after the countdown ends
                timerAction(self.timerDuration) // Call the action to capture photo after timer
            }
        }
    }
    
    var barTimer: some View {
        HStack {
            Spacer()
            
            Button(action: {
                isShowTimerBar = false
                isTimerOn = false
            }) {
                Text("Turn off")
                    .font(.system(size: 20))
                    .fontWidth(.compressed)
                    .foregroundColor(.white)
            }
            Spacer()
            // Timer buttons (you can adjust these as needed)
            Button(action: {
                timerAction(3)
                
                isShowTimerBar = false
                isTimerOn = true
            }) {
                Text("3s")
                    .font(.system(size: 20))
                    .fontWidth(.compressed)
                    .foregroundColor(.white)
            }
            Spacer()
            Button(action: {
                timerAction(5)
                isShowTimerBar = false
                isTimerOn = true
            }) {
                Text("5s")
                    .font(.system(size: 20))
                    .fontWidth(.compressed)
                    .foregroundColor(.white)
            }
            Spacer()
            Button(action: {
                timerAction(10)
                isShowTimerBar = false
                isTimerOn = true
            }) {
                Text("10s")
                    .font(.system(size: 20))
                    .fontWidth(.compressed)
                    .foregroundColor(.white)
            }
            
            Spacer()
        }
    }
    
}


struct ControlPanelViewWrapper:View {
    @State var espectRatio:AspectRatio = .ratio4_3
    @State var isTimeOn = false
    
    var body: some View {
        
        ControlPanelView(flashAction: {
            
        }, timerAction: { duration in
            
        }, aspectRatio: $espectRatio, isTimerOn: $isTimeOn)
        
    }
}

#Preview {
    ControlPanelViewWrapper()
}
