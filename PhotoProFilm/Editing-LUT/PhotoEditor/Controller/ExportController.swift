//
//  Export.swift
//  colorful-room
//
//  Created by Ping9 on 16/01/2022.
//

import Foundation
import Combine
import SwiftUI
import PixelEnginePackage
 
import CoreData


class ExportController : ObservableObject{
    
    // Export
    @Published var originExport:UIImage?
    @Published var isExportPrepared: Bool = false
    
    var originRatio: Double {
        get{
            PECtl.shared.originUI.size.width/PECtl.shared.originUI.size.height;
        }
    }
    
    var controller: PECtl {
        get {
            PECtl.shared
        }
    }
    
    func prepareExport() {
        if(originExport == nil){
            self.controller.didReceive(action: .commit)
            DispatchQueue.main.async {

                self.originExport = self.controller.editState.makeRenderer().render(resolution: .full)
                
                self.isExportPrepared = true
            }
        }
    }
    
    func resetExport() {
        originExport = nil
    }
    
    func exportOrigin() {
        if let origin = originExport{
            ImageSaver().writeToPhotoAlbum(image: origin)
        }
        return
    }
   
}
