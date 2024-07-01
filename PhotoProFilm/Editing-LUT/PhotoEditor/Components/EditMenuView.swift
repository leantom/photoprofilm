//
//  EditMenuControlView.swift
//  colorful-room
//
//  Created by macOS on 7/8/20.
//  Copyright © 2020 PingAK9. All rights reserved.
//

import SwiftUI
 

struct EditMenuView: View {
    
    @EnvironmentObject var shared:PECtl
    
    @State var currentView:EditView = .lut
    var sizeIcon: CGFloat = 25
    
    var body: some View {
        GeometryReader { geometry in
            VStack{
                if((self.currentView == .filter && self.shared.currentEditMenu != .none) == false
                   && self.shared.lutsCtrl.editingLut == false){
                    HStack(spacing: 48){
                        
                        Button(action:{
                            self.currentView = .lut
                        }){
                            
                            Image(systemName: "camera.filters")
                                .resizable()
                                .scaledToFit()
                                .foregroundColor(self.currentView == .lut ? Color("kFF4500") : .white)
                                .frame(width: sizeIcon, height: sizeIcon)
                            
                        }
                        Button(action:{
                            if(self.shared.lutsCtrl.loadingLut == false){
                                self.currentView = .filter
                                self.shared.didReceive(action: PECtlAction.commit)
                            }
                        }){
                            
                            Image(systemName: "circle.lefthalf.filled.righthalf.striped.horizontal")
                                .resizable()
                                .scaledToFit()
                                .foregroundColor(self.currentView == .filter ? Color("kFF4500") : .white)
                                .frame(width: sizeIcon, height: sizeIcon)
                        }
//                        Button(action:{
//                            self.currentView = .recipe
//                        }){
//                            IconButton(self.currentView == .recipe ? "edit-recipe-highlight" : "edit-recipe")
//                        }
                        Button(action:{
                            
                            self.shared.didReceive(action: PECtlAction.undo)
                        }){
                            Image(systemName: "arrow.counterclockwise")
                                .resizable()
                                .scaledToFit()
                                .foregroundColor(.white)
                                .frame(width: sizeIcon, height: sizeIcon)
                            
                            
                        }
                    }
                    .frame(width: geometry.size.width, height: 50)
                    .background(Color.myPanel)
                }
                Spacer()
                ZStack{
                    if(self.currentView == .filter){
                        FilterMenuUI()
                    }
                    if(self.currentView == .lut){
                        LutMenuUI()
                    }
                    if(self.currentView == .recipe){
                        RecipeMenuUI()
                    }
                }
                Spacer()
            }
           
        }
    }
    
    
}

public enum EditView{
    case lut
    case filter
    case recipe
    case back
}
