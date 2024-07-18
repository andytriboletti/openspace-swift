//
//  GameViewController.swift
//  GridHackSceneKit
//
//  Created by Andy Triboletti on 1/30/20.
//  Copyright © 2020 GreenRobot LLC. All rights reserved.
//

import UIKit
import QuartzCore
import SceneKit

class GridHackGameViewController: UIViewController, MultiplayerProtocol {
    func connectionNotEstablished() {
        print("shouldn't happen")
    }
    func opponentFound() {
        print("shouldn't happen")
    }
    func endGame() {
        appDelegate.gridNode.enumerateChildNodes { (node, _) in
             node.removeFromParentNode()
         }
        appDelegate.gridNode.removeFromParentNode()

        self.performSegue(withIdentifier: "goToResults", sender: self)
    }
    var scnView: SCNView?
    var overlay: InfoOverlayScene?
    var timer: Timer?
    var endGameTimer: Timer?
    override func viewWillAppear(_ animated: Bool) {
        appDelegate.multiplayer.delegate = self
        self.startTimer()
        if appDelegate.isMultiplayer == false {
            self.endGameTimer = Timer.scheduledTimer(timeInterval: TimeInterval(Common.timeLeft), target: self, selector: Selector(("endGameFunction")), userInfo: nil, repeats: false)
        }

        appDelegate.gridHackGameState = GridHackGameState()

        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(closeTapped))
        navigationItem.leftBarButtonItem?.tintColor = .systemBlue  // or any color that contrasts well with the background
        #if targetEnvironment(macCatalyst)
        if #available(iOS 13.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = .white // Set the navigation bar background color to white
            appearance.titleTextAttributes = [.foregroundColor: UIColor.black] // Set the title color if needed

            navigationController?.navigationBar.standardAppearance = appearance
            navigationController?.navigationBar.scrollEdgeAppearance = appearance
            navigationController?.navigationBar.compactAppearance = appearance

            // Ensure the bar button item tint color is set
            navigationItem.leftBarButtonItem?.tintColor = .systemBlue
        } else {
            // Fallback on earlier versions
            navigationController?.navigationBar.barTintColor = .white
            navigationController?.navigationBar.tintColor = .systemBlue
        }
        #endif



        if appDelegate.isMultiplayer == false {
            navigationItem.title = "Bernie Vs Trump - Single Player"
        } else {
            navigationItem.title = "Bernie Vs Trump - Multiplayer"

        }

        // create a new scene
        appDelegate.scene = GameScene()
        appDelegate.gameViewController = self
        // retrieve the SCNView
        scnView = (self.view as? SCNView)
        scnView!.autoenablesDefaultLighting=true

        // set the scene to the view
        scnView!.scene = appDelegate.scene

        // allows the user to manipulate the camera
        scnView!.allowsCameraControl = true
        scnView!.defaultCameraController.interactionMode = .pan
        scnView!.defaultCameraController.inertiaEnabled = true

        scnView!.cameraControlConfiguration.rotationSensitivity=0.0
        scnView!.cameraControlConfiguration.truckSensitivity=0.0

        scnView!.cameraControlConfiguration.panSensitivity = 0.01
        scnView!.defaultCameraController.maximumVerticalAngle = 0
        scnView!.defaultCameraController.minimumVerticalAngle = 0
        scnView!.defaultCameraController.maximumHorizontalAngle = 0
        scnView!.defaultCameraController.minimumHorizontalAngle = 0

        // scnView!.pointOfView?.rotation = SCNVector4(0, 0, 0, 0)
        scnView!.pointOfView?.movabilityHint = .fixed

        scnView?.backgroundColor = UIColor.black

        let tapRec = UITapGestureRecognizer(target: self, action: #selector(handleTap(rec:)))

        scnView!.addGestureRecognizer(tapRec)
        self.overlay = InfoOverlayScene(size: scnView!.frame.size)
        overlay!.gameScene = appDelegate.scene
        scnView!.overlaySKScene = overlay

        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        var zoomLevel = 15.0
        #if targetEnvironment(macCatalyst)
        zoomLevel = 15.0
        #else
        if UIDevice.current.userInterfaceIdiom == .pad {
            zoomLevel = 15.0
        } else {
            zoomLevel = 18.0
        }
        #endif

        let yOffset = 0
        cameraNode.position = SCNVector3(x: Float((Float(GameScene.GRIDSIZE))/2) + 0.5, y: Float((Float(GameScene.GRIDSIZE) + 1.5)/2) - Float(yOffset), z: Float(zoomLevel))
        appDelegate.scene!.rootNode.addChildNode(cameraNode)
        scnView!.scene = appDelegate.scene

    }

    override func viewWillDisappear(_ animated: Bool) {
        self.stopTimer()
        appDelegate.multiplayer.disconnectFromWebSocket()

    }

    func stopTimer() {
        timer?.invalidate()
        timer = nil
        endGameTimer?.invalidate()
        endGameTimer = nil
    }

    func startTimer() {
        self.timer = Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: Selector(("checkForIdleUnits")), userInfo: nil, repeats: true)
    }

    override func viewDidAppear(_ animated: Bool) {
        self.overlay!.startTimer()
    }
    override func viewDidDisappear(_ animated: Bool) {
        self.overlay?.stopTimer()
        self.overlay = nil

    }

    func doYouWantToLeave() {

        let alert = UIAlertController(title: "Do You Want To Leave?",
                                      message: "The game is in progress. Do you want to leave?", preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "Leave", style: .destructive, handler: {(_: UIAlertAction!) in
            self.reallyLeave()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: {(_: UIAlertAction!) in

        }))
        self.present(alert, animated: false)
    }
    func reallyLeave() {
        appDelegate.gridNode.enumerateChildNodes { (node, _) in
             node.removeFromParentNode()
         }
        appDelegate.gridNode.removeFromParentNode()

        self.navigationController!.performSegue(withIdentifier: "goToLobbyFromGame", sender: self)
    }
    @objc func closeTapped() {
        self.doYouWantToLeave()
    }

    var previousLoc = CGPoint.init(x: 0, y: 0)

    var panStartZ: CGFloat = 0.0
    var lastPanLocation: SCNVector3?

    // Method called when tap
    @objc func handleTap(rec: UITapGestureRecognizer) {
        if rec.state == .ended {
            let location: CGPoint = rec.location(in: self.scnView)
            let hits = self.scnView!.hitTest(location, options: [SCNHitTestOption.rootNode: appDelegate.gridNode])
            if !hits.isEmpty {
                let tappedNode = hits.first?.node
                print("tapped: %@", tappedNode!.position)
                print("tappedx: %@", tappedNode!.position.x)
                print("tappedy: %@", tappedNode!.position.y)
                if appDelegate.isMultiplayer {
                    appDelegate.multiplayer.tappedPosition(position: tappedNode!.position)

                }
                if appDelegate.gridHackGameState.points[Int(tappedNode!.position.x)][Int((tappedNode?.position.y)!)] == GridState.open {
                    print("it's open")

                    if appDelegate.isMultiplayer == false {
                        DumbAI.selectSquareToBeBuiltRandomly()
                    }
                    appDelegate.gridHackGameState.points[Int(tappedNode!.position.x)][Int((tappedNode?.position.y)!)] = GridState.waitingForFriendlyConstruction
                    let node = tappedNode!
                    node.geometry = node.geometry!.copy() as? SCNGeometry
                    node.geometry?.firstMaterial = node.geometry?.firstMaterial!.copy() as? SCNMaterial
                    node.geometry?.firstMaterial?.diffuse.contents = Friendly().getLightColor()
                    checkForIdleUnits()

                } else if appDelegate.gridHackGameState.points[Int(tappedNode!.position.x)][Int((tappedNode?.position.y)!)] == GridState.waitingForFriendlyConstruction {
                    print("waiting for friendly construction - open now")
                    appDelegate.gridHackGameState.points[Int(tappedNode!.position.x)][Int((tappedNode?.position.y)!)] = GridState.open
                    let node = tappedNode!
                    node.geometry = node.geometry!.copy() as? SCNGeometry
                    node.geometry?.firstMaterial = node.geometry?.firstMaterial!.copy() as? SCNMaterial
                    node.geometry?.firstMaterial?.diffuse.contents = UIColor.lightGray
                    checkForIdleUnits()
                }
            }
        }
    }
    @objc func endGameFunction() {
        self.endGame()
    }
    @objc func checkForIdleUnits() {
        checkForIdleBuilders()
        checkForIdleEnemyBuilders()
        checkForIdleEnemyAttackers()
        checkForIdleAttackers()
        checkForIdleHackers()
        checkForIdleEnemyHackers()
    }
    func checkForIdleBuilders() {
        // print("check for idle")
        if appDelegate.gridHackGameState.idleBuilders?.count == 0 {
            return
        }
        let builder = appDelegate.gridHackGameState.idleBuilders?.popLast()
        if builder == nil {
            return
        }

        FriendlyBuilderFactory.spawnBuilder(character: builder)

    }
    func checkForIdleHackers() {
        // print("check for idle hackers")
        if appDelegate.gridHackGameState.idleHackers?.count == 0 {
            return
        }
        let unit = appDelegate.gridHackGameState.idleHackers?.popLast()
        if unit == nil {
            return
        }
        FriendlyHackerFactory.spawnHacker(character: unit)

    }
    func checkForIdleEnemyHackers() {
        // print("check for idle enemy hackers")
        if appDelegate.gridHackGameState.idleEnemyHackers?.count == 0 {
            return
        }
        let unit = appDelegate.gridHackGameState.idleEnemyHackers?.popLast()
        if unit == nil {
            return
        }
        EnemyHackerFactory.spawnHacker(character: unit)
    }

    func checkForIdleAttackers() {
        // print("check for idle attackers")
        if appDelegate.gridHackGameState.idleAttackers?.count == 0 {
            return
        }
        let builder = appDelegate.gridHackGameState.idleAttackers?.popLast()
        if builder == nil {
            return
        }
        FriendlyAttackerFactory.spawnAttacker(character: builder)

    }
    func checkForIdleEnemyAttackers() {
        // print("check for idle enemy attackers")
        if appDelegate.gridHackGameState.idleEnemyAttackers!.count == 0 {
            return
        }
        let builder = appDelegate.gridHackGameState.idleEnemyAttackers!.popLast()
        if builder == nil {
            return
        }
        EnemyAttackerFactory.spawnEnemyAttacker(character: builder)

    }
    func checkForIdleEnemyBuilders() {
        // print("check for idle enemy builders")
        if appDelegate.gridHackGameState.idleEnemyBuilders?.count == 0 {
            return
        }
        let builder = appDelegate.gridHackGameState.idleEnemyBuilders?.popLast()
        if builder == nil {
            return
        }
        EnemyBuilderFactory.spawnEnemyBuilder(character: builder)

    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

}
