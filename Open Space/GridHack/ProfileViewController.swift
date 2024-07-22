//
//  ProfileViewController.swift
//  GridHack
//
//  Created by Andy Triboletti on 2/8/20.
//  Copyright © 2020 GreenRobot LLC. All rights reserved.
//

import UIKit
import Defaults

class ProfileViewController: UIViewController {

    @IBOutlet var usernameLabel: UILabel?
    @IBAction func dismissView() {
        self.dismiss(animated: false, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        let username = Defaults[.username]
        usernameLabel!.text = "Username: \(username)"
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
