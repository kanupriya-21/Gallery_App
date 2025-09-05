//
//  LoginViewController.swift
//  GalleryApp
//
//  Created by Kanupriya Rajpal on 05/09/25.
//

import UIKit
import FirebaseAuth
import GoogleSignIn
import FirebaseCore

class LoginViewController: UIViewController {
    
    
    @IBOutlet weak var signInButton: UIButton!
    
    private var loadingView: UIView?
    private var activityIndicator: UIActivityIndicatorView?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupLoadingView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Ensure loading view is hidden when view appears
        hideLoading()
    }
    
    private func setupLoadingView() {
        // Create loading view
        loadingView = UIView()
        loadingView?.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        loadingView?.translatesAutoresizingMaskIntoConstraints = false
        
        // Create activity indicator
        activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator?.color = .white
        activityIndicator?.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator?.hidesWhenStopped = true
        
        // Create loading label
        let loadingLabel = UILabel()
        loadingLabel.text = "Signing in..."
        loadingLabel.textColor = .white
        loadingLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        loadingLabel.textAlignment = .center
        loadingLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Add subviews
        if let loadingView = loadingView, let activityIndicator = activityIndicator {
            view.addSubview(loadingView)
            loadingView.addSubview(activityIndicator)
            loadingView.addSubview(loadingLabel)
            
            // Setup constraints
            NSLayoutConstraint.activate([
                // Loading view constraints
                loadingView.topAnchor.constraint(equalTo: view.topAnchor),
                loadingView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                loadingView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                loadingView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                
                // Activity indicator constraints
                activityIndicator.centerXAnchor.constraint(equalTo: loadingView.centerXAnchor),
                activityIndicator.centerYAnchor.constraint(equalTo: loadingView.centerYAnchor, constant: -20),
                
                // Loading label constraints
                loadingLabel.centerXAnchor.constraint(equalTo: loadingView.centerXAnchor),
                loadingLabel.topAnchor.constraint(equalTo: activityIndicator.bottomAnchor, constant: 20)
            ])
            
            // Hide loading view by default
            loadingView.isHidden = true
        }
    }
    
    private func showLoading() {
        DispatchQueue.main.async { [weak self] in
            self?.loadingView?.isHidden = false
            self?.activityIndicator?.startAnimating()
            self?.signInButton.isEnabled = false
            self?.signInButton.alpha = 0.6
        }
    }
    
    private func hideLoading() {
        DispatchQueue.main.async { [weak self] in
            self?.loadingView?.isHidden = true
            self?.activityIndicator?.stopAnimating()
            self?.signInButton.isEnabled = true
            self?.signInButton.alpha = 1.0
        }
    }
    
    
    @IBAction func signInPressed(_ sender: UIButton) {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        
        // Show loading indicator
        showLoading()
        
        // Create Google Sign In configuration object
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        // Start the sign in flow
        GIDSignIn.sharedInstance.signIn(withPresenting: self) { [weak self] result, error in
            if let error = error {
                print("Google Sign-In error: \(error.localizedDescription)")
                self?.hideLoading()
                return
            }
            
            guard let user = result?.user,
                  let idToken = user.idToken?.tokenString else {
                print("Failed to get user or idToken")
                self?.hideLoading()
                return
            }
            
            let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                         accessToken: user.accessToken.tokenString)
            
            // Sign in with Firebase
            Auth.auth().signIn(with: credential) { authResult, error in
                if let error = error {
                    print("Firebase sign-in error: \(error.localizedDescription)")
                    self?.hideLoading()
                    return
                }
                
                // User is signed in
                print("User signed in successfully: \(authResult?.user.email ?? "No email")")
                
                // User is signed in successfully
                print("Sign-in completed successfully!")
                
                // Navigate to gallery view controller with a small delay for smooth transition
//                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
//                    self?.navigateToGallery()
//                }
            }
        }
    }
    
    private func navigateToGallery() {
        // Get the scene delegate and navigate to gallery
        if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
            sceneDelegate.showGalleryViewController()
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
