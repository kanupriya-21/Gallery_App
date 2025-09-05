//
//  ProfileViewController.swift
//  GalleryApp
//
//  Created by Kanupriya Rajpal on 06/09/25.
//

import UIKit
import FirebaseAuth

class ProfileViewController: UIViewController {

    @IBOutlet weak var userName: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupUserInfo()
    }
    
    private func setupUserInfo() {
        // Display the logged-in user's email
        if let user = Auth.auth().currentUser {
            userName.text = user.displayName ?? "No name found"
        } else {
            userName.text = "Not logged in"
        }
    }
    

    @IBAction func logoutButtonPressed(_ sender: UIButton) {
        // Show confirmation alert
        let alert = UIAlertController(title: "Logout", message: "Are you sure you want to logout?", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Logout", style: .destructive) { [weak self] _ in
            self?.performLogout()
        })
        
        present(alert, animated: true)
    }
    
    private func performLogout() {
        do {
            try Auth.auth().signOut()
            print("User logged out successfully")
            
            // Navigate back to login screen
            if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
                sceneDelegate.showLoginViewControllerPublic()
            }
        } catch {
            print("Error signing out: \(error.localizedDescription)")
            
            // Show error alert
            let alert = UIAlertController(title: "Error", message: "Failed to logout. Please try again.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
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
