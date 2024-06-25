//
//  SettingsViewController.swift
//  GridHack
//
//  Created by Andy Triboletti on 2/8/20.
//  Copyright © 2020 GreenRobot LLC. All rights reserved.
//

import UIKit
import Alamofire
import FirebaseAuth
import SwiftyJSON
import CTFeedbackSwift

class SettingsViewController: UIViewController {

    @IBOutlet var feedbackButton: UIButton!
    @IBOutlet var aboutButton: UIButton!

    @IBAction func aboutButtonAction() {
        print("about")

        let alert = UIAlertController(title: "Election Game Credits",
                                      message: "Game Development & Design: Andy Triboletti of GreenRobot.\n\nDonkey, Elephant & Protester modeling and animation: Angel Ayala", preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {(_: UIAlertAction!) in
        }))
        self.present(alert, animated: false)

    }

    @IBAction func feedbackButtonAction() {
        print("feedback")
        let configuration = FeedbackConfiguration(toRecipients: ["info+electiongame@greenrobot.com"], hidesAttachmentCell: true )
        let controller    = FeedbackViewController(configuration: configuration)
        navigationController?.pushViewController(controller, animated: true)
    }

    @IBAction func dismissView() {
        self.dismiss(animated: false, completion: nil)
    }

    @IBAction func logout() {
        logoutOfFirebase()
    }

    @IBAction func deleteAccount() {
        let alert = UIAlertController(title: "Delete Account",
                                      message: "Do you really want to delete your account?", preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "Delete Account Forever",
                                      style: .destructive, handler: {(_: UIAlertAction!) in
            print("really delete")
            self.reallyDelete()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: {(_: UIAlertAction!) in
        }))
        self.present(alert, animated: false)

    }
    func reallyDelete() {
        let url = Common.baseUrl + "delete_account.php"
        let parameters: Parameters = [
            "firebase_uid": Auth.auth().currentUser!.uid
        ]

        _ = appDelegate.session.request(url, method: .post, parameters: parameters).responseJSON(
            completionHandler: { (data: DataResponse) in
            let json = JSON(data.value as Any)

            print("deleted account result")
            print(json)
            let result: String = json["result"].stringValue
            print(result)
            if result == "error" {
                print("error")
            } else if result == "success" {
                print("success")
                self.logoutOfFirebase()
                self.performSegue(withIdentifier: "goToLoginFromSettings", sender: self)
            }
        })
    }

    func logoutOfFirebase() {
        print("logout of firebase")
        let firebaseAuth = Auth.auth()
        do {
            print("sign out")
            try firebaseAuth.signOut()
            self.performSegue(withIdentifier: "goToLoginFromSettings", sender: self)

        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
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
