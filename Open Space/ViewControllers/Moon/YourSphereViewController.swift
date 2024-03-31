//
//  YourSphereViewController.swift
//  Open Space
//
//  Created by Andrew Triboletti on 7/6/23.
//  Copyright © 2023 GreenRobot LLC. All rights reserved.
//

import UIKit
import Defaults

class YourSphereViewController: UIViewController {
    @IBOutlet var inputText: UITextView!
    @IBOutlet var headerLabel: UILabel!

    override func viewDidLoad() {
        let selectedSphereName = Defaults[.selectedSphereName]
        self.headerLabel.text = "Viewing your sphere: \(selectedSphereName)"

    }
    func showSuccessAlert() {
        let alertController = UIAlertController(title: "Text Submitted", message: "Your text has been submitted and is in the waiting line to be generated.", preferredStyle: .alert)

        // Add an action (button)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))

        // Present the alert controller
        self.present(alertController, animated: true, completion: nil)
    }
    // Example function to call the sendTextToServer function
    func sendText(text: String) {
            let email = Defaults[.email] // Replace with the actual email
            let authToken = Defaults[.authToken] // Replace with the actual auth token

           OpenspaceAPI.shared.sendTextToServer(email: email, authToken: authToken, text: text) { success, error in
               if let error = error {
                   print("Error: \(error)")
                   // Handle error
               } else if success {
                   print("Text sent successfully to server")
                   // Handle success
                   DispatchQueue.main.async {
                       self.inputText.text=""
                       self.showSuccessAlert()
                   }

               } else {
                   print("Failed to send text to server")
                   // Handle failure
               }
           }
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
