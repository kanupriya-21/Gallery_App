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
    private var hasLoadedInitialImages = false
    
    // MARK: - Public Methods
    func loadImages() {
        currentPage = 1
        model.images = []
        hasLoadedInitialImages = false
        
        // Check if we have cached images first
        let cachedURLs = ImageCacheManager.shared.getCachedImageURLs()
        print("Checking for cached images: Found \(cachedURLs.count) cached URLs")
        
        if !cachedURLs.isEmpty {
            print("Loading cached images first...")
            loadCachedImages()
        }
        
        // Then load more images from network if online
        if NetworkManager.shared.isConnected {
            print("Network available, loading more images...")
            loadMoreImages()
        } else {
            print("No network connection, showing cached images only")
        }
    }
    
    func loadMoreImages() {
        guard !isLoading else { return }
        
        // Check network connectivity
        if !NetworkManager.shared.isConnected {
            print("No network connection, cannot load more images")
            return
        }
        
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
            self.hasLoadedInitialImages = true
            
            DispatchQueue.main.async {
                self.delegate?.didLoadImages()
            }
        }
    }
    
    func loadCachedImages() {
        print("Loading cached images for offline viewing...")
        
        // Get actual cached image URLs
        let cachedURLs = ImageCacheManager.shared.getCachedImageURLs()
        print("Found \(cachedURLs.count) cached images")
        
        if cachedURLs.isEmpty {
            print("No cached images found!")
            return
        }
        
        // Create GalleryImage objects for cached images
        for (index, url) in cachedURLs.enumerated() {
            let image = GalleryImage(id: "\(index + 1)", customURL: url)
            model.images.append(image)
            print("Added cached image \(index + 1): \(url)")
        }
        
        print("Total images in model: \(model.images.count)")
        hasLoadedInitialImages = true
        
        DispatchQueue.main.async {
            print("Calling delegate to reload collection view...")
            self.delegate?.didLoadImages()
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
        // Only load more if we have network connection
        guard NetworkManager.shared.isConnected else { return false }
        
        // Load more when user reaches the last 5 items
        return index >= model.images.count - 5 && !isLoading
    }
    
    func isOffline() -> Bool {
        return !NetworkManager.shared.isConnected
    }
    
    func handleOfflineTransition() {
        print("Handling transition to offline mode...")
        
        // If we have images already loaded, keep them
        if !model.images.isEmpty {
            print("Keeping \(model.images.count) already loaded images for offline viewing")
            return
        }
        
        // If no images loaded, try to load cached images
        loadCachedImages()
    }
}
