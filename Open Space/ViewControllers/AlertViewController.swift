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
import DynamicBlurView
class AlertViewController: UIViewController {
    @IBOutlet var cancelButton: MDCButton!

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    @IBAction func dismissButtonTapped(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)

    }
}
