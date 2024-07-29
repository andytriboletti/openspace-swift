//
//  GameViewController+UIActions.swift
//  Open Space
//
//  Created by Andrew Triboletti on 7/1/24.
//  Copyright © 2024 GreenRobot LLC. All rights reserved.
//
import UIKit
import Defaults
import SceneKit
extension GameViewController {
    func presentUsernameEntryView(completion: @escaping (String) -> Void) {
        DispatchQueue.main.async {
            let alertController = UIAlertController(title: "Enter Username", message: nil, preferredStyle: .alert)
            alertController.addTextField { textField in
                textField.placeholder = "Username"
            }

            let submitAction = UIAlertAction(title: "Submit", style: .default) { _ in
                if let username = alertController.textFields?.first?.text {
                    self.submitUsername(username: username) { submittedUsername, errorMessage in
                        if let errorMessage = errorMessage {
                            DispatchQueue.main.async {
                                //print(errorMessage)
                                let errorAlert = UIAlertController(title: "Error", message: "Please select a new username. The username '\(username)' is already taken.", preferredStyle: .alert)
                                errorAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
                                    self.presentUsernameEntryView(completion: completion)
                                }))
                                self.present(errorAlert, animated: true, completion: nil)
                            }
                        } else if let submittedUsername = submittedUsername {
                            //print("Username submitted successfully")
                            completion(submittedUsername)
                        }
                    }
                }
            }

            alertController.addAction(submitAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }

    @IBAction func landButtonClicked() {
        if appDelegate.gameState.locationState == LocationState.nearEarth {
            //print("land on earth")
            Utils.shared.saveLocation(location: "onEarth", usesEnergy: "0")

            moveToPlanet()

            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                self.performSegue(withIdentifier: "landOnEarth", sender: self)
            }
        } else if appDelegate.gameState.locationState == LocationState.nearISS {
            //print("land on iss")
            moveToPlanet()
            Utils.shared.saveLocation(location: "onISS", usesEnergy: "0")

            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                self.performSegue(withIdentifier: "dockWithStation", sender: self)
            }

        } else if appDelegate.gameState.locationState == LocationState.nearMoon {
            //print("land on the moon")
            moveToPlanet()
            Utils.shared.saveLocation(location: "onMoon", usesEnergy: "0")

            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                self.performSegue(withIdentifier: "landOnMoon", sender: self)
            }
        } else if appDelegate.gameState.locationState == LocationState.nearMars {
            //print("land on mars")
            moveToPlanet()
            Utils.shared.saveLocation(location: "onMars", usesEnergy: "0")

            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                self.performSegue(withIdentifier: "landOnMars", sender: self)
            }
        }
    }

    @IBAction func navigateToClicked() {
        //print("where do you want to go")
        self.performSegue(withIdentifier: "selectDestination", sender: self)
    }

    @IBAction func showAlertButtonTapped(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let myAlert = storyboard.instantiateViewController(withIdentifier: "alert")
        myAlert.modalPresentationStyle = .overCurrentContext
        myAlert.modalTransitionStyle = .crossDissolve
        self.present(myAlert, animated: true, completion: nil)
    }

    @objc func shipsAction(_ sender: UIBarButtonItem) {
        self.performSegue(withIdentifier: "selectShip", sender: sender)
    }

    @objc func handleTap(_ gestureRecognize: UIGestureRecognizer) {
        let scnView = self.scnView!
        let gestureR = gestureRecognize.location(in: scnView)
        let hitResults = scnView.hitTest(gestureR, options: [SCNHitTestOption.searchMode: SCNHitTestSearchMode.all.rawValue])
        if hitResults.count > 0 {
            let result: SCNHitTestResult = hitResults[0]
            var node = result.node
            node = node.getTopParent(rootNode: baseNode)
            highlightNode(node: node, color: .red)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.highlightNode(node: node, color: .black)
            }
        }
    }

    func highlightNode(node: SCNNode, color: UIColor) {
        let material = node.geometry?.firstMaterial
        SCNTransaction.begin()
        SCNTransaction.animationDuration = 0.0
        if node.geometry != nil {
            highlightMaterial(material: material!, color: color)
        } else {
            highlightMaterialChildren(node: node, color: color)
        }
        SCNTransaction.commit()
    }

    func highlightMaterialChildren(node: SCNNode, color: UIColor) {
        for childNode in node.childNodes {
            let material = childNode.geometry?.firstMaterial
            if childNode.geometry != nil {
                highlightMaterial(material: material!, color: color)
            } else {
                highlightMaterialChildren(node: childNode, color: color)
            }
        }
    }

    func highlightMaterial(material: SCNMaterial, color: UIColor) {
        material.emission.contents = color
    }

    func setupHeader() {
        self.headerButton2.setTitle("Navigate To...", for: .normal)
        self.tabBarController?.title = "'\(appDelegate.gameState.getShipName())' Viewport"
    }

    func showHeaderButtons() {
        self.headerButton.isHidden = false
        self.headerButton2.isHidden = false
        self.headerButtonView.isHidden = false
        self.headerButton2View.isHidden = false
    }

    func hideHeaderButtons() {
        self.headerButton.isHidden = true
        self.headerButton2.isHidden = true
        self.headerButtonView.isHidden = true
        self.headerButton2View.isHidden = true
    }

    func askForUserName() {
        DispatchQueue.main.async {
            let myUsername = Defaults[.username]
            //print("my username:")
            //print(myUsername)
            if myUsername == "" {
                self.presentUsernameEntryView { enteredUsername in
                    self.username = enteredUsername
                }
            }
        }
    }
}
