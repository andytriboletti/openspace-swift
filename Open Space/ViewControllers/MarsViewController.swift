//
//  MarsViewController.swift
//  Open Space
//
//  Created by Andy Triboletti on 2/20/20.
//  Copyright © 2020 GreenRobot LLC. All rights reserved.
//

import UIKit
import MaterialComponents.MaterialButtons
import MaterialComponents.MaterialButtons_Theming

class MarsViewController: UIViewController {
    @IBOutlet var takeOffButton: MDCButton!

    @IBAction func takeOffAction() {
        self.performSegue(withIdentifier: "takeOff", sender: self)
    }
    @objc func shipsAction(_ sender: UIBarButtonItem) {
        
        self.performSegue(withIdentifier: "selectShip", sender: sender)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.takeOffButton.applyTextTheme(withScheme: appDelegate.containerScheme)
        self.takeOffButton.applyContainedTheme(withScheme: appDelegate.containerScheme)
        
        
        let shipButton = UIBarButtonItem(title: "Ships", style: .done, target: self, action: #selector(shipsAction(_:)))
        self.navigationItem.leftBarButtonItem = shipButton
        
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
