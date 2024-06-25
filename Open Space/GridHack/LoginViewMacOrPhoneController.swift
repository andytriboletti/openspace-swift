//
//  LoginViewControllerBase.swift
//  GridHack
//
//  Created by Andy Triboletti on 2/4/20.
//  Copyright © 2020 GreenRobot LLC. All rights reserved.
//

import Foundation
import FirebaseAuthUI
import UIKit
import Alamofire
import Firebase
import SwiftyUserDefaults
import SwiftyJSON

class LoginViewMacOrPhoneController: UIViewController {

    override func viewWillAppear(_ animated: Bool) {
        #if targetEnvironment(macCatalyst)
        print("UIKit running on macOS")
        self.performSegue(withIdentifier: "goToMacLogin", sender: self)

        #else
        print("Your regular code")
        self.performSegue(withIdentifier: "goToPhoneLogin", sender: self)

        #endif

    }

}
