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

class ReplicatorViewController: BackgroundImageViewController {
    @IBOutlet var inputText: UITextView!
    @IBOutlet var labelForSphere: UILabel!
    @IBOutlet var doYouHaveEnoughMinerals: UILabel!
    @IBOutlet var createNewItemButton: UIButton!
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

        let sphereName = Defaults[.selectedSphereName]
        labelForSphere.text = "This creation will be shown in your sphere \(sphereName)"
        // Do any additional setup after loading the view.

        updateMineralStatus()

    }
    func updateMineralStatus() {
          // Retrieve the stored mineral amounts
          let regolith = Defaults[.regolithCargoAmount]
          let waterIce = Defaults[.waterIceCargoAmount]
          let helium3 = Defaults[.helium3CargoAmount]
          let silicate = Defaults[.silicateCargoAmount]
          let jarosite = Defaults[.jarositeCargoAmount]
          let hematite = Defaults[.hematiteCargoAmount]
          let goethite = Defaults[.goethiteCargoAmount]
          let opal = Defaults[.opalCargoAmount]

          // Required amount of each mineral
          let requiredAmount = 10

          // Check if all minerals meet the required amount
          if regolith >= requiredAmount && waterIce >= requiredAmount && helium3 >= requiredAmount &&
             silicate >= requiredAmount && jarosite >= requiredAmount && hematite >= requiredAmount &&
             goethite >= requiredAmount && opal >= requiredAmount {
              // Success case
              doYouHaveEnoughMinerals.text = "You have all the needed minerals to create this object."
              doYouHaveEnoughMinerals.textColor = UIColor.green
              createNewItemButton.isEnabled = true
          } else {
              // Build the missing minerals message
              var missingMineralsMessage = "You need:"
              if regolith < requiredAmount {
                  missingMineralsMessage += " \(requiredAmount - regolith) kg of Regolith,"
              }
              if waterIce < requiredAmount {
                  missingMineralsMessage += " \(requiredAmount - waterIce) kg of Water Ice,"
              }
              if helium3 < requiredAmount {
                  missingMineralsMessage += " \(requiredAmount - helium3) kg of Helium-3,"
              }
              if silicate < requiredAmount {
                  missingMineralsMessage += " \(requiredAmount - silicate) kg of Silicate,"
              }
              if jarosite < requiredAmount {
                  missingMineralsMessage += " \(requiredAmount - jarosite) kg of Jarosite,"
              }
              if hematite < requiredAmount {
                  missingMineralsMessage += " \(requiredAmount - hematite) kg of Hematite,"
              }
              if goethite < requiredAmount {
                  missingMineralsMessage += " \(requiredAmount - goethite) kg of Goethite,"
              }
              if opal < requiredAmount {
                  missingMineralsMessage += " \(requiredAmount - opal) kg of Opal,"
              }

              // Remove the last comma
              if missingMineralsMessage.last == "," {
                  missingMineralsMessage.removeLast()
              }

              missingMineralsMessage += "\nYou can find minerals on the Moon and Mars, or buy a mineral pack from the Account tab."

              // Update the label
              doYouHaveEnoughMinerals.text = missingMineralsMessage
              doYouHaveEnoughMinerals.textColor = UIColor.red
              createNewItemButton.isEnabled = false
          }

          // Add black background around the text
          doYouHaveEnoughMinerals.backgroundColor = UIColor.black
          doYouHaveEnoughMinerals.layer.masksToBounds = true
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
        let okAction = UIAlertAction(title: "OK", style: .default) { _ in
            // Dismiss the current view controller
            self.dismiss(animated: true, completion: nil)
        }
        alertController.addAction(okAction)

        // Present the alert controller
        self.present(alertController, animated: true, completion: nil)
    }


    func sendText(text: String) {
        let email = Defaults[.email] // Replace with the actual email
        let authToken = Defaults[.authToken] // Replace with the actual auth token
        let yourSphereId = Defaults[.selectedSphereId]
        //print(email)
        //print(authToken)
        //print(text)
        //print(yourSphereId)

        OpenspaceAPI.shared.sendTextToServer(email: email, authToken: authToken, text: text, sphereId: yourSphereId) { result in
            switch result {
            case .success(let success):
                if success {
                    print("Text sent successfully to server")
                    // Handle success
                    DispatchQueue.main.async {
                        self.inputText.text = ""
                        self.showSuccessAlert()
                    }
                } else {
                    print("Failed to send text to server")
                    // Handle failure
                }
            case .failure(let error):
                print("Error: \(error.localizedDescription)")
                // Handle error
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
