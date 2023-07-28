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
import Defaults

//import SceneDelegate
class SignInViewController: UIViewController, FUIAuthDelegate {
    public var authUI:FUIAuth = FUIAuth.defaultAuthUI()!
    var rootViewController:SignInViewController?
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let user = Auth.auth().currentUser {
            if let email = user.email {
                print("Logged-in user email: \(email)")
                dismiss(animated:false)
            }
        }
        else {
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
            authController.modalPresentationStyle = .fullScreen
            present(authController, animated: true, completion: nil)
        }

        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    func loginWithEmail(email: String, authToken: String, completion: @escaping (String?, Error?) -> Void) {
        let url = URL(string: "https://server.openspace.greenrobot.com/wp-json/openspace/v1/login")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let parameters: [String: Any] = [
            "email": email,
            "authToken": authToken
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: [])
        } catch {
            completion(nil, error)
            return
        }
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                completion(nil, error)
                return
            }
            
            guard let data = data else {
                let error = NSError(domain: "com.openspace.error", code: -1, userInfo: nil)
                completion(nil, error)
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    // Handle the server response
                    // Print the response or extract relevant data
                    print(json)
                    
                    if let success = json["success"] as? Bool, success {
                        if let lastLocation = json["data"] as? String {
                            completion(lastLocation, nil)
                            return
                        }
                    }
                }
            } catch let error {
                print("Error description: \(error.localizedDescription)")
                print("Actual error: \(error)")
                completion(nil, error)
            }
            
            let error = NSError(domain: "com.openspace.error", code: -1, userInfo: nil)
            completion(nil, error)
        }
        
        task.resume()
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
            
            // Call the method with a completion block
            currentUser.getIDTokenForcingRefresh(true) { (idToken, error) in
                if let idToken = idToken {
                    // The ID token is successfully obtained. You can use it here.
                    print("ID token: \(idToken)")
                    
                    
                    
                    let email = currentUser.email
                    let uid = currentUser.uid
                    //let authToken = currentUser.refreshToken!
                    print("Email: ")
                    print(email)
                    print("uid: ")
                    print(uid)
                    print("IdToken: ")
                    print(idToken)
                    Defaults[.email] = email!
                    Defaults[.authToken] = idToken
                    // Call the OpenspaceAPI to retrieve the last_location
                    OpenspaceAPI.shared.loginWithEmail(email: email!, authToken: idToken) { lastLocation, error in
                        if let error = error {
                            // Handle the error
                            print("Error: \(error.localizedDescription)")
                        } else if let lastLocation = lastLocation {
                            // Use the last_location
                            print("Last Location: \(lastLocation)")
                            
                            //save email and authToken in Defaults
                            Defaults[.email] = email!
                            Defaults[.authToken] = idToken

                            print("Successfully signed in with user: \(user!)")

                            let uid = currentUser.uid
                            //let email = currentUser.email
                            let displayName = currentUser.displayName
                            let photoURL = currentUser.photoURL
                            let phoneNumber = currentUser.phoneNumber
                            let isAnonymous = currentUser.isAnonymous
                            let providerData = currentUser.providerData
                            //let authToken = currentUser.refreshToken
                            
                            print("Successfully signed in end with user: \(user!)")
                            //dismiss(animated: false)
                            DispatchQueue.main.async {
                                // Perform UI-related updates here
                                // For example, updating UI elements like labels, buttons, etc.
                                // e.g., myLabel.text = "Updated text"
                                self.performSegue(withIdentifier: "goToSignedIn", sender: self)

                            }

                            
                            
                            
                            }
                    }
                    
                    
                } else if let error = error {
                    // Handle the error, if any occurred during the token retrieval.
                    print("Error occurred: \(error.localizedDescription)")
                } else {
                    // This block will be executed if both idToken and error are nil.
                    print("Both idToken and error are nil.")
                }
            }

            
            //currentUser.getIDToken()
            
            
            
            
            //self.reloadViewController()

        

            // Use the attributes as needed
        }
        else {
            print("Successfully signed in with a user, but user data is nil.")
        }
    }
    
    
}
