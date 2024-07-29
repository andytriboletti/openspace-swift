//
//  WaitForOpponent.swift
//  GridHack
//
//  Created by Andy Triboletti on 2/5/20.
//  Copyright © 2020 GreenRobot LLC. All rights reserved.
//

import Foundation
import UIKit
import Toast_Swift
class WaitForOpponentViewController: UIViewController, MultiplayerProtocol {
    func connectionNotEstablished() {
        if self.view.window == nil {
            //print("window is nil.. not presenting alert")
            return
        }
            let alert = UIAlertController(title: "Can't Connect!",
                                          message: "Can't connect to server. Please try again later.", preferredStyle: .alert)

            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {(_: UIAlertAction!) in
                self.performSegue(withIdentifier: "clickCancel", sender: self)

            }))
            self.present(alert, animated: false)
    }
    func endGame() {
        //print("shouldn't happen")
    }
    func opponentFound() {
        self.view.makeToast("Opponent Found")
        self.performSegue(withIdentifier: "goToGameFromWaiting", sender: self)

    }

    override func viewWillAppear(_ animated: Bool) {
        appDelegate.multiplayer.delegate = self
        appDelegate.multiplayer.connectToWebSocket()

    }
    override func viewDidLoad() {

    }
    @IBAction func clickCancel() {
        appDelegate.multiplayer.socket?.disconnect()

    }
}
