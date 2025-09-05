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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupViewModel()
        setupCollectionView()
        viewModel.loadImages()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        DispatchQueue.main.async {
            self.galleryCollectionView.setNeedsLayout()
            self.galleryCollectionView.layoutIfNeeded()
        }
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
        
        // Check load more images (pagination)
        if viewModel.shouldLoadMore(for: indexPath.item) {
            viewModel.loadMoreImages()
        }
        
        // Get image URL from ViewModel
        if let imageURL = viewModel.getImageURL(at: indexPath.item) {
            cell.configure(with: imageURL)
        } else {
            // Handle case where no image URL is available
            print("No image URL found for index: \(indexPath.item)")
            // set a placeholder image or clear the cell
            cell.galleryImageView.image = nil
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

// MARK: - Image Loading Extension with Caching
extension UIImageView {
    private static var imageCache = NSCache<NSString, UIImage>()
    
    func loadImage(from urlString: String) {
        guard let url = URL(string: urlString) else { return }
        
        // Check cache first
        let cacheKey = NSString(string: urlString)
        if let cachedImage = UIImageView.imageCache.object(forKey: cacheKey) {
            DispatchQueue.main.async {
                self.image = cachedImage
            }
            return
        }
        
        // Show loading indicator
        DispatchQueue.main.async {
            self.image = nil
        }
        
        // Load image asynchronously
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let data = data, error == nil else {
                print("Error loading image: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            guard let image = UIImage(data: data) else { return }
            
            // Cache the image
            UIImageView.imageCache.setObject(image, forKey: cacheKey)
            
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
