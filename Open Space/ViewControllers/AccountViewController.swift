//
//  AccountViewController.swift
//  Open Space
//
//  Created by Andrew Triboletti on 6/25/23.
//  Copyright © 2023 GreenRobot LLC. All rights reserved.
//

import UIKit
import FirebaseAuth
import Defaults

class AccountViewController: UIViewController {
    var rootViewController:SignInViewController?

    @IBOutlet weak var loggedInAs: UILabel!
    @IBOutlet weak var signOutButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!

    @IBAction func deleteButtonTapped(_ sender: UIButton) {
           let confirmationAlert = UIAlertController(title: "Delete Account", message: "Are you sure you want to delete your account?", preferredStyle: .alert)
           confirmationAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
           confirmationAlert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { [weak self] _ in
               do {
                   try Auth.auth().signOut()
               } catch let signOutError as NSError {
                   print("Error signing out: \(signOutError.localizedDescription)")
               }
               
               self?.deleteUser()

               self!.goToSignIn()
           }))
           
           // Present the confirmation alert
           self.present(confirmationAlert, animated: true, completion: nil)
       }
    
    func goToSignIn() {
        // Get the frame of the existing view controller's view
            let frame = self.view.frame
        
        // User is not signed in
        rootViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SignInViewController") as? SignInViewController
        
        // Set the frame of the new view controller's view to match the existing view controller's frame
        rootViewController!.view.frame = frame

        // Assuming you have a reference to your app's UIWindow object
        guard let window = UIApplication.shared.windows.first else {
            return
        }
        window.rootViewController = rootViewController
        window.makeKeyAndVisible()
    }
    @IBAction func signOutButtonTapped(_ sender: UIButton) {
        do {
            try Auth.auth().signOut()
            
            // Get the frame of the existing view controller's view
                let frame = self.view.frame
            
            // User is not signed in
            rootViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SignInViewController") as? SignInViewController
            
            // Set the frame of the new view controller's view to match the existing view controller's frame
            rootViewController!.view.frame = frame

            // Assuming you have a reference to your app's UIWindow object
            guard let window = UIApplication.shared.windows.first else {
                return
            }
            window.rootViewController = rootViewController
            window.makeKeyAndVisible()
            
            
            
            //todo go to sign in screen
            // Perform any additional actions or UI updates after sign out
        } catch let signOutError as NSError {
            print("Error signing out: \(signOutError.localizedDescription)")
        }
    }

    
    //Delete user
    ////////////////////
    func deleteUser() {
        let email = Defaults[.email] // Replace with the actual email
        let authToken = Defaults[.authToken] // Replace with the actual auth token

           OpenspaceAPI.shared.deleteUser(email: email, authToken: authToken) { [weak self] message, error in
               if let error = error {
                   // Handle the error
                   print("Error: \(error.localizedDescription)")
               } else if let message = message {
                   // User deleted successfully
                   print("Success: \(message)")
               }
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
