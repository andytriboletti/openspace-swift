//
//  ViewController.swift
//  MOE
//
//  Created by Andy Triboletti on 12/28/19.
//  Copyright © 2019 GreenRobot LLC. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class EntryViewController: UIViewController {

    override func viewDidAppear(_ animated: Bool) {
        // else go to logged in
        super.viewDidAppear(animated)
        // Do any additional setup after loading the view.

        if Auth.auth().currentUser != nil {
            // User is signed in.
            performSegue(withIdentifier: "goToLobby", sender: self)

        } else {
            // No user is signed in.
            performSegue(withIdentifier: "goToLogin", sender: self)

        }

    }

}
