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
    override func viewDidLoad() {
        super.viewDidLoad()
        baseNode = SCNNode()

        let shipButton = UIBarButtonItem(title: "Ships", style: .done, target: self, action: #selector(shipsAction(_:)))
        self.tabBarController!.navigationItem.leftBarButtonItem = shipButton
        
        let nearPlanet = true
        
        if(nearPlanet) {
            
            self.headerLabel.text = "Your ship '\(appDelegate.gameState.currentShipName)' is near Mars. It is stopped."

            self.headerButton.isHidden=false
            self.headerButton2.isHidden=false
            
            self.headerButtonView.isHidden=false
            self.headerButton2View.isHidden=false
            
            
        }
        else {
            self.headerLabel.text = "It is stopped."
            
            self.headerButton.isHidden=true
            self.headerButtonView.isHidden=true
            
            self.headerButton2.isHidden=false
            self.headerButton2View.isHidden=false
            
        }
        self.headerButton.applyTextTheme(withScheme: appDelegate.containerScheme)
        self.headerButton.applyContainedTheme(withScheme: appDelegate.containerScheme)
        
        self.headerButton2.applyTextTheme(withScheme: appDelegate.containerScheme)
        self.headerButton2.applyContainedTheme(withScheme: appDelegate.containerScheme)
        
        //self.tabBarController!.title = "Ship Abracadabra Stopped in Deep Space"
        let scene = SCNScene()
        //imageView.contentMode = .scaleAspectFit
        //let backgroundFilename = "PIA12348orig.jpg"
        //let backgroundFilename = "PIA13005orig.jpg"
        let backgroundFilename = "PIA15415orig.jpg"
        let image = UIImage(named: backgroundFilename)!
        
        let size = CGSize(width: self.view.frame.width, height: self.view.frame.height)
        let aspectScaledToFitImage = image.af_imageAspectScaled(toFill: size)
        
        self.tabBarController?.title = "'\(appDelegate.gameState.currentShipName)' Viewport"
        
        //image!.size = self.view.frame.size
        
        scene.background.contents = aspectScaledToFitImage
        //scene.background.contentsTransform = SCNMatrix4MakeScale(Float(self.view.frame.width), Float(self.view.frame.height), 1)
        
        scene.background.wrapS = SCNWrapMode.repeat
        scene.background.wrapT = SCNWrapMode.repeat
        
        
        //spaceship facing forward is y = 0 is center
        addObject(name: appDelegate.gameState.currentShipModel, position: nil, scale: SCNVector3(10.0,10.0,10.0))
        
        addObject(name: appDelegate.gameState.closestOtherPlayerShipModel, position: SCNVector3(00,000,500), scale: nil)
        
        addObject(name: "mars.dae", position: SCNVector3(-500, 0, -200), scale: 6)
        
        for _ in 1...50 {
            addAsteroid()
        }
        
         addObject(name: "instantmeshstation2.scn", position: SCNVector3(-400, -800, -400), scale: SCNVector3(5,5,5))
          
        
         
        //static asteroid
        //      addObject(name: "a.dae", position: SCNVector3(100,100,100), scale: SCNVector3(30,30,30))
        
        //addObject(name: "starcrumpled.dae", position: SCNVector3(-1000, 300, 10), scale: SCNVector3(2,2,2))

        //Sun_1_1391000.usdz
        //addObject(name: "Sun_1_1391000.usdz", position: SCNVector3(-5000, 5000, 5000), scale: SCNVector3(0.2,0.2,0.2))
        addObject(name: "sunlowres.scn", position: SCNVector3(-5000, 5000, 5000), scale: SCNVector3(1,1,1))

        addObject(name: "b.dae", position: SCNVector3(400,-400,400), scale: SCNVector3(30,30,30))
        //instantmeshstation2.dae
        
 
        
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
        
        //scene.rootNode.addChildNode(scene.rootNode.childNodes)

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
        
        // retrieve the ship node
        //let ship = scene.rootNode.childNode(withName: "ship", recursively: true)!
        
        // animate the 3d object
        //ship.runAction(SCNAction.repeatForever(SCNAction.rotateBy(x: 0, y: 2, z: 0, duration: 1)))
        
        // retrieve the SCNView
        let scnView = self.scnView!
        //self.view as! SCNView
        
        // set the scene to the view
        scnView.scene = scene
        
        // allows the user to manipulate the camera
        scnView.allowsCameraControl = true
        
        // show statistics such as fps and timing information
        scnView.showsStatistics = false
        scnView.autoenablesDefaultLighting=true

        // configure the view
        scnView.backgroundColor = UIColor.black
        
        // add a tap gesture recognizer
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        scnView.addGestureRecognizer(tapGesture)
    }
    
    @objc
    func handleTap(_ gestureRecognize: UIGestureRecognizer) {
        // retrieve the SCNView
        let scnView = self.scnView!//self.view as! SCNView
        
        // check what nodes are tapped
        let p = gestureRecognize.location(in: scnView)
        let hitResults = scnView.hitTest(p, options: [:])
        // check that we clicked on at least one object
        if hitResults.count > 0 {
            // retrieved the first clicked object
            let result = hitResults[0]
            
            // get its material
            let material = result.node.geometry!.firstMaterial!
            
            // highlight it
            SCNTransaction.begin()
            SCNTransaction.animationDuration = 0.5
            
            // on completion - unhighlight
            SCNTransaction.completionBlock = {
                SCNTransaction.begin()
                SCNTransaction.animationDuration = 0.5
                
                material.emission.contents = UIColor.black
                
                SCNTransaction.commit()
            }
            
            material.emission.contents = UIColor.red
            
            SCNTransaction.commit()
        }
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
            let minValue = 5
            let maxValue = 70
            let xScale = Int.random(in: minValue ..< maxValue)
            let yScale = Int.random(in: minValue ..< maxValue)
            let zScale = Int.random(in: minValue ..< maxValue)
            myScale = SCNVector3(xScale, yScale, zScale)
        }
        
        var myPosition = position
        if(position == nil) {
            
            //not too close, not too far
            let minValue = 200
            let maxValue = 1000
            

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

