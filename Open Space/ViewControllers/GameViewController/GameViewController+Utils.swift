//
//  GameViewController+Utils.swift
//  Open Space
//
//  Created by Andrew Triboletti on 7/1/24.
//  Copyright © 2024 GreenRobot LLC. All rights reserved.
//
import UIKit
import SceneKit
import Defaults

extension GameViewController {
    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        let widthRatio  = targetSize.width  / image.size.width
        let heightRatio = targetSize.height / image.size.height
        var newSize: CGSize
        if widthRatio > heightRatio {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio, height: size.height * widthRatio)
        }
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }


    func setNearFromLocationState() {
        DispatchQueue.main.async {
            switch self.appDelegate.gameState.locationState {
            case .nearEarth:
                self.nearEarth()
            case .nearISS:
                self.nearISS()
            case .nearMoon:
                self.nearMoon()
            case .nearMars:
                self.nearMars()
            case .nearNothing:
                self.nearNothing()
            }
        }
    }

    func nearNothing() {
        self.headerLabel.text = "Your ship '\(appDelegate.gameState.getShipName())' is stopped in space."
        self.headerButton.isHidden = true
        self.headerButtonView.isHidden = true
        self.headerButton2.isHidden = false
        self.headerButton2View.isHidden = false
    }

    func nearISS() {
        self.headerButton.setTitle("Dock With Station", for: .normal)

        let traveling = Defaults[.traveling]

        if traveling == "true" {
            travel()
            Defaults[.traveling] = "false"
            hideHeaderButtons()
            self.headerLabel.text = ""
        } else {
            drawISS()
            showHeaderButtons()
            self.headerLabel.text = "Your ship '\(appDelegate.gameState.getShipName())' is near the International Space Station. It is stopped."
        }
    }

    func nearEarth() {
        self.headerButton.setTitle("Land on Earth", for: .normal)
        let traveling = Defaults[.traveling]

        if traveling == "true" {
            Defaults[.traveling] = "false"
            hideHeaderButtons()
            self.headerLabel.text = ""
            travel()
        } else {
            drawEarth()
            showHeaderButtons()
            self.headerLabel.text = "Your ship '\(appDelegate.gameState.getShipName())' is near Earth. It is stopped."
        }
    }

    func travel() {
        if appDelegate.gameState.goingToLocationState != nil {
            var travelingTo: String = ""
            if appDelegate.gameState.goingToLocationState == LocationState.nearEarth {
                travelingTo = "Earth"
            } else if appDelegate.gameState.goingToLocationState == LocationState.nearISS {
                travelingTo = "the ISS"
            } else if appDelegate.gameState.goingToLocationState == LocationState.nearMoon {
                travelingTo = "the Moon"
            } else if appDelegate.gameState.goingToLocationState == LocationState.nearMars {
                travelingTo = "Mars"
            }

            self.showToast(message: "Traveling to \(travelingTo)", font: .systemFont(ofSize: 24.0))

            moveAwayFromPlanet()
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                self.performSegue(withIdentifier: "travel", sender: self)
            }
        }
    }

    func nearMoon() {
        self.headerButton.setTitle("Land on the Moon", for: .normal)
        let traveling = Defaults[.traveling]

        if traveling == "true" {
            travel()
            Defaults[.traveling] = "false"
            hideHeaderButtons()
            self.headerLabel.text = ""
        } else {
            drawMoon()
            showHeaderButtons()
            self.headerLabel.text = "Your ship '\(appDelegate.gameState.getShipName())' is near the Moon. It is stopped."
        }
    }

    func nearMars() {
        self.headerButton.setTitle("Land on Mars", for: .normal)
        showHeaderButtons()
        let traveling = Defaults[.traveling]

        if traveling == "true" {
            travel()
            Defaults[.traveling] = "false"
            hideHeaderButtons()
            self.headerLabel.text = ""
        } else {
            drawMars()
            showHeaderButtons()
            self.headerLabel.text = "Your ship '\(appDelegate.gameState.getShipName())' is near Mars. It is stopped."
        }
    }

    func drawISS() {
        addTempObject(name: "ISS_stationary2.usdz", position: SCNVector3(-500, 0, -200), scale: 5)
    }

    func drawMars() {
        addTempObject(name: "mars.scn", position: SCNVector3(-500, 0, -200), scale: 5)
    }

    func drawMoon() {
        addTempObject(name: "moon.scn", position: SCNVector3(-500, 0, -200), scale: 5)
    }

    func drawEarth() {
        addTempObject(name: "earth.scn", position: SCNVector3(-500, 0, -200), scale: 5)
    }
}
