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

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    @IBAction func createNewItem() {
        print("create new item")
        print(inputText.text!)
        //let extractedText = "Text extracted from image prompt"
        sendText(text: inputText.text)

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
