//
//  LobbyViewController.swift
//  GridHack
//
//  Created by Andy Triboletti on 2/4/20.
//  Copyright © 2020 GreenRobot LLC. All rights reserved.
//

import Foundation
import UIKit
import FirebaseAuth
import Alamofire
import SwiftyUserDefaults
import SwiftyJSON
import SceneKit
import MaterialComponents.MaterialButtons
import MaterialComponents.MaterialButtons_Theming
import Defaults

class LobbyViewController: UIViewController, PartyDelegate {
    @IBOutlet var singleButton: MDCButton!
    @IBOutlet var multiButton: MDCButton!
    @IBOutlet var howToPlayButton: MDCButton!
    @IBOutlet var switchPartyButton: MDCButton!
    @IBOutlet var profileButton: MDCButton!
    @IBOutlet var settingsButton: MDCButton!

    var myScene: SCNScene?
    var sceneView: SCNView?
    @IBOutlet var iconView: UIView!
    @IBOutlet var joinMultiplayerGameButton: UIButton!

    @IBAction func goBack() {

        let storyboard = UIStoryboard(name: "Main", bundle: nil)

        if let viewController = storyboard.instantiateViewController(withIdentifier: "TargetViewControllerIdentifier") as? MoonViewController {
            viewController.modalPresentationStyle = .fullScreen
            self.present(viewController, animated: true, completion: nil)
        } else {
            print("Failed to instantiate LobbyViewController from MainGridHack storyboard")
        }

    }

    func updatedParty() {
        print("updated party")
        // refresh
        refreshNoNetwork()
    }

    @IBAction func startSinglePlayer() {
        appDelegate.isMultiplayer = false
        self.performSegue(withIdentifier: "goToGame", sender: self)
    }

    @IBAction func startMultiplayer() {
        appDelegate.isMultiplayer = true
        self.performSegue(withIdentifier: "goToWaiting", sender: self)
    }

    @IBOutlet var teamLabel: UILabel?

    @IBAction func switchParty() {
        print("switch party")
        if Defaults[.team] == "bernie" {
            self.sceneView!.scene = appDelegate.elephantScene
            Defaults[.team] = "trump"
        } else if Defaults[.team] == "trump" {
            Defaults[.team] = "bernie"
            self.sceneView!.scene = appDelegate.donkeyScene

        }

        refreshNoNetwork()
        setTeam()

        //        if appDelegate.team == "bernie" {
        //            self.sceneView!.scene = appDelegate.elephantScene
        //            GridHackUtils().pickPartyNoNetwork(party: "trump", delegate: self)
        //        } else if appDelegate.team == "trump" {
        //            self.sceneView!.scene = appDelegate.donkeyScene
        //
        //            GridHackUtils().pickPartyNoNetwork(party: "bernie", delegate: self)
        //        }
        // refreshNoNetwork()
    }

    func refreshNoNetwork() {

        // self.appDelegate.team = "bernie" //json["user"]["party"].stringValue

        if Defaults[.team] == "bernie" {
            self.sceneView!.scene = self.appDelegate.donkeyScene

            self.colorButtonsBlue()
        } else {
            self.sceneView!.scene = self.appDelegate.elephantScene

            self.colorButtonsRed()
        }

        setTeam()

    }
    func setTeam() {

        var teamName: String = ""
        if Defaults[.team] == "bernie" {
            teamName = "biden"
        } else {
            teamName = "trump"
        }
        // self.appDelegate.username = json["user"]["username"].stringValue
        self.teamLabel!.text = "Team: " +
            teamName.firstUppercased
    }

    func refresh() {

        let url = Common.baseUrl + "enter_lobby.php"
        let parameters: Parameters = [
            "firebase_uid": Auth.auth().currentUser!.uid
        ]

        _ = appDelegate.session.request(url, method: .post, parameters: parameters).responseJSON(completionHandler: { (data: DataResponse) in
            let json = JSON(data.value as Any)

            print("enter lobby")
            print(json)
            let result: String = json["status"].stringValue
            print(result)
            if result == "error" {
                let message: String = json["message"].stringValue
                if message == "user-missing" {
                    self.performSegue(withIdentifier: "goToRegistrationFromLobby", sender: self)
                }
                if message == "party-missing" {
                    self.performSegue(withIdentifier: "goToPickPartyFromLobby", sender: self)
                }
            } else if result == "success" {
                let systemVariables = json["system_variables"]
                let enableMultiplayer: Bool = systemVariables["enable_multiplayer"].boolValue
                if enableMultiplayer {
                    print("enable multiplayer")
                    self.joinMultiplayerGameButton.isHidden = false
                } else {
                    print("disable multiplayer")
                    self.joinMultiplayerGameButton.isHidden = true

                }

                print("enter lobby success")

                self.appDelegate.team = json["user"]["party"].stringValue

                if self.appDelegate.team == "bernie" {
                    self.sceneView!.scene = self.appDelegate.donkeyScene

                    self.colorButtonsBlue()
                } else {
                    self.sceneView!.scene = self.appDelegate.elephantScene

                    self.colorButtonsRed()
                }

                self.appDelegate.username = json["user"]["username"].stringValue
                self.setTeam()

            }
        })
    }
//    func playIdleAnimation() {
//        let animation = subAnimation(of:fullAnimation, startFrame: 10, endFrame: 160)
//        animation.repeatCount = .greatestFiniteMagnitude
//        addAnimation(animation, forKey: "animation")
//    }

    func colorButtonsRed() {

        self.singleButton.applyTextTheme(withScheme: appDelegate.containerSchemeRed)
        self.singleButton.applyContainedTheme(withScheme: appDelegate.containerSchemeRed)

        self.multiButton.applyTextTheme(withScheme: appDelegate.containerSchemeRed)
        self.multiButton.applyContainedTheme(withScheme: appDelegate.containerSchemeRed)

        self.howToPlayButton.applyTextTheme(withScheme: appDelegate.containerSchemeRed)
        self.howToPlayButton.applyContainedTheme(withScheme: appDelegate.containerSchemeRed)

        self.switchPartyButton.applyTextTheme(withScheme: appDelegate.containerSchemeRed)
        self.switchPartyButton.applyContainedTheme(withScheme: appDelegate.containerSchemeRed)
//
//        self.profileButton.applyTextTheme(withScheme: appDelegate.containerSchemeRed)
//        self.profileButton.applyContainedTheme(withScheme: appDelegate.containerSchemeRed)
//
        self.settingsButton.applyTextTheme(withScheme: appDelegate.containerSchemeRed)
        self.settingsButton.applyContainedTheme(withScheme: appDelegate.containerSchemeRed)

    }

    func colorButtonsBlue() {

        self.singleButton.applyTextTheme(withScheme: appDelegate.containerSchemeBlue)
        self.singleButton.applyContainedTheme(withScheme: appDelegate.containerSchemeBlue)
        // self.singleButton.textS

        self.multiButton.applyTextTheme(withScheme: appDelegate.containerSchemeBlue)
        self.multiButton.applyContainedTheme(withScheme: appDelegate.containerSchemeBlue)

        self.howToPlayButton.applyTextTheme(withScheme: appDelegate.containerSchemeBlue)
        self.howToPlayButton.applyContainedTheme(withScheme: appDelegate.containerSchemeBlue)

        self.switchPartyButton.applyTextTheme(withScheme: appDelegate.containerSchemeBlue)
        self.switchPartyButton.applyContainedTheme(withScheme: appDelegate.containerSchemeBlue)
//        
//        self.profileButton.applyTextTheme(withScheme: appDelegate.containerSchemeBlue)
//        self.profileButton.applyContainedTheme(withScheme: appDelegate.containerSchemeBlue)
//        
        self.settingsButton.applyTextTheme(withScheme: appDelegate.containerSchemeBlue)
        self.settingsButton.applyContainedTheme(withScheme: appDelegate.containerSchemeBlue)

    }
    func subAnimation(of fullAnimation: CAAnimation, startFrame: Int, endFrame: Int) -> CAAnimation {
        let (startTime, duration) = timeRange(startFrame: startFrame, endFrame: endFrame)
        let animation = subAnimation(of: fullAnimation, offset: startTime, duration: duration)
        return animation
    }

    func subAnimation(of fullAnimation: CAAnimation, offset timeOffset: CFTimeInterval, duration: CFTimeInterval) -> CAAnimation {
        fullAnimation.timeOffset = timeOffset
        let container = CAAnimationGroup()
        container.animations = [fullAnimation]
        container.duration = duration
        return container
    }

    func timeRange(startFrame: Int, endFrame: Int) -> (startTime: CFTimeInterval, duration: CFTimeInterval) {
        let startTime = timeOf(frame: startFrame)
        let endTime = timeOf(frame: endFrame)
        let duration = endTime - startTime
        return (startTime, duration)
    }

    func timeOf(frame: Int) -> CFTimeInterval {
        return CFTimeInterval(frame) / framesPerSecond()
    }

    func framesPerSecond() -> CFTimeInterval {
        // number of frames per second the model was designed with
        return 30.0
    }

    override func viewWillAppear(_ animated: Bool) {
        if Auth.auth().currentUser == nil {
            performSegue(withIdentifier: "goToLoginFromLobby", sender: self)
            return
        }

        //    @IBOutlet var singleButton: MDCButton!
        // @IBOutlet var multiButton: MDCButton!
        // @IBOutlet var howToPlayButton: MDCButton!
        // @IBOutlet var switchPartyButton: MDCButton!
        // @IBOutlet var profileButton: MDCButton!
        // @IBOutlet var settingsButton: MDCButton!

        // retrieve the SCNView

        let frame  = CGRect(x: 0, y: 0, width: self.iconView.frame.width, height: self.iconView.frame.height)
        self.sceneView = SCNView(frame: frame)

        sceneView!.sceneTime = 70

        var animationPlayer: SCNAnimationPlayer! = nil
//
//        let url = URL(string: "sm_Protester_TrumpNamed.dae")
//        let sceneSource = SCNSceneSource(url: url!, options: [
//            SCNSceneSource.LoadingOption.animationImportPolicy : SCNSceneSource.AnimationImportPolicy.doNotPlay
//          ])
        // var node = sceneSource!.entryWithIdentifier("monster", withClass: SCNNode.self)

        // var attackAnimation = sceneSource!.entryWithIdentifier("Protestor_Resting", withClass: CAAnimation.self)

        // node!.addAnimation(attackAnimation!, forKey: "attack")

        myScene?.rootNode.enumerateHierarchy { (child, _)  in
            if !child.animationKeys.isEmpty {
                print("child = \(child) -----------------")
                print("child.aniationKeys = \(child.animationKeys) -----------------")
                animationPlayer = child.animationPlayer(forKey: child.animationKeys[0])

                myScene!.rootNode.addAnimationPlayer(animationPlayer, forKey: "\(child)")
                animationPlayer.play()

            }
        }

        sceneView!.autoenablesDefaultLighting=true
        // sceneView.backgroundColor = UIColor.gray
        if traitCollection.userInterfaceStyle == .light {
            sceneView!.backgroundColor=UIColor.white

        } else {
            sceneView!.backgroundColor=UIColor.black

        }

        sceneView!.scene = myScene

        self.iconView.addSubview(sceneView!)

        // get data from server
        // refresh()
        refreshNoNetwork()

        // show ads
        // showAds()

    }

    func showAds() {
        let number = Int.random(in: 0 ..< Common.adFrequency )
        print("random: \(number)")
        #if targetEnvironment(macCatalyst)
        #else

//            if appDelegate.interstitial.isReady && number == 0 {
//                appDelegate.interstitial.present(fromRootViewController: self)
//            } else {
//              print("Ad wasn't ready")
//            }

        #endif
    }
}

extension StringProtocol {
    var firstUppercased: String { return prefix(1).uppercased() + dropFirst() }
    var firstCapitalized: String { return prefix(1).capitalized + dropFirst() }
}
