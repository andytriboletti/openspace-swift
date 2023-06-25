//
//  AccountViewController.swift
//  Open Space
//
//  Created by Andrew Triboletti on 6/25/23.
//  Copyright © 2023 GreenRobot LLC. All rights reserved.
//

import UIKit
import FirebaseAuth

class AccountViewController: UIViewController {

    @IBOutlet weak var loggedInAs: UILabel!
    @IBOutlet weak var signOutButton: UIButton!
    
    @IBAction func signOutButtonTapped(_ sender: UIButton) {
        do {
            try Auth.auth().signOut()
            
            //todo go to sign in screen
            // Perform any additional actions or UI updates after sign out
        } catch let signOutError as NSError {
            print("Error signing out: \(signOutError.localizedDescription)")
        }
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let user = Auth.auth().currentUser {
            if let email = user.email {
                print("Logged-in user email: \(email)")
                loggedInAs.text = "Logged In As: \(email)"
            }
        }

        
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
