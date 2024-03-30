//
//  ExploreMoonViewController.swift
//  Open Space
//
//  Created by Andrew Triboletti on 8/1/23.
//  Copyright © 2023 GreenRobot LLC. All rights reserved.
//

import UIKit
import SceneKit
import Alamofire
import Defaults
import GoogleMobileAds

class ExploreMoonViewController: UIViewController {
    @IBOutlet weak var stackView: UIStackView!

    @IBOutlet var spaceportButton: UIButton!

    @IBOutlet var tradingPostButton: UIButton!

    @IBOutlet var treasureButton: UIButton!
    @IBOutlet var rewardedButton: UIButton!

    @IBOutlet var takeOffButton: UIButton!

    @IBOutlet var headerLabel: PaddingLabel!

    var rewardedAd: GADRewardedAd?

    var baseNode: SCNNode!
    @IBOutlet var scnView: SCNView!

    func loadRewardedAd() async {
        do {
            print("user id is")
            print(Defaults[.userId])

          rewardedAd = try await GADRewardedAd.load(
            withAdUnitID: "ca-app-pub-8840903285420889/2588345097", request: GADRequest())
            let serverSideVerificationOptions = GADServerSideVerificationOptions()
            serverSideVerificationOptions.userIdentifier = Defaults[.userId]
            rewardedAd?.serverSideVerificationOptions = serverSideVerificationOptions
        } catch {
          print("Rewarded ad failed to load with error: \(error.localizedDescription)")
        }
      }

    @IBAction func takeOffAction() {
        // self.dismiss(animated: true, completion: {
            self.performSegue(withIdentifier: "takeOffFromMoon", sender: self)
            // self.dismiss(animated: true, completion: nil)

        // })

    }

    @objc func shipsAction(_ sender: UIBarButtonItem) {

        self.performSegue(withIdentifier: "selectShip", sender: sender)

    }

    func addButtonToStackView() {
            // Create a new UIButton instance
            treasureButton = UIButton(type: .system)
        treasureButton.setTitle("Claim Hourly Treasure!", for: .normal)
        treasureButton.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)

            // Add any additional customization to the button (e.g., setting background color, text color, etc.)

            // Add the button to the stack view
            stackView.addArrangedSubview(treasureButton)

            // Optionally, you can set constraints for the button if needed
        treasureButton.translatesAutoresizingMaskIntoConstraints = false
        treasureButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
    }
    func addRewardedButtonToStackView() {
            // Create a new UIButton instance
            rewardedButton = UIButton(type: .system)
        rewardedButton.setTitle("Watch a Video Ad To Claim Treasure Now", for: .normal)
        rewardedButton.addTarget(self, action: #selector(buttonTappedRewarded), for: .touchUpInside)

            // Add any additional customization to the button (e.g., setting background color, text color, etc.)

            // Add the button to the stack view
            stackView.addArrangedSubview(rewardedButton)

            // Optionally, you can set constraints for the button if needed
        rewardedButton.translatesAutoresizingMaskIntoConstraints = false
        rewardedButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
    }

    func show() {
      guard let rewardedAd = rewardedAd else {
        return print("Ad wasn't ready.")
      }

      // The UIViewController parameter is an optional.
      rewardedAd.present(fromRootViewController: nil) {
        let reward = rewardedAd.adReward
        print("Reward received with currency \(reward.amount), amount \(reward.amount.doubleValue)")
        // TODO: Reward the user.
      }
    }

    @objc func buttonTappedRewarded() {
        print("rewarded tap")
        show()
    }
    @objc func buttonTapped() {
        // Action to be performed when the button is tapped
        print("Button tapped!")
        //
        // claimDailyTreasure()
        // Call to claim daily treasure
        OpenspaceAPI.shared.claimDailyTreasure(planet: "moon") { response, error in
            if let error = error {
                // Handle error
                print("Error claiming daily treasure: \(error)")
            } else {
                // Handle response
                print("Response from claim daily treasure: \(String(describing: response))")

                if response == "claimed" {
                    // Show a success message to the user on the main thread
                    DispatchQueue.main.async {
                        self.showSuccessMessage()
                    }
                } else {
                    // Show an error message or handle any other response status accordingly on the main thread
                    DispatchQueue.main.async {
                        self.showError()
                    }
                }

            }

        }

    }

    // ...
    func checkDailyTreasureAvailability() {
        // Call API to check daily treasure availability
        OpenspaceAPI.shared.checkDailyTreasureAvailability(planet: "moon") { response, error in
            if let error = error {
                print("Error checking daily treasure availability: \(error)")
                self.showError()
            } else {
                print("Response from check daily treasure availability: \(String(describing: response))")
                if response == "claimed" {
                    DispatchQueue.main.async {
                        self.showClaimedText()
                        self.hideTreasureButton()
                        self.showRewardedButton()
                        // Call loadAdAwait within a DispatchQueue.main.async block
                        Task {
                            await self.loadAdAwait()
                        }
                    }

                } else if response == "available" {
                    DispatchQueue.main.async {
                        self.showTreasureButton()
                    }
                }
            }
        }
    }
    var claimedLabel: UILabel?

    func showClaimedText() {
        // Check if claimedLabel has already been added
        guard claimedLabel == nil else {
            return
        }

        // Hide the button and show the text
        treasureButton.isHidden = true

        // Create the claimedLabel if it hasn't been created yet
        claimedLabel = UILabel()
        claimedLabel?.text = "Hourly treasure already claimed."
        claimedLabel?.textAlignment = .center
        claimedLabel?.textColor = .white

        // Add the claimedLabel to the stackView
        if let label = claimedLabel {
            stackView.addArrangedSubview(label)
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

    func showRewardedButton() {
        // Hide the text and show the button
        rewardedButton.isHidden = false
    }
    func hideRewardedButton() {
        // Hide the text and show the button
        rewardedButton.isHidden = true
    }

    override func viewDidAppear(_ animated: Bool) {
        // Call the function to check if the daily treasure is available for the user
         checkDailyTreasureAvailability()

    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.addButtonToStackView()
        self.addRewardedButtonToStackView()

        headerLabel.layer.masksToBounds = true
        headerLabel.layer.cornerRadius = 35.0
        headerLabel.layer.borderColor = UIColor.darkGray.cgColor
        headerLabel.layer.borderWidth = 3.0

        baseNode = SCNNode()
        let scene = SCNScene()
        self.title="Your ship '\(appDelegate.gameState.getShipName())' is on the Moon"

        let backgroundFilename = "moonbackgroundwithearth.jpg"
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
    func loadAdAwait() async {
        do {
            // Perform the loading of the rewarded ad asynchronously
            try await loadRewardedAd()
            // Handle successful loading
        } catch {
            // Handle any errors that occur during loading
            print("Error loading rewarded ad: \(error)")
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
            // print(child.animationKeys)

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

    func showSuccessMessage() {
        // Show a success message to the user (e.g., an alert or a label)
        let alertController = UIAlertController(title: "Congratulations!", message: "You claimed your hourly treasure.", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        checkDailyTreasureAvailability()

        present(alertController, animated: true, completion: nil)
    }

    func showError() {
        // Show an error message to the user (e.g., an alert or a label)
        let alertController = UIAlertController(title: "Error", message: "Unable to claim the daily treasure.", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }

}
