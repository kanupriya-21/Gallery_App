//
//  GalleryModel.swift
//  GalleryApp
//
//  Created by Kanupriya Rajpal on 06/09/25.
//

import Foundation

struct GalleryImage {
    let id: String
    let imageURL: String
    let width: Int
    let height: Int
    
    init(id: String, width: Int = 400, height: Int = 400) {
        self.id = id
        self.width = width
        self.height = height
        self.imageURL = "https://picsum.photos/\(width)/\(height)?random=\(id)"
    }
}

struct GalleryModel {
    var images: [GalleryImage] = []
    
    mutating func generateImages(count: Int = 20) {
        images = []
        for i in 1...count {
            let image = GalleryImage(id: "\(i)")
            images.append(image)
        }
    }
}
