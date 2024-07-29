//
//  PickPartyViewController.swift
//  GridHack
//
//  Created by Andy Triboletti on 2/4/20.
//  Copyright © 2020 GreenRobot LLC. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import SwiftyUserDefaults
import SwiftyJSON
import Firebase
class PickPartyViewController: UIViewController, PartyDelegate {
    func updatedParty() {
        self.performSegue(withIdentifier: "goToLobbyFromPickParty", sender: self)
    }

    @IBAction func bernie() {
        //print("pick bernie")
        GridHackUtils().pickParty(party: "bernie", delegate: self)

    }

    @IBAction func trump() {
        //print("pick trump")
        GridHackUtils().pickParty(party: "trump", delegate: self)
    }

}
