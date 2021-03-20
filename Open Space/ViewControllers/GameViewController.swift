//
//  GameViewController.swift
//  Open Space
//
//  Created by Andy Triboletti on 2/19/20.
//  Copyright © 2020 GreenRobot LLC. All rights reserved.
//

import UIKit
import QuartzCore
import SceneKit
import Alamofire
import AlamofireImage

import PopupDialog
import SCLAlertView
import DynamicBlurView

class GameViewController: UIViewController {
    var baseNode:SCNNode!
    var tempNode:SCNNode!
    var spaceShip:[SCNNode]!
    var tapGesture: UITapGestureRecognizer?
//    var iss: SCNNode?
    @IBOutlet var headerButton: UIButton!
    @IBOutlet var headerButton2: UIButton!
    
    @IBOutlet var headerButtonView: UIView!
    @IBOutlet var headerButton2View: UIView!
    
    @IBOutlet var spaceShipsButton: UIBarButtonItem!


    
    @IBOutlet var scnView: SCNView!
    @IBOutlet var headerLabel: UILabel!
    func moveToPlanet() {
        for node in spaceShip {
            if(node.name == "Spaceship") {
                let toPlace = SCNVector3(x: -500, y: 0, z: -200)
                let moveAction = SCNAction.move(to: toPlace, duration: TimeInterval(Float(5.0)))
                node.runAction(moveAction)
            }
        }
    }
    func moveAwayFromPlanet() {
        for node in spaceShip {
            if(node.name == "Spaceship") {
                let toPlace = SCNVector3(x: 500, y: 0, z: 200)
                let moveAction = SCNAction.move(to: toPlace, duration: TimeInterval(Float(5.0)))
                node.runAction(moveAction)
            }
        }
    }
    @IBAction func landButtonClicked() {
        if(appDelegate.gameState.locationState == LocationState.nearEarth) {
            print("land on earth")
            //var node = spaceShip.getTopParent(rootNode: spaceShip)
            moveToPlanet()
            
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                self.performSegue(withIdentifier: "landOnEarth", sender: self)
            }
        }
        else if(appDelegate.gameState.locationState == LocationState.nearISS) {
                print("land on iss")
                moveToPlanet()
                DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                    self.performSegue(withIdentifier: "dockWithStation", sender: self)
                }

        }
        else if(appDelegate.gameState.locationState == LocationState.nearMars) {
            print("land on mars")
            moveToPlanet()
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                self.performSegue(withIdentifier: "landOnMars", sender: self)
            }
        }
        
        
        
    }
    @IBAction func navigateToClicked() {
        print("where do you want to go")
        self.performSegue(withIdentifier: "selectDestination", sender: self)
        //self.performSegue(withIdentifier: "goToBase", sender: self)
        
        
    }
    @IBAction func showAlertButtonTapped(_ sender: UIButton) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let myAlert = storyboard.instantiateViewController(withIdentifier: "alert")
        myAlert.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        myAlert.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        self.present(myAlert, animated: true, completion: nil)
    }
    
    @objc func shipsAction(_ sender: UIBarButtonItem) {
        
        self.performSegue(withIdentifier: "selectShip", sender: sender)
        
    }
    
    
    override func viewDidDisappear(_ animated: Bool) {

//        baseNode?.enumerateChildNodes { (node, stop) in
//            node.removeFromParentNode()
//        }
//        baseNode?.removeFromParentNode()
//
//
        tempNode?.enumerateChildNodes { (node, stop) in
            node.removeFromParentNode()
        }
        tempNode?.removeFromParentNode()
//        scnView.scene?.rootNode.enumerateChildNodes { (node, stop) in
//                     node.removeFromParentNode()
//        }
        
        //scnView.scene?.rootNode.removeFromParentNode()

        if(self.tapGesture != nil) {
            scnView.removeGestureRecognizer(self.tapGesture!)
        }
        super.viewDidDisappear(animated)
    }
    func setupHeader() {
        self.headerButton2.setTitle("Navigate To...", for: .normal)

        self.tabBarController?.title = "'\(appDelegate.gameState.currentShipName)' Viewport"
        
        
        
    }
    override func viewWillAppear(_ animated: Bool) {
        scnView.scene?.rootNode.removeFromParentNode()

        let cameraNode = SCNNode()
        let camera = SCNCamera()
        
        self.baseNode = SCNNode()
        self.tempNode = SCNNode()
        let scene = SCNScene()
        
        super.viewDidLoad()
        
        setupHeader()
        
        
//        baseNode?.enumerateChildNodes { (node, stop) in
//            node.removeFromParentNode()
//        }
//        //baseNode?.removeFromParentNode()
//        scnView.scene?.rootNode.enumerateChildNodes { (node, stop) in
//                     node.removeFromParentNode()
//        }
        //scnView.scene?.rootNode.removeFromParentNode()

//        scnView?.removeGestureRecognizer(self.tapGesture)
        
        
        let backgroundFilename = "starry-sky-998641.jpg"
        let image = UIImage(named: backgroundFilename)!
        let rose = UIColor(red: 1.000, green: 0.314, blue: 0.314, alpha: 0.5)
        _ = UIColor.black
        let semi = rose.withAlphaComponent(0.1)
        _ = Utils.colorizeImage(image, with: semi)
        let size = CGSize(width: self.view.frame.width, height: self.view.frame.height)
        let aspectScaledToFitImage = image.af.imageAspectScaled(toFill: size)
        
        
        
        scene.background.contents = aspectScaledToFitImage
        
        scene.background.wrapS = SCNWrapMode.repeat
        scene.background.wrapT = SCNWrapMode.repeat
        spaceShip = addObject(name: appDelegate.gameState.currentShipModel, position: nil, scale: SCNVector3(5,5,5))
        
        
        for _ in 1...50 {
            addAsteroid()
        }
        
        //max asteroid
        
        _ = addObject(name: "a.dae", position: SCNVector3(5000,5000,5000), scale: SCNVector3(100,100,100))

        
        //let locationState:LocationState = LocationState.random()
        
        
        //animateAsteroid(baseNode: baseNode)
        
        
        
        
        
        
        
        // create and add a camera to the scene
        cameraNode.camera = camera
        //scene.rootNode.addChildNode(cameraNode)
        
                // place the camera
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 15)

        baseNode.addChildNode(cameraNode)

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
        
        refresh()

        scene.rootNode.addChildNode(baseNode)
        baseNode.addChildNode(tempNode)


        
        self.scnView!.scene = scene
        
        self.scnView!.allowsCameraControl = true
        
        // show statistics such as fps and timing information
        self.scnView!.showsStatistics = false
        self.scnView!.autoenablesDefaultLighting=true
        
        // configure the view
        self.scnView!.backgroundColor = UIColor.black
        
        self.tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        scnView.addGestureRecognizer(self.tapGesture!)
        
        

    }
    
    func refresh() {
        print("refresh")
        
        //        self.iss?.enumerateChildNodes { (node, stop) in
        //            node.removeFromParentNode()
        //        }
        //        self.iss?.removeFromParentNode()
        
        switch appDelegate.gameState.locationState {
        case .nearEarth:
            nearEarth()
            break
        case .nearISS:
            nearISS()
            break
        case .nearMoon:
            nearMoon()
            break
        case .nearMars:
            nearMars()
            break

        case .nearNothing:
            nearNothing()
            break
        }
    }
    func drawISS() {
        addTempObject(name: "ISS_stationary2.usdz", position:  SCNVector3(-500,0,-200), scale: 5)
        
    }
    func drawMars() {
        addTempObject(name: "mars.dae", position: SCNVector3(-500, 0, -200), scale: 5)
    }
    func drawMoon() {
        addTempObject(name: "moon.scn", position: SCNVector3(-500, 0, -200), scale: 5)
    }
    func drawEarth() {
        addTempObject(name: "earth.scn", position: SCNVector3(-500, 0, -200), scale: 5)
    }
    func showHeaderButtons() {
        self.headerButton.isHidden=false
        self.headerButton2.isHidden=false
        
        self.headerButtonView.isHidden=false
        self.headerButton2View.isHidden=false
    }
    
    func nearNothing() {
        self.headerLabel.text = "Your ship '\(appDelegate.gameState.currentShipName)' is stopped in space."
        
        self.headerButton.isHidden=true
        self.headerButtonView.isHidden=true
        
        self.headerButton2.isHidden=false
        self.headerButton2View.isHidden=false
    }
    func nearISS() {
        self.headerButton.setTitle("Dock With Station", for: .normal)
        self.headerLabel.text = "Your ship '\(appDelegate.gameState.currentShipName)' is near the International Space Station. It is stopped."
        
        showHeaderButtons()
        drawISS()
        travel()

    }
    
    func nearEarth() {
        
        self.headerButton.setTitle("Land on Earth", for: .normal)
        //self.headerButton2.setTitle("Navigate To...", for: .normal)
        self.headerLabel.text = "Your ship '\(appDelegate.gameState.currentShipName)' is near Earth. It is stopped."
        
        showHeaderButtons()
        
        drawEarth()
        travel()
        
    }
    
    func travel() {
        
        if(appDelegate.gameState.goingToLocationState != nil) {

            //self.view.makeToast("This is a piece of toast", style: style)
            var travelingTo:String = ""
            if(appDelegate.gameState.goingToLocationState == LocationState.nearEarth) {
                travelingTo = "Earth"
            }
            else if(appDelegate.gameState.goingToLocationState == LocationState.nearISS) {
                travelingTo = "the ISS"
            }
            else if(appDelegate.gameState.goingToLocationState == LocationState.nearMoon) {
                travelingTo = "the Moon"
            }
            else if(appDelegate.gameState.goingToLocationState == LocationState.nearMars) {
                travelingTo = "Mars"
            }
            
            self.showToast(message: "Traveling to \(travelingTo)", font: .systemFont(ofSize: 24.0))

            //move ship
            moveAwayFromPlanet()
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                self.performSegue(withIdentifier: "travel", sender: self)
            }
            //after 3 seconds go to travel screen then go to goingToLocationState

        }
    }
    func nearMoon() {
        
        self.headerButton.setTitle("Land on the Moon", for: .normal)
        self.headerLabel.text = "Your ship '\(appDelegate.gameState.currentShipName)' is near the Moon. It is stopped."
                
        self.headerButton.isHidden=true
        self.headerButton2.isHidden=false
        
        self.headerButtonView.isHidden=true
        self.headerButton2View.isHidden=false
        
        drawMoon()
        travel()

    }
    
    func nearMars() {
        
        self.headerButton.setTitle("Land on Mars", for: .normal)
        self.headerLabel.text = "Your ship '\(appDelegate.gameState.currentShipName)' is near Mars. It is stopped."
        
        showHeaderButtons()
        
        drawMars()
        travel()

    }
    
    
    
    func animateAsteroid(baseNode: SCNNode) {
        let shipScenec = SCNScene(named: "a.dae")!
        
        let shipSceneChildNodesc = shipScenec.rootNode.childNodes
        for childNode in shipSceneChildNodesc {
            let initialPositionX = 0
            let initialPositionY = 200
            childNode.position = SCNVector3(initialPositionX, initialPositionY, 200)
            childNode.scale = SCNVector3(100, 50, 50)
            
            baseNode.addChildNode(childNode)
            
            let howLongToTravel = 5000
            let toPlace = SCNVector3(x: Float(initialPositionX + howLongToTravel), y: Float(initialPositionY + howLongToTravel), z: Float(howLongToTravel))
            var moveAction = SCNAction.move(to: toPlace, duration: TimeInterval(Float(200.0)))
            childNode.runAction(moveAction)
            
            let path1 = UIBezierPath()
            path1.move(to: CGPoint(x: 1000,y: 1000))
            moveAction = SCNAction.moveAlong(path: path1)
            
            SCNTransaction.begin()
            SCNTransaction.animationDuration = 0
            
            moveAction = SCNAction.moveAlong(path: path1)
            //let repeatAction = SCNAction.repeatForever(moveAction)
            
            
            SCNTransaction.commit()
            
            
            
        }
        
    }
    @objc
    func handleTap(_ gestureRecognize: UIGestureRecognizer) {
        // retrieve the SCNView
        let scnView = self.scnView!//self.view as! SCNView
        
        // check what nodes are tapped
        let p = gestureRecognize.location(in: scnView)
        //let hitResults = scnView.hitTest(p, options: [])
        let hitResults = scnView.hitTest(p, options: [SCNHitTestOption.searchMode: SCNHitTestSearchMode.all.rawValue])
        //SCNHitTestSearchModeAll
        // check that we clicked on at least one object
        //print(hitResults.count)
        if hitResults.count > 0 {
            // retrieved the first clicked object
            let result:SCNHitTestResult = hitResults[0]
            
            var node = result.node
            node = node.getTopParent(rootNode: baseNode)
            
            // get its material
            highlightNode(node: node, color: .red)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.highlightNode(node: node, color: .black)
                
            }
            
            
        }
    }
    func highlightNode(node: SCNNode, color: UIColor) {
        let material = node.geometry?.firstMaterial
        // highlight it
        
        SCNTransaction.begin()
        SCNTransaction.animationDuration = 0.0
        
        if(node.geometry != nil) {
            highlightMaterial(material: material!, color: color)
        }
        else {
            highlightMaterialChildren(node: node, color: color)
        }
        
        SCNTransaction.commit()
    }
    func highlightMaterialChildren(node: SCNNode, color: UIColor) {
        for childNode in node.childNodes {
            //print(childNode)
            // get its material
            let material = childNode.geometry?.firstMaterial
            // highlight it
            if(childNode.geometry != nil) {
                highlightMaterial(material: material!, color: color)
            }
            else {
                highlightMaterialChildren(node: childNode, color: color)
            }
            
        }
    }
    func highlightMaterial(material: SCNMaterial, color: UIColor) {
        material.emission.contents = color
        
    }
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }
    
    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        
        let widthRatio  = targetSize.width  / image.size.width
        let heightRatio = targetSize.height / image.size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
    func addAsteroid(position: SCNVector3? = nil, scale: SCNVector3? = nil) {
        
        var myScale = scale
        if(scale == nil) {
            let minValue = 20
            let maxValue = 100
            let xScale = Int.random(in: minValue ..< maxValue)
            let yScale = Int.random(in: minValue ..< maxValue)
            let zScale = Int.random(in: minValue ..< maxValue)
            myScale = SCNVector3(xScale, yScale, zScale)
        }
        
        var myPosition = position
        if(position == nil) {
            
            //not too close, not too far
            let minValue = 300
            let maxValue = 5000
            
            
            var xVal = Int.random(in: minValue ..< maxValue)
            var yVal = Int.random(in: minValue ..< maxValue)
            var zVal = Int.random(in: minValue ..< maxValue)
            //randomly do positive or negative
            if arc4random_uniform(2) == 0 {
                xVal = xVal * -1
            }
            if arc4random_uniform(2) == 0 {
                yVal = yVal * -1
            }
            if arc4random_uniform(2) == 0 {
                zVal = zVal * -1
            }
            
            myPosition = SCNVector3(xVal, yVal, zVal)
        }
        _ = addObject(name: "a.dae", position: myPosition, scale: myScale)
    }
    func addObject(name: String, position: SCNVector3?, scale: Float) -> [SCNNode] {
        return addObject(name: name, position: position, scale: SCNVector3(x: scale, y: scale, z: scale))
    }
    func addTempObject(name: String, position: SCNVector3?, scale: Float) {
        addTempObject(name: name, position: position, scale: SCNVector3(x: scale, y: scale, z: scale))
    }
    func addObject(name: String, position: SCNVector3?, scale: SCNVector3?) -> [SCNNode] {
        let shipScene = SCNScene(named: name)!
        
        let shipSceneChildNodes = shipScene.rootNode.childNodes
        for childNode in shipSceneChildNodes {
            baseNode.addChildNode(childNode)
            if(position != nil) {
                childNode.position = position!
            }
            if(scale != nil) {
                childNode.scale = scale!
            }
        }
        return shipSceneChildNodes
    }
    func addTempObject(name: String, position: SCNVector3?, scale: SCNVector3?) {
        let shipScene = SCNScene(named: name)!
        
        let shipSceneChildNodes = shipScene.rootNode.childNodes
        for childNode in shipSceneChildNodes {
            tempNode.addChildNode(childNode)
            if(position != nil) {
                childNode.position = position!
            }
            if(scale != nil) {
                childNode.scale = scale!
            }
        }
        //return shipScene.rootNode
    }
}

extension UIViewController {

func showToast(message : String, font: UIFont) {

    let toastLabel = UILabel(frame: CGRect(x: self.view.frame.size.width/2 - 200, y: self.view.frame.size.height-200, width: 400, height: 100))
    toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
    toastLabel.textColor = UIColor.white
    toastLabel.font = font
    toastLabel.textAlignment = .center;
    toastLabel.text = message
    toastLabel.alpha = 1.0
    toastLabel.layer.cornerRadius = 10;
    toastLabel.clipsToBounds  =  true
    self.view.addSubview(toastLabel)
    UIView.animate(withDuration: 6.0, delay: 0.1, options: .curveEaseOut, animations: {
         toastLabel.alpha = 0.0
    }, completion: {(isCompleted) in
        toastLabel.removeFromSuperview()
    })
} }
