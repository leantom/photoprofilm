//
//  Utils+Extenstion.swift
//  PhotoProFilm
//
//  Created by QuangHo on 25/9/24.
//
import FirebaseFirestore

enum Screen: String {
    case setting = "Setting"
    case login = "Login"
    case category = "category"
    case choosePicker = "ChoosePicker"
    case personalInfo = "PersonalInfo"
    case aboutUs = "AboutUs"
    case privacy = "Privacy"
    case instruction = "Instruction"
    case photo = "photo"
    case savePhoto = "savePhoto"
    case editPhoto = "editPhoto"
   
    case unknown
    
    init(rawValue: String) {
        switch rawValue {
        case "Setting": self = .setting
        case "Login": self = .login
        case "category": self = .category
        case "ChoosePicker": self = .choosePicker
        case "PersonalInfo": self = .personalInfo
        case "AboutUs": self = .aboutUs
        case "Privacy": self = .privacy
        case "Instruction": self = .instruction
        case "photo": self = .photo
        case "savePhoto": self = .savePhoto
        case "editPhoto": self = .editPhoto
        default: self = .unknown
        }
    }
}

var staticPaintingStyle: [PaintingStyle]?

func getStylePainting() async throws -> [PaintingStyle] {
    let db = Firestore.firestore()
    
    do {
        let document = try await db.collection("settings").document("9zxOBlwNLQEvHOYe3h0I").getDocument()
        
        if let data = document.data() {
            if let paintingStylesValue = data["paintingstyles"] {
                print("paintingstyles field value: \(paintingStylesValue)")
                print("Type of paintingstyles: \(type(of: paintingStylesValue))")
                
                if let paintingStylesArray = paintingStylesValue as? [[String: Any]] {
                    let jsonData = try JSONSerialization.data(withJSONObject: paintingStylesArray)
                    let paintingStyles = try JSONDecoder().decode([PaintingStyle].self, from: jsonData)
                    return paintingStyles
                } else if let paintingStylesString = paintingStylesValue as? String {
                    if let jsonData = paintingStylesString.data(using: .utf8) {
                        let paintingStyles = try JSONDecoder().decode([PaintingStyle].self, from: jsonData)
                        return paintingStyles
                    } else {
                        print("Error converting paintingstyles string to Data")
                        return []
                    }
                } else {
                    print("paintingstyles field is not a valid array or string")
                    return []
                }
            } else {
                print("paintingstyles field does not exist")
                return []
            }
        } else {
            print("Document does not exist or contains no data.")
            return []
        }
    } catch {
        print("Error fetching document: \(error.localizedDescription)")
        throw error
    }
}
