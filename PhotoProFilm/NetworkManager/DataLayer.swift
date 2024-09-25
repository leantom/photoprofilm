//
//  DataLayer.swift
//  PhotoProFilm
//
//  Created by QuangHo on 1/7/24.
//

import Foundation
import FirebaseFirestore

func insertPaintingStyles() {
    let db = Firestore.firestore()
    
    let paintingStyles = [
        [
            "title": "Sunset Bliss",
            "description": "A vivid portrayal of a sunset over the ocean.",
            "outstandingAuthor": "Claude Monet",
            "imageUrl": "https://example.com/sunset-bliss.jpg",
            "order": 1,
            "createdAt": Date(),
            "style": "Vivid",
            "introductoryArticle": "Vivid art focuses on the use of bright, vibrant colors..."
        ],
        [
            "title": "Sketchy City",
            "description": "A pencil sketch of a bustling city street.",
            "outstandingAuthor": "Pablo Picasso",
            "imageUrl": "https://example.com/sketchy-city.jpg",
            "order": 2,
            "createdAt": Date(),
            "style": "Sketch",
            "introductoryArticle": "The sketch style captures the raw essence of form and movement..."
        ],
        // Add more painting styles here
    ]
    
    for style in paintingStyles {
        db.collection("paintingStyles").addDocument(data: style) { err in
            if let err = err {
                print("Error adding document: \(err)")
            } else {
                print("Document successfully added!")
            }
        }
    }
}
