//
//  ImageCacheManager.swift
//  GalleryApp
//
//  Created by Kanupriya Rajpal on 06/09/25.
//

import UIKit

class ImageCacheManager {
    
    // MARK: - Singleton
    static let shared = ImageCacheManager()
    
    // MARK: - Properties
    private let cacheDirectory: URL
    private let maxCacheSize: Int = 100 * 1024 * 1024 // 100MB
    private let maxCacheAge: TimeInterval = 7 * 24 * 60 * 60 // 7 days
    private let cachedImagesKey = "GalleryApp_CachedImageURLs"
    
    // MARK: - Initialization
    private init() {
        // Create cache directory in Documents folder
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        cacheDirectory = documentsPath.appendingPathComponent("ImageCache")
        
        print("ImageCacheManager initialized")
        print("Cache directory: \(cacheDirectory.path)")
        print("Cache key: \(cachedImagesKey)")
        
        // Create cache directory if it doesn't exist
        createCacheDirectoryIfNeeded()
        
        // Clean old cache on initialization
        cleanOldCache()
        
        // Debug: Check what's in UserDefaults
        let existingURLs = UserDefaults.standard.stringArray(forKey: cachedImagesKey) ?? []
        print("Initialization: Found \(existingURLs.count) existing cached URLs")
    }
    
    // MARK: - Public Methods
    
    /// Save image to disk cache
    func saveImageToDisk(_ image: UIImage, forKey key: String) {
        guard let data = image.jpegData(compressionQuality: 0.8) else { return }
        
        let fileURL = cacheDirectory.appendingPathComponent("\(key).jpg")
        
        do {
            try data.write(to: fileURL)
            addCachedImageURL(key)
            print("Image cached to disk: \(key)")
        } catch {
            print("Failed to cache image to disk: \(error)")
        }
    }
    
    /// Load image from disk cache
    func loadImageFromDisk(forKey key: String) -> UIImage? {
        let fileURL = cacheDirectory.appendingPathComponent("\(key).jpg")
        
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            return nil
        }
        
        do {
            let data = try Data(contentsOf: fileURL)
            let image = UIImage(data: data)
            print("Image loaded from disk cache: \(key)")
            return image
        } catch {
            print("Failed to load image from disk: \(error)")
            return nil
        }
    }
    
    /// Check if image exists in disk cache
    func hasImageInDiskCache(forKey key: String) -> Bool {
        let fileURL = cacheDirectory.appendingPathComponent("\(key).jpg")
        return FileManager.default.fileExists(atPath: fileURL.path)
    }
    
    /// Get current cache size
    func getCacheSize() -> Int {
        var totalSize = 0
        
        do {
            let files = try FileManager.default.contentsOfDirectory(at: cacheDirectory, includingPropertiesForKeys: [.fileSizeKey])
            for file in files {
                let attributes = try FileManager.default.attributesOfItem(atPath: file.path)
                if let size = attributes[.size] as? Int {
                    totalSize += size
                }
            }
        } catch {
            print("Failed to calculate cache size: \(error)")
        }
        
        return totalSize
    }
    
    /// Clear all cached images
    func clearAllCache() {
        do {
            let files = try FileManager.default.contentsOfDirectory(at: cacheDirectory, includingPropertiesForKeys: nil)
            for file in files {
                try FileManager.default.removeItem(at: file)
            }
            clearCachedImageURLs()
            print("All cache cleared")
        } catch {
            print("Failed to clear cache: \(error)")
        }
    }
    
    /// Get all cached image URLs
    func getCachedImageURLs() -> [String] {
        let urls = UserDefaults.standard.stringArray(forKey: cachedImagesKey) ?? []
        print("ImageCacheManager: Retrieved \(urls.count) cached URLs from UserDefaults")
        for (index, url) in urls.enumerated() {
            print("   \(index + 1): \(url)")
        }
        return urls
    }
    
    /// Get cached image count
    func getCachedImageCount() -> Int {
        return getCachedImageURLs().count
    }
    
    /// Debug method to test cache functionality
    func debugCacheStatus() {
        print("=== CACHE DEBUG STATUS ===")
        print("Cache directory exists: \(FileManager.default.fileExists(atPath: cacheDirectory.path))")
        print("UserDefaults key: \(cachedImagesKey)")
        
        let urls = getCachedImageURLs()
        print("Cached URLs count: \(urls.count)")
        
        for (index, url) in urls.enumerated() {
            let fileURL = cacheDirectory.appendingPathComponent("\(url).jpg")
            let fileExists = FileManager.default.fileExists(atPath: fileURL.path)
            print("   \(index + 1): \(url) - File exists: \(fileExists)")
        }
        
        print("Cache size: \(getCacheSize()) bytes")
        print("=== END CACHE DEBUG ===")
    }
    
    /// Test method to manually add a URL to cache
    func testAddURLToCache(_ url: String) {
        print("Testing: Adding URL to cache: \(url)")
        addCachedImageURL(url)
        
        // Test retrieval
        let retrievedURLs = getCachedImageURLs()
        print("Testing: Retrieved \(retrievedURLs.count) URLs after adding")
        if retrievedURLs.contains(url) {
            print("Test PASSED: URL successfully saved and retrieved")
        } else {
            print("Test FAILED: URL not found after saving")
        }
    }
    
    // MARK: - Private Methods
    
    private func createCacheDirectoryIfNeeded() {
        if !FileManager.default.fileExists(atPath: cacheDirectory.path) {
            do {
                try FileManager.default.createDirectory(at: cacheDirectory, withIntermediateDirectories: true, attributes: nil)
                print("Cache directory created: \(cacheDirectory.path)")
            } catch {
                print("Failed to create cache directory: \(error)")
            }
        }
    }
    
    private func cleanOldCache() {
        do {
            let files = try FileManager.default.contentsOfDirectory(at: cacheDirectory, includingPropertiesForKeys: [.creationDateKey])
            let now = Date()
            var removedURLs: [String] = []
            
            for file in files {
                let attributes = try FileManager.default.attributesOfItem(atPath: file.path)
                if let creationDate = attributes[.creationDate] as? Date {
                    if now.timeIntervalSince(creationDate) > maxCacheAge {
                        try FileManager.default.removeItem(at: file)
                        let imageKey = file.lastPathComponent.replacingOccurrences(of: ".jpg", with: "")
                        removedURLs.append(imageKey)
                        print("Removed old cached image: \(file.lastPathComponent)")
                    }
                }
            }
            
            // Remove URLs from UserDefaults
            if !removedURLs.isEmpty {
                removeCachedImageURLs(removedURLs)
            }
        } catch {
            print("Failed to clean old cache: \(error)")
        }
    }
    
    private func addCachedImageURL(_ url: String) {
        var cachedURLs = getCachedImageURLs()
        if !cachedURLs.contains(url) {
            cachedURLs.append(url)
            UserDefaults.standard.set(cachedURLs, forKey: cachedImagesKey)
            UserDefaults.standard.synchronize() // Force save to disk
            print("ImageCacheManager: Added URL to cache: \(url)")
            print("Total cached URLs: \(cachedURLs.count)")
            
            // Verify it was saved
            let savedURLs = UserDefaults.standard.stringArray(forKey: cachedImagesKey) ?? []
            print("Verification: \(savedURLs.count) URLs in UserDefaults after save")
        } else {
            print("ImageCacheManager: URL already in cache: \(url)")
        }
    }
    
    private func removeCachedImageURLs(_ urls: [String]) {
        var cachedURLs = getCachedImageURLs()
        cachedURLs.removeAll { urls.contains($0) }
        UserDefaults.standard.set(cachedURLs, forKey: cachedImagesKey)
    }
    
    private func clearCachedImageURLs() {
        UserDefaults.standard.removeObject(forKey: cachedImagesKey)
    }
    
    /// Clean cache if it exceeds max size
    func cleanCacheIfNeeded() {
        let currentSize = getCacheSize()
        if currentSize > maxCacheSize {
            print("Cache size (\(currentSize)) exceeds limit (\(maxCacheSize)), cleaning...")
            
            do {
                let files = try FileManager.default.contentsOfDirectory(at: cacheDirectory, includingPropertiesForKeys: [.creationDateKey])
                let sortedFiles = files.sorted { file1, file2 in
                    let date1 = (try? FileManager.default.attributesOfItem(atPath: file1.path)[.creationDate] as? Date) ?? Date.distantPast
                    let date2 = (try? FileManager.default.attributesOfItem(atPath: file2.path)[.creationDate] as? Date) ?? Date.distantPast
                    return date1 < date2
                }
                
                // Remove oldest files until we're under the limit
                var sizeToRemove = currentSize - (maxCacheSize * 3 / 4) // Keep 75% of max size
                for file in sortedFiles {
                    if sizeToRemove <= 0 { break }
                    
                    let attributes = try FileManager.default.attributesOfItem(atPath: file.path)
                    if let size = attributes[.size] as? Int {
                        try FileManager.default.removeItem(at: file)
                        sizeToRemove -= size
                        print("Removed cached image to free space: \(file.lastPathComponent)")
                    }
                }
            } catch {
                print("Failed to clean cache: \(error)")
            }
        }
    }
}
