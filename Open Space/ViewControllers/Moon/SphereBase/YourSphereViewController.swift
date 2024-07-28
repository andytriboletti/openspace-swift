//
//  YourSphereViewController.swift
//  Open Space
//
//  Created by Andrew Triboletti on 7/6/23.
//  Copyright © 2023 GreenRobot LLC. All rights reserved.
//

import UIKit
import Defaults

class YourSphereViewController: BackgroundImageViewController {
    @IBOutlet var inputText: UITextView!
    @IBOutlet var headerLabel: UILabel!
    @IBOutlet var numberOfObjectsInSphere: UILabel!
    // @IBOutlet var createNewButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        let selectedSphereName = Defaults[.selectedSphereName]
        self.headerLabel.text = "   Viewing your sphere: \(selectedSphereName)   "

        // todo get sphere items
    }
    var count = 0
    override func viewDidAppear(_ animated: Bool) {
        fetchData()
    }

    @IBAction func createNewButton() {
        if count > 50 {
            // show alert
            let myMessage = "Your sphere can hold 50 items and you've already created 50 items. Coming soon ability to claim new spheres and delete objects."
            let alertController = UIAlertController(title: "Max items created", message: myMessage, preferredStyle: .alert)

            // Add an action (button)
            alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))

            // Present the alert controller
            self.present(alertController, animated: true, completion: nil)
        } else {
            // show segue
            self.performSegue(withIdentifier: "goToReplicator", sender: self)

        }

    }
    func fetchData() {
        let email = Defaults[.email]
        let authToken = Defaults[.authToken]
        let yourSphereId = Defaults[.selectedSphereId]

        OpenspaceAPI.shared.fetchData(email: email, authToken: authToken, sphereId: yourSphereId) { result in
            switch result {
            case .success(let responseData):
                self.count = responseData.pending.count + responseData.completed.count
                DispatchQueue.main.async {
                    if self.count == 1 {
                        self.numberOfObjectsInSphere.text = "   You have \(self.count) item in your sphere, out of a max of 50.   "
                    } else {
                        self.numberOfObjectsInSphere.text = "   You have \(self.count) items in your sphere, out of a max of 50.   "

                    }
                }
            case .failure(let error):
                print("Error fetching data: \(error)")
            }
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
