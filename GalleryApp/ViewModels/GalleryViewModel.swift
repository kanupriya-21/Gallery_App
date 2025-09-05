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
    private let pageSize = 20
    private var currentPage = 1
    private var isLoading = false
    
    // MARK: - Public Methods
    func loadImages() {
        currentPage = 1
        model.images = []
        loadMoreImages()
    }
    
    func loadMoreImages() {
        guard !isLoading else { return }
        
        isLoading = true
        print("Loading page \(currentPage)...")
        
        // Simulate network delay
        DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let self = self else { return }
            
            // Generate new images for current page
            let startIndex = (self.currentPage - 1) * self.pageSize + 1
            let endIndex = self.currentPage * self.pageSize
            
            for i in startIndex...endIndex {
                let image = GalleryImage(id: "\(i)")
                self.model.images.append(image)
            }
            
            self.currentPage += 1
            self.isLoading = false
            
            DispatchQueue.main.async {
                self.delegate?.didLoadImages()
            }
        }
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
    
    func shouldLoadMore(for index: Int) -> Bool {
        // Load more when user reaches the last 5 items
        return index >= model.images.count - 5 && !isLoading
    }
}
