//
//  GalleryViewController.swift
//  GalleryApp
//
//  Created by Kanupriya Rajpal on 06/09/25.
//

import UIKit

class GalleryViewController: UIViewController {

    @IBOutlet weak var galleryCollectionView: UICollectionView!
    @IBOutlet weak var profileButton: UIButton!
    
    // MARK: - ViewModel
    private let viewModel = GalleryViewModel()
    
    // MARK: - Offline Indicator
    private var offlineLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupViewModel()
        setupCollectionView()
        setupOfflineIndicator()
        setupNetworkObserver()
        viewModel.loadImages()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        DispatchQueue.main.async {
            self.galleryCollectionView.setNeedsLayout()
            self.galleryCollectionView.layoutIfNeeded()
        }
        // Update offline indicator
        updateOfflineIndicator()
    }
    
    private func setupViewModel() {
        viewModel.delegate = self
    }
    
    private func setupCollectionView() {
        galleryCollectionView.delegate = self
        galleryCollectionView.dataSource = self
        
        galleryCollectionView.register(UINib(nibName: "GalleryCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "GalleryCollectionViewCell")
        
        // Setup collection view layout
        if let layout = galleryCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.minimumInteritemSpacing = 10
            layout.minimumLineSpacing = 10
            layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
            layout.scrollDirection = .vertical
        }
        galleryCollectionView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func setupOfflineIndicator() {
        offlineLabel = UILabel()
        offlineLabel.text = "Offline Mode - Showing Cached Images"
        offlineLabel.textAlignment = .center
        offlineLabel.backgroundColor = UIColor.systemOrange.withAlphaComponent(0.9)
        offlineLabel.textColor = .white
        offlineLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        offlineLabel.layer.cornerRadius = 8
        offlineLabel.clipsToBounds = true
        offlineLabel.translatesAutoresizingMaskIntoConstraints = false
        offlineLabel.isHidden = true
        
        view.addSubview(offlineLabel)
        
        NSLayoutConstraint.activate([
            offlineLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            offlineLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            offlineLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            offlineLabel.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    private func updateOfflineIndicator() {
        let isOffline = !NetworkManager.shared.isConnected
        offlineLabel.isHidden = !isOffline
        
        if isOffline {
            print("App is in offline mode - showing cached images only")
            printCacheInfo()
            
            // Refresh collection view to show offline state
            DispatchQueue.main.async {
                self.galleryCollectionView.reloadData()
            }
        }
    }
    
    private func printCacheInfo() {
        let cacheSize = ImageCacheManager.shared.getCacheSize()
        let cacheSizeMB = Double(cacheSize) / (1024 * 1024)
        print("Cache Info:")
        print("   - Cache Size: \(String(format: "%.2f", cacheSizeMB)) MB")
        print("   - Images in cache: Available for offline viewing")
    }
    
    private func setupNetworkObserver() {
        // Observe network changes
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(networkStatusChanged),
            name: .init("NetworkStatusChanged"),
            object: nil
        )
    }
    
    @objc private func networkStatusChanged() {
        DispatchQueue.main.async {
            self.updateOfflineIndicator()
            
            if NetworkManager.shared.isConnected {
                // Network reconnected
                if self.viewModel.getImageCount() == 0 {
                    print("Network reconnected, loading images...")
                    self.viewModel.loadImages()
                }
            } else {
                // Network disconnected - handle offline transition
                print("Network disconnected, handling offline transition...")
                self.viewModel.handleOfflineTransition()
            }
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @IBAction func profileButtonPressed(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "ProfileScreen", bundle: nil)
        if let profileVC = storyboard.instantiateViewController(withIdentifier: "ProfileViewController") as? ProfileViewController {
            print("profile button tapped")
            print("NavigationController: \(String(describing: navigationController))")
            
            if let navController = navigationController {
                print("Navigation controller exists, pushing view controller")
                navController.pushViewController(profileVC, animated: true)
            } else {
                print("Navigation controller is nil, using present instead")
                profileVC.modalPresentationStyle = .fullScreen
                present(profileVC, animated: true)
            }
        }
    }
    
}

// MARK: - UICollectionViewDataSource
extension GalleryViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.getImageCount()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GalleryCollectionViewCell", for: indexPath) as! GalleryCollectionViewCell
        
        // Check load more images (pagination) - only if online
        if viewModel.shouldLoadMore(for: indexPath.item) {
            viewModel.loadMoreImages()
        }
        
        // Get image URL from ViewModel
        if let imageURL = viewModel.getImageURL(at: indexPath.item) {
            cell.configure(with: imageURL)
        } else {
            // Handle case where no image URL is available
            // Set a placeholder image for offline mode
            if viewModel.isOffline() {
                cell.galleryImageView.image = UIImage(systemName: "photo")
                cell.galleryImageView.tintColor = .systemGray
            } else {
                cell.galleryImageView.image = nil
            }
        }
        
        return cell
    }
}

// MARK: - UICollectionViewDelegate
extension GalleryViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // Handle cell selection through ViewModel
        viewModel.didSelectImage(at: indexPath.item)
    }
    
}

// MARK: - UICollectionViewDelegateFlowLayout
extension GalleryViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellSize: CGFloat = 180
        
//        // Debug print to track sizing
//        print("Cell size for index \(indexPath.item): \(cellSize)x\(cellSize)")
//        
        return CGSize(width: cellSize, height: cellSize)
    }
}

// MARK: - Image Loading Extension with Disk Caching
extension UIImageView {
    private static var imageCache = NSCache<NSString, UIImage>()
    
    func loadImage(from urlString: String) {
        guard let url = URL(string: urlString) else { return }
        
        // Create cache key from URL
        let cacheKey = NSString(string: urlString)
        
        // 1. Check memory cache first (fastest)
        if let cachedImage = UIImageView.imageCache.object(forKey: cacheKey) {
            DispatchQueue.main.async {
                self.image = cachedImage
            }
            return
        }
        
        // 2. Check disk cache (fast)
        if let diskImage = ImageCacheManager.shared.loadImageFromDisk(forKey: urlString) {
            // Store in memory cache for faster access
            UIImageView.imageCache.setObject(diskImage, forKey: cacheKey)
            DispatchQueue.main.async {
                self.image = diskImage
            }
            return
        }
        
        // 3. Check network connectivity
        if !NetworkManager.shared.isConnected {
            print("No network connection, cannot load image: \(urlString)")
            DispatchQueue.main.async {
                self.image = UIImage(systemName: "wifi.slash") // Show offline indicator
            }
            return
        }
        
        // 4. Download from network (slowest)
        print("Downloading image from network: \(urlString)")
        
        // Show loading indicator
        DispatchQueue.main.async {
            self.image = nil
        }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let data = data, error == nil else {
                print("Error loading image: \(error?.localizedDescription ?? "Unknown error")")
                DispatchQueue.main.async {
                    self?.image = UIImage(systemName: "exclamationmark.triangle") // Show error indicator
                }
                return
            }
            
            guard let image = UIImage(data: data) else { 
                print("Failed to create image from data")
                return 
            }
            
            // Cache the image in both memory and disk
            UIImageView.imageCache.setObject(image, forKey: cacheKey)
            ImageCacheManager.shared.saveImageToDisk(image, forKey: urlString)
            
            // Clean cache if needed
            ImageCacheManager.shared.cleanCacheIfNeeded()
            
            DispatchQueue.main.async {
                self?.image = image
            }
        }.resume()
    }
}

// MARK: - GalleryViewModelDelegate
extension GalleryViewController: GalleryViewModelDelegate {
    func didLoadImages() {
        DispatchQueue.main.async {
            self.galleryCollectionView.reloadData()
        }
    }
    
    func didSelectImage(at index: Int) {
        print("Selected item at index: \(index)")
    }
}
