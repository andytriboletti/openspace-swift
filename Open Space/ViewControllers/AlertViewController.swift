//
//  AlertViewController.swift
//  Open Space
//
//  Created by Andy Triboletti on 2/20/20.
//  Copyright © 2020 GreenRobot LLC. All rights reserved.
//

import UIKit
import MaterialComponents.MaterialButtons
import MaterialComponents.MaterialButtons_Theming

class AlertViewController: UIViewController {
    @IBOutlet var cancelButton: MDCButton!

    override func viewWillAppear(_ animated: Bool) {
        self.cancelButton.applyTextTheme(withScheme: appDelegate.containerScheme)
        self.cancelButton.applyContainedTheme(withScheme: appDelegate.containerScheme)
        
    }
    @IBAction func dismissButtonTapped(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
}
