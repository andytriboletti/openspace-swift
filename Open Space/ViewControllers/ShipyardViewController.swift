//
//  ShipyardViewController.swift
//  Open Space
//
//  Created by Andy Triboletti on 3/27/21.
//  Copyright © 2021 GreenRobot LLC. All rights reserved.
//

import UIKit
import Defaults
class ShipyardViewController: UIViewController {

    @IBAction func configureShipName() {
        //print("configure ship name")
        // 1. Create the alert controller.
        let alert = UIAlertController(title: "Ship Name", message: "Enter your Ship's Name", preferredStyle: .alert)

        // 2. Add the text field. You can configure it however you need.
        alert.addTextField { (textField) in
            textField.text = "Ship Name"
        }

        // 3. Grab the value from the text field, and print it when the user clicks OK.
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
            let textField = alert?.textFields![0] // Force unwrapping because we know it exists.
            //print("Text field: \(String(describing: textField!.text))")
            Defaults[.shipName] = textField!.text!
        }))

        // 4. Present the alert.
        self.present(alert, animated: true, completion: nil)

    }

    @IBAction func configureShipDesign() {
        //print("configure ship design")
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
