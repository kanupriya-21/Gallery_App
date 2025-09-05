//
//  GalleryCollectionViewCell.swift
//  GalleryApp
//
//  Created by Kanupriya Rajpal on 06/09/25.
//

import UIKit

class GalleryCollectionViewCell: UICollectionViewCell {

    
    @IBOutlet weak var galleryImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        setupImageView()
    }
    
    private func setupImageView() {
        // Configure image view appearance
        galleryImageView.contentMode = .scaleAspectFill
        galleryImageView.clipsToBounds = true
        galleryImageView.layer.cornerRadius = 8
        galleryImageView.backgroundColor = .systemGray5
    }
    
    func configure(with imageURL: String) {
        // Load image from URL
        galleryImageView.loadImage(from: imageURL)
    }

}
