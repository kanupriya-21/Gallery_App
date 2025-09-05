//
//  GalleryViewModel.swift
//  GalleryApp
//
//  Created by Kanupriya Rajpal on 06/09/25.
//

import Foundation
import UIKit

protocol GalleryViewModelDelegate: AnyObject {
    func didLoadImages()
    func didSelectImage(at index: Int)
}

class GalleryViewModel {
    
    // MARK: - Properties
    private var model = GalleryModel()
    weak var delegate: GalleryViewModelDelegate?
    
    // MARK: - Public Methods
    func loadImages() {
        model.generateImages(count: 20)
        delegate?.didLoadImages()
    }
    
    func getImageCount() -> Int {
        return model.images.count
    }
    
    func getImage(at index: Int) -> GalleryImage? {
        guard index >= 0 && index < model.images.count else { return nil }
        return model.images[index]
    }
    
    func getImageURL(at index: Int) -> String? {
        return getImage(at: index)?.imageURL
    }
    
    func didSelectImage(at index: Int) {
        delegate?.didSelectImage(at: index)
    }
}
