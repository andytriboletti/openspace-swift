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
import Defaults

class NavGameController: UINavigationController, FUIAuthDelegate {
    var rootViewController: SignInViewController?
    var screenSetup = false

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // Check if appToken is empty and show SignInViewController if needed
        if Defaults[.appToken].isEmpty {
            do {
                try Auth.auth().signOut()

                // Clear all stored values
                Defaults.removeAll()

            } catch let signOutError as NSError {
                print("Error signing out to get app token: \(signOutError.localizedDescription)")
            }
            presentSignInViewController()
            return
        }

        if screenSetup == false {
            screenSetup = true

            if let currentUser = Auth.auth().currentUser {
                let viewController: UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TabViewController") as UIViewController
                self.setViewControllers([viewController], animated: true)
            } else {
                presentSignInViewController()
            }
        }
    }

    private func presentSignInViewController() {
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

        screenSetup = false

        window.rootViewController = rootViewController
        window.makeKeyAndVisible()
    }
}
