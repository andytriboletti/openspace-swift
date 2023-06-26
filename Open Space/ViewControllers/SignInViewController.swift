//
//  SignInViewController.swift
//  Open Space
//
//  Created by Andrew Triboletti on 6/5/23.
//  Copyright © 2023 GreenRobot LLC. All rights reserved.
//

import UIKit
import FirebaseAuthUI
import FirebaseCore
import FirebaseOAuthUI
//import SceneDelegate
class SignInViewController: UIViewController, FUIAuthDelegate {
    public var authUI:FUIAuth = FUIAuth.defaultAuthUI()!
    var rootViewController:SignInViewController?
    
    override func viewDidAppear(_ animated: Bool) {
        if let user = Auth.auth().currentUser {
            if let email = user.email {
                print("Logged-in user email: \(email)")
                dismiss(animated:false)
            }
        }
        let authUI = FUIAuth.defaultAuthUI()
        // You need to adopt a FUIAuthDelegate protocol to receive callback
        authUI!.delegate = self
        // Do any additional setup after loading the view.
        
        let providers: [FUIAuthProvider] = [
            FUIOAuth.appleAuthProvider(),
        ]
        authUI!.providers = providers
        
        //self.authUI.providers = providers
        let authViewController = authUI!.authViewController()
        //present(authViewController, animated: true, completion: nil)
        //navigationController!.pushViewController(authViewController, animated: true)
        //self.present(authViewController, animated: true)
        //let signInViewController = SignInViewController()
        authViewController.modalPresentationStyle = .fullScreen
        authViewController.modalTransitionStyle = .crossDissolve
       // self.window.rootViewController = signInViewController
        //present(authViewController, animated: true, completion: nil)
     
        let frame = self.view.frame
        let authController = authUI!.authViewController()
        authController.view.frame = frame
        authController.preferredContentSize = frame.size
        
        present(authController, animated: true, completion: nil)
        
        super.viewDidAppear(animated)

        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    func authUI(_ authUI: FUIAuth, didSignInWith user: User?, error: Error?) {
      // handle user and error as necessary
        //rootViewController!.dismiss(animated: false)
        
        if let error = error {
                    // Handle sign-in error
                    print("Sign-in error: \(error.localizedDescription)")
                    return
                }
        
        if let currentUser = user {
            print("Successfully signed in with user: \(user!)")

            let uid = currentUser.uid
            let email = currentUser.email
            let displayName = currentUser.displayName
            let photoURL = currentUser.photoURL
            let phoneNumber = currentUser.phoneNumber
            let isAnonymous = currentUser.isAnonymous
            let providerData = currentUser.providerData
            print("Successfully signed in end with user: \(user!)")
            //dismiss(animated: false)
            self.performSegue(withIdentifier: "goToSignedIn", sender: self)
            
            
            //self.reloadViewController()

            

            // Use the attributes as needed
        }
        else {
            print("Successfully signed in with a user, but user data is nil.")
        }
    }
    
    
}
