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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
