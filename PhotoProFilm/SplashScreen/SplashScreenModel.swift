//
//  SplashScreenModel.swift
//  PhotoProFilm
//
//  Created by QuangHo on 1/7/24.
//

import Foundation
enum TypeSplash {
    case skip
    case start
}
struct SplashScreen: Identifiable {
    var id = UUID()
    var imageName: String
    var title: String
    var description: String
    var buttonText: String
    var typeSplash: TypeSplash
}
