//
//  AuctionHouseViewController.swift
//  Open Space
//
//  Created by Andrew Triboletti on 8/4/23.
//  Copyright © 2023 GreenRobot LLC. All rights reserved.
//

import UIKit
import SceneKit
import Alamofire
import Defaults

class AuctionHouseViewController: UIViewController {
    @IBOutlet weak var stackView: UIStackView!

    @IBOutlet var spaceportButton: UIButton!

    @IBOutlet var tradingPostButton: UIButton!

    @IBOutlet var treasureButton: UIButton!

    @IBOutlet var takeOffButton: UIButton!

    @IBOutlet var headerLabel: PaddingLabel!

    var baseNode: SCNNode!
    @IBOutlet var scnView: SCNView!

    @IBAction func takeOffAction() {
        // self.dismiss(animated: true, completion: {
            self.performSegue(withIdentifier: "takeOffFromMoon", sender: self)
            // self.dismiss(animated: true, completion: nil)

        // })

    }

    @objc func shipsAction(_ sender: UIBarButtonItem) {

        self.performSegue(withIdentifier: "selectShip", sender: sender)

    }

    override func viewDidLoad() {
        super.viewDidLoad()

        headerLabel.layer.masksToBounds = true
        headerLabel.layer.cornerRadius = 35.0
        headerLabel.layer.borderColor = UIColor.darkGray.cgColor
        headerLabel.layer.borderWidth = 3.0

    }
    @objc
    func handleTap(_ gestureRecognize: UIGestureRecognizer) {
        // retrieve the SCNView
        }

}
