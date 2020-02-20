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
    @objc func shipsAction(_ sender: UIBarButtonItem) {
        
        
       }
       
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let shipButton = UIBarButtonItem(title: "wtf", style: .done, target: self, action: #selector(shipsAction(_:)))
              self.navigationItem.leftBarButtonItem = shipButton
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.cancelButton.applyTextTheme(withScheme: appDelegate.containerScheme)
        self.cancelButton.applyContainedTheme(withScheme: appDelegate.containerScheme)
        
    }
    @IBAction func dismissButtonTapped(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)

    }
}
