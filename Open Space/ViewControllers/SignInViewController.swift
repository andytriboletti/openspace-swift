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
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
     
        
        
      
        
    }
    
}
