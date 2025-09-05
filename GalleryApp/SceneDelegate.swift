//
//  SceneDelegate.swift
//  GalleryApp
//
//  Created by Kanupriya Rajpal on 04/09/25.
//

import UIKit
import FirebaseAuth

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        // Set up the window
        window = UIWindow(windowScene: windowScene)
        
        // Check authentication state and set initial view controller
        if Auth.auth().currentUser != nil {
            // User is logged in, show gallery
            showGalleryViewController()
        } else {
            // User is not logged in, show login
            showLoginViewController()
        }
        
        window?.makeKeyAndVisible()
    }
    
    private func showLoginViewController() {
        let storyboard = UIStoryboard(name: "loginScreen", bundle: nil)
        if let loginVC = storyboard.instantiateViewController(withIdentifier: "LoginViewController") as? LoginViewController {
            window?.rootViewController = loginVC
        }
    }
    
    func showLoginViewControllerPublic() {
        showLoginViewController()
    }
    
    func showGalleryViewController() {
        // Navigate to the actual GalleryViewController from storyboard
        let storyboard = UIStoryboard(name: "GalleryScreen", bundle: nil)
        if let galleryVC = storyboard.instantiateViewController(withIdentifier: "GalleryViewController") as? GalleryViewController {
            // Add smooth transition animation
            UIView.transition(with: window!, duration: 0.3, options: .transitionCrossDissolve, animations: {
                self.window?.rootViewController = galleryVC
            }, completion: nil)
        }
    }
    
    /*
    // COMMENTED OUT - Using actual GalleryViewController from storyboard instead
    private func createGalleryViewController() -> UIViewController {
        let viewController = UIViewController()
        viewController.view.backgroundColor = .systemBackground
        viewController.title = "Gallery"
        
        // Create a simple UI
        let welcomeLabel = UILabel()
        welcomeLabel.text = "Welcome to Gallery!"
        welcomeLabel.textAlignment = .center
        welcomeLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        welcomeLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let userLabel = UILabel()
        if let user = Auth.auth().currentUser {
            userLabel.text = "Logged in as: \(user.email ?? "Unknown")"
        } else {
            userLabel.text = "Not logged in"
        }
        userLabel.textAlignment = .center
        userLabel.font = UIFont.systemFont(ofSize: 16)
        userLabel.textColor = .systemGray
        userLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let signOutButton = UIButton(type: .system)
        signOutButton.setTitle("Sign Out", for: .normal)
        signOutButton.backgroundColor = .systemRed
        signOutButton.setTitleColor(.white, for: .normal)
        signOutButton.layer.cornerRadius = 8
        signOutButton.translatesAutoresizingMaskIntoConstraints = false
        signOutButton.addTarget(self, action: #selector(signOutTapped), for: .touchUpInside)
        
        viewController.view.addSubview(welcomeLabel)
        viewController.view.addSubview(userLabel)
        viewController.view.addSubview(signOutButton)
        
        NSLayoutConstraint.activate([
            welcomeLabel.centerXAnchor.constraint(equalTo: viewController.view.centerXAnchor),
            welcomeLabel.centerYAnchor.constraint(equalTo: viewController.view.centerYAnchor, constant: -50),
            
            userLabel.centerXAnchor.constraint(equalTo: viewController.view.centerXAnchor),
            userLabel.topAnchor.constraint(equalTo: welcomeLabel.bottomAnchor, constant: 20),
            
            signOutButton.centerXAnchor.constraint(equalTo: viewController.view.centerXAnchor),
            signOutButton.topAnchor.constraint(equalTo: userLabel.bottomAnchor, constant: 40),
            signOutButton.widthAnchor.constraint(equalToConstant: 120),
            signOutButton.heightAnchor.constraint(equalToConstant: 44)
        ])
        
        return viewController
    }
    
    @objc private func signOutTapped() {
        do {
            try Auth.auth().signOut()
            // Show login screen with smooth transition
            UIView.transition(with: window!, duration: 0.3, options: .transitionCrossDissolve, animations: {
                self.showLoginViewController()
            }, completion: nil)
        } catch {
            print("Error signing out: \(error.localizedDescription)")
        }
    }
    */

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.

        // Save changes in the application's managed object context when the application transitions to the background.
        (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
    }


}

