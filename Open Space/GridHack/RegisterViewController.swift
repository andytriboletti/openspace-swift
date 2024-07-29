//
//  RegisterViewController.swift
//  MOE
//
//  Created by Andy Triboletti on 12/29/19.
//  Copyright © 2019 GreenRobot LLC. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import SwiftyUserDefaults
import SwiftyJSON
import Firebase
import FirebaseAuth

class RegisterViewController: UIViewController {

    @IBOutlet var pleasePick: UILabel!

    @IBOutlet var username: UITextField?
    @IBOutlet var email: UITextField?
    @IBAction func register() {
        // call register.php passing phone number and uid from defaults and
        // username from name uitextfield

        if self.username == nil || self.username!.text == nil {
            return
        }

        // let emailText:String = self.email!.text!
        let usernameText: String = self.username!.text!

        let url = Common.baseUrl + "register_v2.php"
        var platform = "ios"
        #if targetEnvironment(macCatalyst)
            platform="macos"
        #endif
        var parameters: Parameters = [
            "firebase_uid": Auth.auth().currentUser!.uid,
            "username": usernameText,
            "platform": platform
        ]
        if Auth.auth().currentUser!.email != nil {
            parameters["email"]  = Auth.auth().currentUser!.email!
        }
        if Auth.auth().currentUser!.phoneNumber != nil {
            parameters["phone_number"]  = Auth.auth().currentUser!.phoneNumber!
        }

        _ = appDelegate.session.request(url, method: .post, parameters: parameters).responseJSON(completionHandler: { (data: DataResponse) in
            // print(data.response.debugDescription)
            let json = JSON(data.value as Any)

            //print("register")
            print(json)
            let result: String = json["result"].stringValue
            if result == "success" {
                //print("success registering")
                self.performSegue(withIdentifier: "goToLobbyFromRegister", sender: self)
            } else {
                let message = json["message"].stringValue
                if message == "pick-new-username" {
                    self.pleasePick.text = "Username taken. Please try again."
                }
                //print("error registering")
                print(parameters.description)
            }
        })

    }

    override func viewDidLoad() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(closeTapped))
        navigationItem.title = "Registration"

    }

    @objc func closeTapped() {

        dismiss(animated: false, completion: nil)
    }

}
