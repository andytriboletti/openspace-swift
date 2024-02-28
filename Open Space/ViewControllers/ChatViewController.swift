//
//  ChatViewController.swift
//  Open Space
//
//  Created by Andrew Triboletti on 2/28/24.
//  Copyright © 2024 GreenRobot LLC. All rights reserved.
//

import UIKit
import SwiftUI

class ChatViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        let chatView = ChatView()
        let hostingController = UIHostingController(rootView: chatView)

        addChild(hostingController)
        view.addSubview(hostingController.view)
        hostingController.didMove(toParent: self)

        // Set constraints if needed
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: view.topAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}

