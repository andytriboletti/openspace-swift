//
//  LunarLoungeViewController.swift
//  Open Space
//
//  Created by Andrew Triboletti on 9/21/24.
//  Copyright © 2024 GreenRobot LLC. All rights reserved.
//
import UIKit
import SwiftUI

class LunarLoungeViewController: UIViewController {

    override func loadView() {
        super.loadView()

        // Set up the view
        view = UIView()
        setupGradientBackground()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Set up a navigation bar with a Close button
        setupNavBar()

        // Set up AlienTavernManager and CommentsView
        setupAlienTavernAndCommentsView()
    }

    // Set up the gradient background
    func setupGradientBackground() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = view.bounds
        gradientLayer.colors = [UIColor.systemBlue.cgColor, UIColor.systemPurple.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        view.layer.insertSublayer(gradientLayer, at: 0)
    }

    func setupAlienTavernAndCommentsView() {
           print("LunarLoungeViewController: Setting up AlienTavern")

           // Configure AlienTavernManager with ATConfig
            let config = ATConfig(boardDisplayName: "Lunar Lounge", board_id: "testboard123", app_id: "1499913239")

           AlienTavernManager.shared.configure(with: config)

           AlienTavernManager.shared.setup { [weak self] success, errorMessage in
               guard let self = self else { return }

               DispatchQueue.main.async {
                   if success {
                       print("LunarLoungeViewController: AlienTavern setup successful")
                       self.setupCommentsView()
                   } else {
                       print("LunarLoungeViewController: AlienTavern setup failed")
                       if let errorMessage = errorMessage {
                           print("Error: \(errorMessage)")
                       }
                       self.showAuthenticationFailureAlert()
                   }
               }
           }
       }


    func setupCommentsView() {
        // Create an instance of ATConfig
        let config = ATConfig(
            boardDisplayName: "Lunar Lounge",
            board_id: "testboard123",
            app_id: "1499913239"
        )

        // Embed SwiftUI CommentsView into the UIKit view using ATConfig
        let commentsView = UIHostingController(
            rootView: CommentsView(
                boardDisplayName: config.boardDisplayName,
                boardID: config.board_id
            )
        )

        addChild(commentsView)
        view.addSubview(commentsView.view)
        commentsView.didMove(toParent: self)

        // Set up constraints so the comments take up most of the screen
        commentsView.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            commentsView.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            commentsView.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            commentsView.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            commentsView.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    // Set up navigation bar with a Close button
    func setupNavBar() {
        // Set up a Close button to dismiss the view
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "Close",
            style: .plain,
            target: self,
            action: #selector(closePage)
        )

        // Optional: set up a refresh button if you want users to manually refresh comments
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .refresh,
            target: self,
            action: #selector(refreshComments)
        )
    }

    // Action to close the comments page
    @objc func closePage() {
        dismiss(animated: true, completion: nil)
    }

    // Action to refresh comments
    @objc func refreshComments() {
        // Refreshing the comments - currently handled automatically within the SwiftUI view
        print("Refresh button tapped, refreshing comments.")
    }

    func showAuthenticationFailureAlert() {
        let alert = UIAlertController(title: "Authentication Failed", message: "Failed to connect to AlienTavern. Please try again later.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}

//// Updated ATConfig struct
//struct ATConfig {
//    let boardDisplayName: String
//    let board_id: String
//}
