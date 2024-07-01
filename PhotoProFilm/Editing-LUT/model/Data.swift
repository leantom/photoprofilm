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
    case basic = "Basic"
    case cinematic = "Cinematic"
    case film = "Film"
    case selfie = "Selfie"
    case scene = "Scene"
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
}

class DataColor: ObservableObject {
    
    static var shared = DataColor(type: .basic)
    public var style: ColorStyle = .basic
    {
        didSet {
            filterLUT()
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
            
            let basic = Collection(type: .basic, name: "Basic", identifier: "Basic", cubeInfos: [])
            for i in 1...3 {
                let cube = FilterColorCubeInfo(
                    name: "A\(i)",
                    identifier: "basic-\(i)",
                    lutImage: "lut-\(i)"
                )
                basic.cubeInfos.append(cube)
            }
            collections.append(basic)
            
            let cinematic = Collection(type: .cinematic, name: "Cinematic", identifier: "Cinematic", cubeInfos: [])
            for i in 1...10 {
                let cube = FilterColorCubeInfo(
                    name: "C\(i)",
                    identifier: "Cinematic-\(i)",
                    lutImage: "cinematic-\(i)"
                )
                cinematic.cubeInfos.append(cube)
            }
            collections.append(cinematic)
            
            let film = Collection(type: .film, name: "Film", identifier: "Film", cubeInfos: [])
            for i in 1...6 {
                let cube = FilterColorCubeInfo(
                    name: "Film\(i)",
                    identifier: "Film-\(i)",
                    lutImage: "film-\(i)"
                )
                film.cubeInfos.append(cube)
            }
            collections.append(film)
            
            let selfie = Collection(type: .selfie, name: "Selfie", identifier: "Selfie", cubeInfos: [])
            for i in 1...10 {
                let cube = FilterColorCubeInfo(
                    name: "Selfie\(i)",
                    identifier: "Selfie-\(i)",
                    lutImage: "selfie-\(i)"
                )
                selfie.cubeInfos.append(cube)
            }
            collections.append(selfie)
            
            let tan = Collection(type: .scene, name: "Tan", identifier: "Tan", cubeInfos: [])
            for i in 1...10 {
                let cube = FilterColorCubeInfo(
                    name: "lut\(i)",
                    identifier: "lut-\(i)",
                    lutImage: "lut-\(i)"
                )
                tan.cubeInfos.append(cube)
            }
            collections.append(tan)
        }
    }
    
    func filterLUT() {
        collectionsSelected = []
        switch style {
        case .basic:
            // basic
            let basic = Collection(type: .basic, name: "Basic", identifier: "Basic", cubeInfos: [])
            for i in 1...3 {
                let cube = FilterColorCubeInfo(
                    name: "A\(i)",
                    identifier: "basic-\(i)",
                    lutImage: "lut-\(i)"
                )
                basic.cubeInfos.append(cube)
            }
            collectionsSelected.append(basic)
        case .cinematic:
            // Cinematic
            let cinematic = Collection(type: .cinematic, name: "Cinematic", identifier: "Cinematic", cubeInfos: [])
            for i in 1...10 {
                let cube = FilterColorCubeInfo(
                    name: "C\(i)",
                    identifier: "Cinematic-\(i)",
                    lutImage: "cinematic-\(i)"
                )
                cinematic.cubeInfos.append(cube)
            }
            collectionsSelected.append(cinematic)
        case .film:
            // Film
            let film = Collection(type: .film, name: "Film", identifier: "Film", cubeInfos: [])
            for i in 1...6 {
                let cube = FilterColorCubeInfo(
                    name: "Film\(i)",
                    identifier: "Film-\(i)",
                    lutImage: "film-\(i)"
                )
                film.cubeInfos.append(cube)
            }
            collectionsSelected.append(film)
        case .selfie:
            // Selfie Good Skin
            let selfie = Collection(type: .selfie, name: "Selfie", identifier: "Selfie", cubeInfos: [])
            for i in 1...10 {
                let cube = FilterColorCubeInfo(
                    name: "Selfie\(i)",
                    identifier: "Selfie-\(i)",
                    lutImage: "selfie-\(i)"
                )
                selfie.cubeInfos.append(cube)
            }
            collectionsSelected.append(selfie)
        case .scene:
            // Tan
            let tan = Collection(type: .scene, name: "Tan", identifier: "Tan", cubeInfos: [])
            for i in 1...10 {
                let cube = FilterColorCubeInfo(
                    name: "lut\(i)",
                    identifier: "lut-\(i)",
                    lutImage: "lut-\(i)"
                )
                tan.cubeInfos.append(cube)
            }
            collectionsSelected.append(tan)
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

