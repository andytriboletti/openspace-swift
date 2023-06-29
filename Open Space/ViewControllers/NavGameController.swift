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
    var rootViewController:SignInViewController?
    var screenSetup = false

    override func viewDidAppear(_ animated: Bool) {
        // Create your new root view controller
        // let newRootViewController = TabViewController()
        if(screenSetup == false) {
            screenSetup = true
            
            if let currentUser = Auth.auth().currentUser {
                let viewController:UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TabViewController") as UIViewController
                // .instantiatViewControllerWithIdentifier() returns AnyObject! this must be downcast to utilize it
                self.setViewControllers([viewController], animated: true)
            }
            else {
                
                // Get the frame of the existing view controller's view
                let frame = self.view.frame
                // Get the size of the existing view controller's view
                let size = self.view.bounds.size
                
                // User is not signed in
                rootViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SignInViewController") as? SignInViewController
                
                // Set the frame of the new view controller's view to match the existing view controller's frame
                rootViewController!.view.frame = frame
                rootViewController!.preferredContentSize = size
                // Assuming you have a reference to your app's UIWindow object
                guard let window = UIApplication.shared.windows.first else {
                    return
                }
                //window.rootViewController = rootViewController
                //window.makeKeyAndVisible()
                
                //let authController = rootViewController!.authUI.authViewController()
                //authController.view.frame = frame
                //authController.preferredContentSize = size
                
                screenSetup = false

                //rootViewController!.present(authController, animated: true, completion: nil)
                window.rootViewController = rootViewController
                window.makeKeyAndVisible()
                
                
                
            }
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

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
