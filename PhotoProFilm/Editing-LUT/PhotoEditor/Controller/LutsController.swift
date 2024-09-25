//
//  LutsController.swift
//  colorful-room
//
//  Created by Ping9 on 28/06/2022.
//
import Foundation
import Combine
import SwiftUI
import PixelEnginePackage
import CoreData

class LutsController : ObservableObject{
    
    @Published var loadingLut:Bool = false
    
    // Cube
    var collections:[Collection] = []
    var cubeSourceCG:CGImage?
    
    @Published var currentCube:String = ""
    @Published var editingLut:Bool = false
    private var cancellables = Set<AnyCancellable>()
    
    var showLoading:Bool{
        get{
            return loadingLut || cubeSourceCG == nil
        }
    }
    
    func setImage(image:CIImage){
        currentCube = ""
        /// setImage
        self.cubeSourceCG = nil
        loadingLut = true
        collections = DataColor.shared.collectionsSelected
        
        DispatchQueue.global(qos: .background).async{
            print("init Cube")
            self.cubeSourceCG = sharedContext.createCGImage(image, from: image.extent)!
            self.observeCollections()
            for e in self.collections {
                e.setImageV2(image: image)
            }
        }
    }
    
    private func observeCollections() {
        cancellables.removeAll()
          for collection in collections {
              collection.$isDoneFilter
                  .receive(on: DispatchQueue.main)
                  .sink { [weak self] isDone in
                      if isDone {
                          self?.checkAllCollectionsDone()
                      }
                  }
                  .store(in: &cancellables)
          }
      }

      private func checkAllCollectionsDone() {
          if collections.allSatisfy({ $0.isDoneFilter }) {
              print("All collections are done")
              loadingLut = false
          }
      }
    
    
    ///
    func selectCube(_ value:String){
        currentCube = value
    }
    
    ///
    func onSetEditingMode(_ value:Bool){
        editingLut = value
    }
    
}
