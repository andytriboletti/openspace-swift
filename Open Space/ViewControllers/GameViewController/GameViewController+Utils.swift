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
        let widthRatio = targetSize.width / image.size.width
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
    func setCurrencyAndEnergyLabels() {
        let currencyFormatter = NumberFormatter()
        currencyFormatter.numberStyle = .currency
        currencyFormatter.locale = Locale.current // Use the current locale for currency formatting

        if let formattedCurrency = currencyFormatter.string(from: NSNumber(value: Defaults[.currency])) {
            self.currencyLabel.text = "Cash: \(formattedCurrency)"
        } else {
            self.currencyLabel.text = "Cash: \(Defaults[.currency])"
        }

        self.energyLabel.text = "Energy: \(Defaults[.currentEnergy]) out of \(Defaults[.totalEnergy])"
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
            case .nearYourSpaceStation: // Updated this case
                self.nearYourSpaceStation()
            case .onEarth:
                self.onEarth()
            case .onISS:
                self.onISS()
            case .onMoon:
                self.onMoon();
            case .onMars:
                self.onMars();
            case .nearNothing:
                self.nearNothing()
            }
        }
    }
    func onEarth() {
        self.performSegue(withIdentifier: "landOnEarth", sender: self)
    }
    func onISS() {
        self.performSegue(withIdentifier: "dockWithStation", sender: self)
    }
    func onMoon() {
        self.performSegue(withIdentifier: "landOnMoon", sender: self)
    }
    func onMars() {
        self.performSegue(withIdentifier: "landOnMars", sender: self)
    }

    func drawYourSpaceStation() {
        guard let stationMeshLocation = Defaults[.stationMeshLocation] as? String else {
            //print("Station mesh location not set")
            return
        }
        print(stationMeshLocation)
        // if stationMeshLocation.lowercased().hasSuffix(".usdz") {
            downloadAndDisplayUSDZ(from: stationMeshLocation)
       // } else {
            addTempObject(name: stationMeshLocation, position: SCNVector3(-500, 0, -200), scale: 30) // Adjusted scale to 20
       // }
        // setupBackground()
    }

    func downloadAndDisplayUSDZ(from urlString: String) {
        guard let url = URL(string: urlString) else {
            //print("Invalid URL")
            return
        }
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let destinationUrl = documentsDirectory.appendingPathComponent("station.usdz")

        // Remove the existing file if it exists
        if FileManager.default.fileExists(atPath: destinationUrl.path) {
            do {
                try FileManager.default.removeItem(at: destinationUrl)
                //print("Existing file removed")
            } catch {
                //print("Failed to remove existing file: \(error.localizedDescription)")
                return
            }
        }

        URLSession.shared.downloadTask(with: url) { (location, _, error) in
            guard let location = location, error == nil else {
                //print("Download error: \(error?.localizedDescription ?? "Unknown error")")
                return
            }

            do {
                try FileManager.default.moveItem(at: location, to: destinationUrl)
                //print("File downloaded to \(destinationUrl.path)")

                self.displayUSDZ(at: destinationUrl)
            } catch {
                //print("File move error: \(error.localizedDescription)")
            }
        }.resume()
    }
    func displayUSDZ(at fileURL: URL) {
        do {
            let scene = try SCNScene(url: fileURL, options: nil)
            let stationNode = scene.rootNode.clone()
            stationNode.position = SCNVector3(-500, 0, -200)
            // stationNode.scale = SCNVector3(20, 20, 20) // Adjusted scale to 20
            stationNode.scale = SCNVector3(60, 60, 60)
            // Add stationNode to the scene
            self.scnView.scene?.rootNode.addChildNode(stationNode)

            // Enable animations
            enableAnimations(on: stationNode)

            //print("Successfully loaded .usdz file with animations")
        } catch {
            //print("Failed to load the .usdz file: \(error.localizedDescription)")
        }
    }

    func enableAnimations(on node: SCNNode) {
        node.enumerateChildNodes { (child, _) in
            for key in child.animationKeys {
                if let animation = child.animation(forKey: key) {
                    child.addAnimation(animation, forKey: key)
                }
            }
        }
        for key in node.animationKeys {
            if let animation = node.animation(forKey: key) {
                node.addAnimation(animation, forKey: key)
            }
        }
    }

//    func setupBackground() {
//        let background = SCNMaterial()
//        background.diffuse.contents = UIImage(named: "stars.jpg") // Ensure you have a stars.jpg file in your project
//        background.isDoubleSided = true
//        let sphere = SCNSphere(radius: 1000)
//        sphere.segmentCount = 200
//        sphere.firstMaterial = background
//        let sphereNode = SCNNode(geometry: sphere)
//        sphereNode.position = SCNVector3(0, 0, 0)
//        self.scnView.scene?.rootNode.addChildNode(sphereNode)
//    }

    func checkFilePermissions(at path: String) {
        let fileManager = FileManager.default
        if fileManager.isReadableFile(atPath: path) {
            //print("File is readable")
        } else {
            //print("File is not readable")
        }

        if fileManager.isWritableFile(atPath: path) {
            //print("File is writable")
        } else {
            //print("File is not writable")
        }

        if fileManager.isExecutableFile(atPath: path) {
            //print("File is executable")
        } else {
            //print("File is not executable")
        }

        if fileManager.isDeletableFile(atPath: path) {
            //print("File is deletable")
        } else {
            //print("File is not deletable")
        }
    }

    func nearYourSpaceStation() {
        self.headerButton.setTitle("Dock With Space Station", for: .normal)
        let traveling = Defaults[.traveling]
        if traveling == "true" {
            travel()
            Defaults[.traveling] = "false"
            hideHeaderButtons()
            self.headerLabel.text = ""
        } else {
            drawYourSpaceStation()
            showHeaderButtons()
            self.headerLabel.text = "Your ship '\(appDelegate.gameState.getShipName())' is near your space station. It is stopped."
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
        if let goingToLocationState = appDelegate.gameState.goingToLocationState {
            var travelingTo: String = ""
            switch goingToLocationState {
            case .nearEarth:
                travelingTo = "Earth"
            case .nearISS:
                travelingTo = "the ISS"
            case .nearMoon:
                travelingTo = "the Moon"
            case .nearMars:
                travelingTo = "Mars"
            case .nearYourSpaceStation: // Updated this case
                travelingTo = "your Space Station"
            default:
                break
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
        addTempObject(name: "ISS_stationary2.usdz", position: SCNVector3(-500, 0, -200), scale: 20) // Adjusted scale to 20
        // setupBackground()
    }

    func drawMars() {
        addTempObject(name: "mars.scn", position: SCNVector3(-500, 0, -200), scale: 5)
    }

    func drawMoon() {
        addTempObject(name: "moon.scn", position: SCNVector3(-500, 0, -200), scale: 5)
    }

    func drawEarth() {
        addTempObject(name: "earth.scn", position: SCNVector3(-500, 0, -200), scale: 5)
        // setupBackground()
    }

    func addTempObject(name: String, position: SCNVector3, scale: Float) {
        let scene = try? SCNScene(named: name)
        let node = SCNNode()

        scene?.rootNode.childNodes.forEach { childNode in
            node.addChildNode(childNode)
        }

        node.position = position
        node.scale = SCNVector3(scale, scale, scale)
        self.scnView.scene?.rootNode.addChildNode(node)
    }
}
