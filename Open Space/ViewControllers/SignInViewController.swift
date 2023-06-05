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

class SignInViewController: UIViewController, FUIAuthDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()

        FirebaseApp.configure()
        let authUI = FUIAuth.defaultAuthUI()
        // You need to adopt a FUIAuthDelegate protocol to receive callback
        authUI!.delegate = self
        // Do any additional setup after loading the view.
    }
    
}
