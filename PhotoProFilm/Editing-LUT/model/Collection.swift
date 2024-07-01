//
//  Collection.swift
//  colorful-room
//
//  Created by macOS on 7/15/20.
//  Copyright © 2020 PingAK9. All rights reserved.
//

import Foundation
import PixelEnginePackage
import SwiftUI
import Combine

public class Collection: ObservableObject {
    
    public let name: String
    public let identifier: String
    public var cubeInfos:[FilterColorCubeInfo]
    public var cubePreviews:[PreviewFilterColorCube] = []
    @Published var isDoneFilter = false
    public var colorType: ColorStyle = .basic
   
    public func setImage(image:CIImage?){
        self.cubePreviews = []
        if let cubeSourceCI: CIImage = image
        {
            let now = Date()
           
            for item in cubeInfos {
                
                print("item.name: \(item.name)")
                print("time progress: \(Date().timeIntervalSince1970 - now.timeIntervalSince1970)")
                
                let cube = FilterColorCube(name: item.name, identifier: item.identifier, lutImage: UIImage(named: item.lutImage)!, dimension: 64);
                let preview = PreviewFilterColorCube(sourceImage: cubeSourceCI, filter: cube)
                cubePreviews.append(preview)
                
            }
        }
    }
    
    public func setImageV2(image: CIImage?) {
        self.cubePreviews = []
        guard let cubeSourceCI = image else { return }
        
        let now = Date()
        let dispatchGroup = DispatchGroup()
        let dispatchQueue = DispatchQueue.global(qos: .userInitiated)
        let serialQueue = DispatchQueue(label: "com.yourapp.cubePreviewsQueue")
        
        for item in cubeInfos {
            dispatchGroup.enter()
            dispatchQueue.async {
                print("item.name: \(item.name)")
                print("time progress: \(Date().timeIntervalSince1970 - now.timeIntervalSince1970)")
                
                guard let lutImage = UIImage(named: item.lutImage) else {
                    dispatchGroup.leave()
                    return
                }
                
                let cube = FilterColorCube(name: item.name, identifier: item.identifier, lutImage: lutImage, dimension: 64)
                let preview = PreviewFilterColorCube(sourceImage: cubeSourceCI, filter: cube)
                
                serialQueue.async {
                    self.cubePreviews.append(preview)
                    print("item.name done: \(item.name)")
                    dispatchGroup.leave()
                }
            }
        }
        
        dispatchGroup.notify(queue: DispatchQueue.main) {
            print("Total time: \(Date().timeIntervalSince1970 - now.timeIntervalSince1970)")
            self.isDoneFilter = true
        }
    }

    
    ///
    public func reset(){
        cubePreviews = []
        isDoneFilter = false
    }
    
    ///
    public init(
        type: ColorStyle,
        name: String,
        identifier: String,
        cubeInfos: [FilterColorCubeInfo] = []
    ) {
        self.colorType = type
        self.name = name
        self.identifier = identifier
        self.cubeInfos = cubeInfos
    }
    
   
}


public struct FilterColorCubeInfo : Equatable {
    public let name: String
    public let identifier: String
    public let lutImage:String
    
    public init(
        name: String,
        identifier: String,
        lutImage: String
    ) {
        self.name = name
        self.identifier = identifier
        self.lutImage = lutImage
    }
    
    func getFilter()-> FilterColorCube{
        return FilterColorCube(name: name, identifier: identifier, lutImage: UIImage(named: lutImage)!, dimension: 64)
    }
    
}
