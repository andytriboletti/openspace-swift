//
//  NavGameController.swift
//  Open Space
//
//  Created by Andy Triboletti on 3/4/20.
//  Copyright © 2020 GreenRobot LLC. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseOAuthUI

class NavGameController: UINavigationController, FUIAuthDelegate {
    
    func authUI(_ authUI: FUIAuth, didSignInWith user: User?, error: Error?) {
      // handle user and error as necessary
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
            
            let viewController:UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TabViewController") as UIViewController
            // .instantiatViewControllerWithIdentifier() returns AnyObject! this must be downcast to utilize it
            self.setViewControllers([viewController], animated: true)
            // Assign the root view controller to the window
            // Assuming you have a reference to your app's UIWindow object
            guard let window = UIApplication.shared.windows.first else {
                return
            }
            window.rootViewController = viewController

            // Make the window key and visible
            window.makeKeyAndVisible()
            

            // Use the attributes as needed
        }
        else {
            print("Successfully signed in with a user, but user data is nil.")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Create your new root view controller
           // let newRootViewController = TabViewController()
        let signedIn = true
        if let currentUser = Auth.auth().currentUser {
            let viewController:UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TabViewController") as UIViewController
            // .instantiatViewControllerWithIdentifier() returns AnyObject! this must be downcast to utilize it
            self.setViewControllers([viewController], animated: true)
        }
        else {
        
            
            // User is not signed in
                        // Perform any necessary actions for a non-signed-in user
                        // ...
                        
                        //sign in
                        //let rootViewController = SignInViewController()

            let rootViewController:SignInViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SignInViewController") as! SignInViewController
            
                        // Assuming you have a reference to your app's UIWindow object
                        guard let window = UIApplication.shared.windows.first else {
                            return
                        }

            
                        // Create an instance of your desired root view controller
                        //let rootViewController = YourRootViewController()

//                        // Assign the root view controller to the window
                        window.rootViewController = rootViewController
//
//                        // Make the window key and visible
                        window.makeKeyAndVisible()

                        // Present the AuthViewController from the rootViewController
                        //let authViewController = AuthViewController()
                        //rootViewController.present(rootViewController.authUI.authViewController(), animated: true, completion: nil)
                    //present(rootViewController.authUI.authViewController(), animated: true, completion: nil)
                      //  self.setViewControllers([rootViewController.authUI.authViewController()], animated: true)

                        
                        let authController = rootViewController.authUI.authViewController()
            
                        rootViewController.present(authController, animated: true, completion: nil)

                        //regular
                        // Create an instance of your desired root view controller
                        //let rootViewController = TabViewController()

                        // Assign the root view controller to the window
                        window.rootViewController = rootViewController

                        // Make the window key and visible
                        window.makeKeyAndVisible()
            
            
            
        }
        
        //self.present(viewController, animated: false, completion: nil)
        
        // Do any additional setup after loading the view.
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
