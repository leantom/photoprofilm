//
//  paintingStyle.swift
//  PhotoProFilm
//
//  Created by QuangHo on 25/9/24.
//

import Foundation
struct PaintingStyle: Codable {
    var title: String?
    var description: String?
    var outstandingAuthor: String?
    var imageUrl: String?
    var order: Int?
    var createdAt: String?
    var style: String?
    var introductoryArticle: String?
    init() {
           self.title = "Sketchy City"
           self.description = "A pencil sketch of a bustling city street."
           self.outstandingAuthor = "Pablo Picasso"
           self.imageUrl = "https://storage.googleapis.com/pod_public/1300/183924.jpg"
           self.order = 0
           self.createdAt = ""
           self.style = "Vivid"
           self.introductoryArticle = "Introduction to Vivid Art:\n\nVivid art captures the eye with bold, intense, and radiant colors that convey powerful emotions and energy. This art style, embraced by artists like Claude Monet, transcends traditional boundaries, focusing less on exact representation and more on the impact of color and atmosphere.\n\n---\n\n'Sunset Bliss': A Masterpiece in Vivid Art:\n\n- 'Sunset Bliss' exemplifies this style by using deep oranges, reds, and blues to depict a stunning sunset scene.\n- The glow of the setting sun immerses the viewer in warmth and tranquility.\n- Monet, a leading figure of Impressionism, pushed vivid art by using color as a means of expression rather than just a tool for depicting nature.\n\n---\n\nKey Characteristics of Vivid Art:\n\n- Emotional Power: The hallmark of vivid art lies in its ability to evoke emotions.\n  - Artists use pure, unblended hues, making each shade pop from the canvas.\n  - This technique allows them to exaggerate reality, crafting a vibrant visual language.\n\n- Vivid Experience in 'Sunset Bliss':\n  - Monet’s use of color turns a simple sunset into an emotional experience.\n  - The viewer can almost feel the warmth of the sun and the coolness of the evening breeze.\n  - The fiery glow of the sun and the calm blues of the water guide the viewer’s eye across the canvas, inviting them to pause and absorb the beauty of the moment.\n\n---\n\nMonet’s Mastery in Vivid Art:\n\n- Monet’s brilliance in creating this vivid experience showcases the emotional power of color in art.\n- Vivid art is often used in landscape paintings, like Monet’s, where the artist seeks to convey the grandeur and awe of nature.\n\n---\n\nThe Influence of Vivid Art in Modern Times:\n\n- This style’s influence extends into modern art, where vivid color is often a primary element in abstract and contemporary works.\n- Universal Appeal: The appeal of vivid art lies in its universal ability to communicate emotion, allowing viewers from diverse backgrounds to experience the artwork in a deeply personal way.\n\n---\n\nVivid Art: A Celebration of Color and Emotion:\n\n- In a world where subtlety often dominates, vivid art stands out as a celebration of color and emotion.\n- It’s a style that embraces the raw power of color, and its boldness allows it to connect with viewers in a truly visceral way."


    }
    
}


