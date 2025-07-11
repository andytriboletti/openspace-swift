//
//  ExploreMarsViewController.swift
//  Open Space
//
//  Created by Andrew Triboletti on 3/30/24.
//  Copyright © 2024 GreenRobot LLC. All rights reserved.
//

import UIKit
import SceneKit
import Defaults
import SwiftUI

class ExploreMarsViewController: UIViewController {
        private var hostingController: UIHostingController<PopupContainerView>?
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
                self.performSegue(withIdentifier: "takeOffFromMars", sender: self)
                // self.dismiss(animated: true, completion: nil)

            // })

        }

        @objc func shipsAction(_ sender: UIBarButtonItem) {

            self.performSegue(withIdentifier: "selectShip", sender: sender)

        }

        func addButtonToStackView() {
                // Create a new UIButton instance
                treasureButton = UIButton(type: .system)
            treasureButton.backgroundColor = .systemBlue // Or your desired color
            treasureButton.setTitleColor(.white, for: .normal)
            treasureButton.layer.cornerRadius = 8 // Adjust for desired roundness
            treasureButton.contentEdgeInsets = UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20) // Adjust padding as needed

            //treasureButton.configuration = UIButton.Configuration.filled()

            treasureButton.setTitle("Claim Hourly Mars Treasure!", for: .normal)
            treasureButton.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)

                // Add any additional customization to the button (e.g., setting background color, text color, etc.)

                // Add the button to the stack view
                stackView.addArrangedSubview(treasureButton)

                // Optionally, you can set constraints for the button if needed
            treasureButton.translatesAutoresizingMaskIntoConstraints = false
            treasureButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        }

    @objc func buttonTapped() {
        // Action to be performed when the button is tapped
        //print("Button tapped!")
        OpenspaceAPI.shared.claimDailyTreasure(planet: "mars") { result in
            switch result {
            case .success(let (status, mineral, amount)):
                // Handle response
                //print("Response from claim daily treasure: \(status)")

                if status == "claimed" {
                    // Show a success message to the user on the main thread
                    DispatchQueue.main.async {
                        self.showSuccessMessage(mineral: mineral, amount: amount)
                    }
                } else if status == "over_limit" {
                    // Show a specific message for over limit error
                    DispatchQueue.main.async {
                        self.showOverLimitMessage()
                    }
                } else {
                    // Show an error message or handle any other response status accordingly on the main thread
                    DispatchQueue.main.async {
                        self.showError()
                    }
                }
            case .failure(let error):
                // Handle error
                print("Error claiming daily treasure: \(error.localizedDescription)")
            }
        }
    }
    func showOverLimitMessage() {
        let alertController = UIAlertController(title: "Cargo Limit Exceeded", message: "Not enough cargo space on the ship to claim the minerals.", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alertController, animated: true, completion: nil)
    }

    
    func checkDailyTreasureAvailability() {
        // Call API to check daily treasure availability
        OpenspaceAPI.shared.checkDailyTreasureAvailability(planet: "mars") { result in
            switch result {
            case .success(let response):
                //print("Response from check daily treasure availability: \(response)")

                // Assuming response is a JSON string and converting it to a dictionary
                if let data = response.data(using: .utf8),
                   let jsonResponse = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let status = jsonResponse["status"] as? String {
                    if status == "claimed" {
                        DispatchQueue.main.async {
                            self.showClaimedText()
                            self.hideTreasureButton()
                        }
                    } else if status == "available" {
                        DispatchQueue.main.async {
                            self.showTreasureButton()
                        }
                    }
                } else {
                    //print("Unexpected response format")
                    self.showError()
                }

            case .failure(let error):
                //print("Error checking daily treasure availability: \(error.localizedDescription)")
                self.showError()
            }
        }
    }


    func showClaimedText() {
        // Hide the treasure button
        treasureButton.isHidden = true

        // Check if the claimed label is already in the stackView
        if !stackView.arrangedSubviews.contains(where: { ($0 as? UILabel)?.text == "Hourly Mars treasure already claimed." }) {
            let claimedLabel = UILabel()
            claimedLabel.text = "Hourly Mars treasure already claimed."
            claimedLabel.textAlignment = .center
            claimedLabel.textColor = .white
            stackView.addArrangedSubview(claimedLabel)
        }
    }


        func showTreasureButton() {
            // Hide the text and show the button
            treasureButton.isHidden = false
        }
        func hideTreasureButton() {
            // Hide the text and show the button
            treasureButton.isHidden = true
        }

        override func viewDidLoad() {
            super.viewDidLoad()
            self.addButtonToStackView()

            // Call the function to check if the daily treasure is available for the user
             checkDailyTreasureAvailability()

            headerLabel.layer.masksToBounds = true
            headerLabel.layer.cornerRadius = 35.0
            headerLabel.layer.borderColor = UIColor.darkGray.cgColor
            headerLabel.layer.borderWidth = 3.0

            baseNode = SCNNode()
            let scene = SCNScene()
            self.title="Your ship '\(appDelegate.gameState.getShipName())' is on Mars"

            let backgroundFilename = "PIA01120orig.jpg"
            let image = UIImage(named: backgroundFilename)!

            let size = CGSize(width: self.view.frame.width, height: self.view.frame.height)
            let aspectScaledToFitImage = image.af.imageAspectScaled(toFill: size)
            scene.background.contents = aspectScaledToFitImage
            scene.background.wrapS = SCNWrapMode.repeat
            scene.background.wrapT = SCNWrapMode.repeat

            scene.rootNode.addChildNode(baseNode)

            let cameraNode = SCNNode()
            cameraNode.camera = SCNCamera()
            scene.rootNode.addChildNode(cameraNode)

            // place the camera
            // increased values for y move object lower to bottom of screen
            // increase values for x move object to the left
            // increase values for z move object smaller
            cameraNode.position = SCNVector3(x: 0, y: 15, z: 50)
            cameraNode.rotation = SCNVector4(1, 0, 0, 0.1) // slightly rotate so base is pointed away from user

            baseNode.rotation = SCNVector4(0, -1, 0, 3.14/2)

            // create and add a light to the scene
            let lightNode = SCNNode()
            lightNode.light = SCNLight()
            lightNode.light!.type = .omni
            lightNode.position = SCNVector3(x: 0, y: 10, z: 10)
            scene.rootNode.addChildNode(lightNode)

            // create and add an ambient light to the scene
            let ambientLightNode = SCNNode()
            ambientLightNode.light = SCNLight()
            ambientLightNode.light!.type = .ambient
            ambientLightNode.light!.color = UIColor.darkGray
            scene.rootNode.addChildNode(ambientLightNode)

            // retrieve the SCNView
            let scnView = self.scnView!
            // self.view as! SCNView

            // set the scene to the view
            scnView.scene = scene

            // allows the user to manipulate the camera
            // scnView.allowsCameraControl = true
            scnView.autoenablesDefaultLighting=true

            // show statistics such as fps and timing information
            scnView.showsStatistics = false

            // configure the view
            scnView.backgroundColor = UIColor.black
            // add a tap gesture recognizer
               let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))

            addObject(name: "flagcool.scn", position: SCNVector3(1, 1, 1), scale: nil)

            for _ in 1...50 {
                // addAsteroid()
            }

        }
        @objc
        func handleTap(_ gestureRecognize: UIGestureRecognizer) {
            // retrieve the SCNView
            }

        func addObject(name: String, position: SCNVector3?, scale: SCNVector3?) {
            let shipScene = SCNScene(named: name)!
            var animationPlayer: SCNAnimationPlayer! = nil

            let shipSceneChildNodes = shipScene.rootNode.childNodes
            for childNode in shipSceneChildNodes {
                if position != nil {
                    childNode.position = position!
                }
                if scale != nil {
                    childNode.scale = scale!
                }
                baseNode.addChildNode(childNode)
                baseNode.scale = SCNVector3(0.50, 0.50, 0.50)
                baseNode.position = SCNVector3(0, 0, 0)
                // //print(child.animationKeys)

            }

            for key in shipScene.rootNode.animationKeys {
                // for every animation key
                animationPlayer = shipScene.rootNode.animationPlayer(forKey: key)

                self.scnView.scene!.rootNode.addAnimationPlayer(animationPlayer, forKey: key)
                animationPlayer.play()

            }

        }
        func addAsteroid(position: SCNVector3? = nil, scale: SCNVector3? = nil) {

            var myScale = scale
            if scale == nil {
                let minValue = 1
                let maxValue = 5
                let xScale = Int.random(in: minValue ..< maxValue)
                let yScale = Int.random(in: minValue ..< maxValue)
                let zScale = Int.random(in: minValue ..< maxValue)
                myScale = SCNVector3(xScale, yScale, zScale)
            }

            var myPosition = position
            if position == nil {

                // not too close, not too far
                let minValue = 10
                let maxValue = 100

                var xVal = Int.random(in: minValue ..< maxValue)
                var yVal = Int.random(in: minValue ..< maxValue)
                var zVal = Int.random(in: minValue ..< maxValue)
                // randomly do positive or negative
                if arc4random_uniform(2) == 0 {
                    xVal *= -1
                }
                if arc4random_uniform(2) == 0 {
                    yVal *= -1
                }
                if arc4random_uniform(2) == 0 {
                    zVal *= -1
                }

                myPosition = SCNVector3(xVal, yVal, zVal)
            }
            addObject(name: "a.scn", position: myPosition, scale: myScale)
        }




    func showSuccessMessage(mineral: String, amount: Int) {
           let popupContainerView = PopupContainerView(
               mineral: mineral,
               amount: amount,
               checkDailyTreasureAvailability: checkDailyTreasureAvailability,
               dismiss: { [weak self] in
                   self?.dismissPopup()
               }
           )

           hostingController = UIHostingController(rootView: popupContainerView)

           if let hostingView = hostingController?.view {
               hostingView.backgroundColor = .clear
               hostingView.translatesAutoresizingMaskIntoConstraints = false

               addChild(hostingController!)
               view.addSubview(hostingView)

               NSLayoutConstraint.activate([
                   hostingView.topAnchor.constraint(equalTo: view.topAnchor),
                   hostingView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                   hostingView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                   hostingView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
               ])

               hostingController?.didMove(toParent: self)
           }
       }

       private func dismissPopup() {
           hostingController?.willMove(toParent: nil)
           hostingController?.view.removeFromSuperview()
           hostingController?.removeFromParent()
           hostingController = nil

           checkDailyTreasureAvailability()
       }


//
//    func showSuccessMessage(mineral: String?, amount: Int?) {
//        // Show a success message to the user (e.g., an alert or a label)
//        guard let mineral = mineral, let amount = amount else {
//            // Handle the case where mineral or amount is nil
//            return
//        }
//
//        let alertController = UIAlertController(title: "Congratulations!", message: "You claimed your daily treasure of \(amount) \(mineral).", preferredStyle: .alert)
//        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
//        alertController.addAction(okAction)
//        checkDailyTreasureAvailability()
//        present(alertController, animated: true, completion: nil)
//    }

        func showError() {
            // Show an error message to the user (e.g., an alert or a label)
            let alertController = UIAlertController(title: "Error", message: "Unable to claim the daily treasure.", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(okAction)
            present(alertController, animated: true, completion: nil)
        }

    }
