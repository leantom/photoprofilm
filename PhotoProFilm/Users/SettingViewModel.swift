//
//  SettingViewModel.swift
//  PhotoProFilm
//
//  Created by QuangHo on 24/7/24.
//

import Foundation
import SwiftUI
import FirebaseFirestore

class SettingViewModel: ObservableObject {
    @Published var aboutus: String = ""

    @Published var privacyPolicy: String = ""
    
    @Published var paintingStyles: String = ""
    
    
    private var db = Firestore.firestore()

    func fetchHtml() {
        db.collection("settings").document("9zxOBlwNLQEvHOYe3h0I").getDocument { (document, error) in
            if let document = document, document.exists {
                self.aboutus = document.data()?["aboutus"] as? String ?? ""
                self.privacyPolicy = document.data()?["privacy"] as? String ?? ""
                self.paintingStyles = document.data()?["paintingstyles"] as? String ?? ""
            } else {
                print("Document does not exist")
            }
        }
    }
}
