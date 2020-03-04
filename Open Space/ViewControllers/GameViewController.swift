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
import MaterialComponents.MaterialButtons
import MaterialComponents.MaterialButtons_Theming
import PopupDialog
import SCLAlertView
import DynamicBlurView

class GameViewController: UIViewController {
    
    
    @IBOutlet var headerButton: MDCButton!
    @IBOutlet var headerButton2: MDCButton!
    
    @IBOutlet var headerButtonView: UIView!
    @IBOutlet var headerButton2View: UIView!
    
    @IBOutlet var spaceShipsButton: UIBarButtonItem!
    
    var baseNode:SCNNode!
    
    @IBOutlet var scnView: SCNView!
    @IBOutlet var headerLabel: UILabel!
    
    @IBAction func landButtonClicked() {
        print("land on mars")
        self.performSegue(withIdentifier: "landOnMars", sender: self)
        
        
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
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
    }
    
    func refresh() {
        print("refresh")
        
        switch appDelegate.gameState.locationState {
        case .nearEarth:
            nearEarth()
        case .nearISS:
            nearISS()
        case .nearNothing:
            nearNothing()
        case .nearMars:
            nearMars()
        case .nearMoon:
            nearISS()
        @unknown default:
            nearNothing()
        }
    }
    func drawISS() {
        addObject(name: "ISS_stationary2.usdz", position:  SCNVector3(-500,0,-200), scale: 5)
        
    }
    func drawMars() {
        addObject(name: "mars.dae", position: SCNVector3(-500, 0, -200), scale: 5)
    }
    func drawEarth() {
        addObject(name: "earth.scn", position: SCNVector3(-500, 0, -200), scale: 5)
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
    }
    
    func nearEarth() {
        
        self.headerButton.setTitle("Land on Earth", for: .normal)
        self.headerLabel.text = "Your ship '\(appDelegate.gameState.currentShipName)' is near Earth. It is stopped."
        
        showHeaderButtons()
        
        drawEarth()
        
    }
    
    func nearMars() {
        
        self.headerButton.setTitle("Land on Mars", for: .normal)
        self.headerLabel.text = "Your ship '\(appDelegate.gameState.currentShipName)' is near Mars. It is stopped."
        
        showHeaderButtons()
        
        drawMars()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        self.tabBarController?.title = "'\(appDelegate.gameState.currentShipName)' Viewport"
        
        let shipButton = UIBarButtonItem(title: "Ships", style: .done, target: self, action: #selector(shipsAction(_:)))
        self.tabBarController!.navigationItem.leftBarButtonItem = shipButton
        
        self.headerButton.applyTextTheme(withScheme: appDelegate.containerScheme)
        self.headerButton.applyContainedTheme(withScheme: appDelegate.containerScheme)
        
        self.headerButton2.applyTextTheme(withScheme: appDelegate.containerScheme)
        self.headerButton2.applyContainedTheme(withScheme: appDelegate.containerScheme)
        
        //node stuff
        baseNode = SCNNode()
        
        let scene = SCNScene()
        let backgroundFilename = "iss006e48523orig.jpg"
        let image = UIImage(named: backgroundFilename)!
        let rose = UIColor(red: 1.000, green: 0.314, blue: 0.314, alpha: 1.0)
        let purple = UIColor.black
        let semi = rose.withAlphaComponent(0.5)
        let colorizedImage = Utils.colorizeImage(image, with: semi)
        let size = CGSize(width: self.view.frame.width, height: self.view.frame.height)
        let aspectScaledToFitImage = colorizedImage!.af_imageAspectScaled(toFill: size)
        
        
        
        scene.background.contents = aspectScaledToFitImage
        
        scene.background.wrapS = SCNWrapMode.repeat
        scene.background.wrapT = SCNWrapMode.repeat
        addObject(name: appDelegate.gameState.currentShipModel, position: nil, scale: SCNVector3(10.0,10.0,10.0))
        
        addObject(name: appDelegate.gameState.closestOtherPlayerShipModel, position: SCNVector3(00,000,500), scale: nil)
        
        
        
        addObject(name: "instantmeshstation2.scn", position: SCNVector3(-4000, -400, -4000), scale: 1)
        
        addObject(name: "sunlowres.scn", position: SCNVector3(100, 100, -500), scale: 0.5)
        
        
        //static asteroid
        //      addObject(name: "a.dae", position: SCNVector3(100,100,100), scale: SCNVector3(30,30,30))
        
        //addObject(name: "starcrumpled.dae", position: SCNVector3(-1000, 300, 10), scale: SCNVector3(2,2,2))
        
        //Sun_1_1391000.usdz
        //addObject(name: "Sun_1_1391000.usdz", position: SCNVector3(-5000, 5000, 5000), scale: SCNVector3(0.2,0.2,0.2))
        addObject(name: "sunlowres.scn", position: SCNVector3(-5000, 5000, 5000), scale: 10)
        
        addObject(name: "b.dae", position: SCNVector3(400,-400,400), scale: SCNVector3(30,30,30))
        //instantmeshstation2.dae
        
        for _ in 1...50 {
            addAsteroid()
        }
        
        
        //let locationState:LocationState = LocationState.random()
        
        
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
        
        
        scene.rootNode.addChildNode(baseNode)
        
        // create and add a camera to the scene
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        scene.rootNode.addChildNode(cameraNode)
        
        // place the camera
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 15)
        
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
        
        
        let scnView = self.scnView!
        
        scnView.scene = scene
        
        scnView.allowsCameraControl = true
        
        // show statistics such as fps and timing information
        scnView.showsStatistics = false
        scnView.autoenablesDefaultLighting=true
        
        // configure the view
        scnView.backgroundColor = UIColor.black
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        scnView.addGestureRecognizer(tapGesture)
        
        refresh()
        
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
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
        addObject(name: "a.dae", position: myPosition, scale: myScale)
    }
    func addObject(name: String, position: SCNVector3?, scale: Float) {
        addObject(name: name, position: position, scale: SCNVector3(x: scale, y: scale, z: scale))
    }
    func addObject(name: String, position: SCNVector3?, scale: SCNVector3?) {
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
        
    }
}

