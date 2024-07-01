//
//  IconButton.swift
//  colorful-room
//
//  Created by macOS on 7/15/20.
//  Copyright © 2020 PingAK9. All rights reserved.
//

import SwiftUI

struct IconButton: View {
    var image:String
    var size:CGFloat
    
    init(_ image:String, size:CGFloat = 32) {
        self.image = image
        self.size = size
    }
    var body: some View {
        Image(systemName: self.image)
            .resizable()
            .foregroundColor(.white)
            .frame(width: self.size, height: self.size)
            .aspectRatio(contentMode: .fit)
    }
}

