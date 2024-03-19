//
//  ReplicatorViewController.swift
//  Open Space
//
//  Created by Andrew Triboletti on 3/11/24.
//  Copyright © 2024 GreenRobot LLC. All rights reserved.
//

import Foundation


//
//  YourSphereViewController.swift
//  Open Space
//
//  Created by Andrew Triboletti on 7/6/23.
//  Copyright © 2023 GreenRobot LLC. All rights reserved.
//

import UIKit
import Defaults

class ReplicatorViewController: UIViewController {
    @IBOutlet var inputText: UITextView!

    override func viewDidLoad() {
        super.viewDidLoad()

        let textView = UITextView()
        let containerView = UIView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(textView)

        textView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor).isActive = true
        textView.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        textView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor).isActive = true
        textView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor).isActive = true

        textView.heightAnchor.constraint(equalToConstant: 100).isActive = true
        let stackView = UIStackView(arrangedSubviews: [containerView])
        
        // Do any additional setup after loading the view.
    }
    func showAlert(message: String) {
        let alert = UIAlertController(title: "Invalid Input", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func createNewItem() {
        print("create new item")
        guard let text = inputText.text else { return }

        let allowedCharacterSet = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789,. ")
        if text.rangeOfCharacter(from: allowedCharacterSet.inverted) != nil || text.contains(":") {
            // Text contains characters other than letters, numbers, comma, period, space, or contains ":"
            showAlert(message: "Only letters, numbers, commas, periods, and spaces are accepted.")
        } else if text.count < 3 {
            // Text is less than 3 characters long, show an alert
            showAlert(message: "Text must be at least 3 characters long.")
        } else {
            // Text is valid, proceed
            sendText(text: text)
        }
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
