//
//  EditController.swift
//  test
//
//  Created by macOS on 7/2/20.
//  Copyright © 2020 PingAK9. All rights reserved.
//

import Foundation
import SwiftUI
import PixelEnginePackage

public enum ColorStyle: String {
    case basic = "Vivid"
    case cinematic = "Cinematic"
    case film = "Film"
    case selfie = "Selfie"
    case scene = "Scene"
    case neutral = "Neutral"
    case BW = "BW"
    case retro = "retro"
    
    var description: String {
            switch self {
            case .basic, .BW:
                return "Enhance colors and make the photo more vibrant and lively."
            case .cinematic:
                return "Apply a cinematic filter to give the photo a dramatic, movie-like effect."
            case .film, .retro:
                return "Create a vintage look with classic film tones and textures."
            case .selfie:
                return "Optimized for selfies with smooth skin tones and enhanced facial features."
            case .scene:
                return "Perfect for capturing landscapes and scenes with balanced exposure and color."
            case .neutral:
                return "Keep the photo natural with minimal adjustments for a true-to-life look."
            }
        }
}

enum ColorName: String {
    case basicA1 = "basic-1"
    case basicA2 = "basic-2"
    case basicA3 = "basic-3"
    case cinematicC1 = "Cinematic-1"
    case cinematicC2 = "Cinematic-2"
    case cinematicC3 = "Cinematic-3"
    case cinematicC4 = "Cinematic-4"
    case cinematicC5 = "Cinematic-5"
    case cinematicC6 = "Cinematic-6"
    case cinematicC7 = "Cinematic-7"
    case cinematicC8 = "Cinematic-8"
    case cinematicC9 = "Cinematic-9"
    case cinematicC10 = "Cinematic-10"
    case film1 = "Film-1"
    case film2 = "Film-2"
    case film3 = "Film-3"
    case film4 = "Film-4"
    case film5 = "Film-5"
    case film6 = "Film-6"
    case selfie1 = "Selfie-1"
    case selfie2 = "Selfie-2"
    case selfie3 = "Selfie-3"
    case selfie4 = "Selfie-4"
    case selfie5 = "Selfie-5"
    case selfie6 = "Selfie-6"
    case selfie7 = "Selfie-7"
    case selfie8 = "Selfie-8"
    case selfie9 = "Selfie-9"
    case selfie10 = "Selfie-10"
    case tan1 = "lut-1"
    case tan2 = "lut-2"
    case tan3 = "lut-3"
    case tan4 = "lut-4"
    case tan5 = "lut-5"
    case tan6 = "lut-6"
    case tan7 = "lut-7"
    case tan8 = "lut-8"
    case tan9 = "lut-9"
    case tan10 = "lut-10"
    
    case BW1 = "BW1"
    case BW2 = "BW2"
    case BW3 = "BW3"
    
    case BW4 = "BW4"
    case BW5 = "BW5"
    case BW6 = "BW6"
    
    
    case retro1 = "retro1"
    case retro2 = "retro2"
    case retro3 = "retro3"
    case retro4 = "retro4"
}

class DataColor: ObservableObject {
    
    static var shared = DataColor(type: .basic)
    public var style: ColorStyle = .basic
    {
        didSet {
            
        }
    }
    
    init(type: ColorStyle) {
        autoreleasepool {
            neutralLUT = UIImage(named: "lut-normal")!
            neutralCube = FilterColorCube(
                name: "Neutral",
                identifier: "neutral",
                lutImage: neutralLUT,
                dimension: 64
            )
            
            let retro = Collection(type: .retro, name: "retro", identifier: "retro", cubeInfos: [])
            for i in 1...6 {
                switch i {
                case 1,4,5:
                    let cube = FilterColorCubeInfo(
                        name: "retro\(i)",
                        identifier: "retro\(i)",
                        lutImage: "retro\(i)",
                        isHot: true
                    )
                    retro.cubeInfos.append(cube)
                default:
                    let cube = FilterColorCubeInfo(
                        name: "retro\(i)",
                        identifier: "retro\(i)",
                        lutImage: "retro\(i)",
                        isHot: false
                    )
                    retro.cubeInfos.append(cube)
                }
                
            }
            collections.append(retro)
            
            let basic = Collection(type: .basic, name: "Basic", identifier: "Basic", cubeInfos: [])
            for i in 1...3 {
                switch i {
                case 3:
                    let cube = FilterColorCubeInfo(
                        name: "A\(i)",
                        identifier: "basic-\(i)",
                        lutImage: "lut-\(i)",
                        isHot: true
                    )
                    basic.cubeInfos.append(cube)
                default:
                    let cube = FilterColorCubeInfo(
                        name: "A\(i)",
                        identifier: "basic-\(i)",
                        lutImage: "lut-\(i)",
                        isHot: false
                    )
                    basic.cubeInfos.append(cube)
                }
               
               
            }
            collections.append(basic)
            
            let cinematic = Collection(type: .cinematic, name: "Cinematic", identifier: "Cinematic", cubeInfos: [])
            for i in 1...10 {
                switch i {
                case 2,5,10:
                    let cube = FilterColorCubeInfo(
                        name: "C\(i)",
                        identifier: "Cinematic-\(i)",
                        lutImage: "cinematic-\(i)",
                        isHot: true
                    )
                    cinematic.cubeInfos.append(cube)
                default :
                    let cube = FilterColorCubeInfo(
                        name: "C\(i)",
                        identifier: "Cinematic-\(i)",
                        lutImage: "cinematic-\(i)",
                        isHot: false
                    )
                    cinematic.cubeInfos.append(cube)
                }
                
            }
            collections.append(cinematic)
            
            let film = Collection(type: .film, name: "Film", identifier: "Film", cubeInfos: [])
            for i in 1...6 {
                switch i {
                case 2,4:
                    let cube = FilterColorCubeInfo(
                        name: "Film\(i)",
                        identifier: "Film-\(i)",
                        lutImage: "film-\(i)",
                        isHot: true
                    )
                    film.cubeInfos.append(cube)
                default:
                    let cube = FilterColorCubeInfo(
                        name: "Film\(i)",
                        identifier: "Film-\(i)",
                        lutImage: "film-\(i)",
                        isHot: false
                    )
                    film.cubeInfos.append(cube)
                }
            
            }
            collections.append(film)
            
            let selfie = Collection(type: .selfie, name: "Selfie", identifier: "Selfie", cubeInfos: [])
            for i in 1...10 {
                switch i {
                case 2,5,10:
                    let cube = FilterColorCubeInfo(
                        name: "Selfie\(i)",
                        identifier: "Selfie-\(i)",
                        lutImage: "selfie-\(i)",
                        isHot: true
                    )
                    selfie.cubeInfos.append(cube)
                default:
                    let cube = FilterColorCubeInfo(
                        name: "Selfie\(i)",
                        identifier: "Selfie-\(i)",
                        lutImage: "selfie-\(i)",
                        isHot: false
                    )
                    selfie.cubeInfos.append(cube)
                }
                
            }
            collections.append(selfie)
            
            let tan = Collection(type: .scene, name: "Tan", identifier: "Tan", cubeInfos: [])
            for i in 1...10 {
                switch i {
                    case 2,6,8,10:
                    let cube = FilterColorCubeInfo(
                        name: "lut\(i)",
                        identifier: "lut-\(i)",
                        lutImage: "lut-\(i)",
                        isHot: true
                    )
                    tan.cubeInfos.append(cube)
                default:
                    let cube = FilterColorCubeInfo(
                        name: "lut\(i)",
                        identifier: "lut-\(i)",
                        lutImage: "lut-\(i)",
                        isHot: false
                    )
                    tan.cubeInfos.append(cube)
                }
            }
            collections.append(tan)
            
            let bw = Collection(type: .BW, name: "BW", identifier: "BW", cubeInfos: [])
            for i in 1...6 {
                switch i {
                case 1,5:
                    let cube = FilterColorCubeInfo(
                        name: "BW\(i)",
                        identifier: "BW\(i)",
                        lutImage: "BW\(i)",
                        isHot: true
                    )
                    bw.cubeInfos.append(cube)
                default:
                    let cube = FilterColorCubeInfo(
                        name: "BW\(i)",
                        identifier: "BW\(i)",
                        lutImage: "BW\(i)",
                        isHot: false
                    )
                    bw.cubeInfos.append(cube)
                }
                
            }
            collections.append(bw)
            
            
        }
    }
    
    var neutralLUT: UIImage!
    var neutralCube: FilterColorCube!
    var collections: [Collection] = []
    var collectionsSelected: [Collection] = []
    
    // Cube by collection
    func cubeBy(identifier: ColorName) -> FilterColorCube? {
        for collection in self.collectionsSelected {
            for cube in collection.cubeInfos {
                if cube.identifier == identifier.rawValue {
                    return cube.getFilter()
                }
            }
        }
        return nil
    }
}

