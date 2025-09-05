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

        // Do any additional setup after loading the view.
        setupViewModel()
        setupCollectionView()
        viewModel.loadImages()
    }
    
    private func setupViewModel() {
        viewModel.delegate = self
    }
    
    private func setupCollectionView() {
        // Set delegate and data source
        galleryCollectionView.delegate = self
        galleryCollectionView.dataSource = self
        
        // Register your custom cell (you'll create the XIB)
        galleryCollectionView.register(UINib(nibName: "GalleryCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "GalleryCollectionViewCell")
        
        // Setup collection view layout
        if let layout = galleryCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.minimumInteritemSpacing = 10
            layout.minimumLineSpacing = 10
            layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        }
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
        
        // Get the image URL from ViewModel
        if let imageURL = viewModel.getImageURL(at: indexPath.item) {
            cell.configure(with: imageURL)
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
        // Calculate cell size for 2 columns
        let spacing: CGFloat = 10
        let totalSpacing = spacing * 3 // left + right + middle spacing
        let availableWidth = collectionView.frame.width - totalSpacing
        let cellWidth = availableWidth / 2
        
        // Make it square or adjust height as needed
        let cellHeight = cellWidth
        
        return CGSize(width: cellWidth, height: cellHeight)
    }
}

// MARK: - Image Loading Extension
extension UIImageView {
    func loadImage(from urlString: String) {
        guard let url = URL(string: urlString) else { return }
        
        // Show loading indicator
        self.image = nil
        
        // Load image asynchronously
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let data = data, error == nil else {
                print("Error loading image: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            DispatchQueue.main.async {
                self?.image = UIImage(data: data)
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
        // You can add navigation to detail view here
        // let detailVC = DetailViewController()
        // navigationController?.pushViewController(detailVC, animated: true)
    }
}
