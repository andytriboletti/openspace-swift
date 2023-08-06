//
//  SpaceStationViewController.swift
//  Open Space
//
//  Created by Andy Triboletti on 3/18/20.
//  Copyright © 2020 GreenRobot LLC. All rights reserved.
//

import UIKit

import SceneKit

class SpaceStationViewController: UIViewController {
    var scene: SCNScene = SCNScene()
    
    @IBOutlet var changeViewButton: UIButton!
    
    @IBOutlet var spaceportButton: UIButton!
    
    @IBOutlet var tradingPostButton: UIButton!
    
    @IBOutlet var exploreButton: UIButton!
    
    @IBOutlet var takeOffButton: UIButton!
    
    @IBOutlet var headerLabel: PaddingLabel!
    
    var baseNode:SCNNode!
    @IBOutlet var scnView: SCNView!
    
    
    @IBAction func changeView() {
        let pictures = ["eye-of-the-storm-image-from-outer-space-71116.jpg","14648179676_db2001e0fa_o.jpg"
        ,"24609260915_a840b027e5_o.jpg",
        "30509478486_5fff4559ab_o.jpg",
        "bwhi1apicaaamlo.jpg_large.jpg",
        "florence.jpg",
        "iss044e045215_lrg.jpg",
        "iss045e166104.jpg"]
        let backgroundFilename = pictures.randomElement()!
        let image = UIImage(named: backgroundFilename)!
        
        let size = CGSize(width: self.view.frame.width, height: self.view.frame.height)
        let aspectScaledToFitImage = image.af.imageAspectScaled(toFill: size)
        scene.background.contents = aspectScaledToFitImage
    }
    @IBAction func takeOffAction() {
        //self.dismiss(animated: true, completion: {
        self.performSegue(withIdentifier: "takeOff", sender: self)
        //self.dismiss(animated: true, completion: nil)
        
        //})
        
    }
    @objc func shipsAction(_ sender: UIBarButtonItem) {
        
        self.performSegue(withIdentifier: "selectShip", sender: sender)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        headerLabel.layer.masksToBounds = true
        headerLabel.layer.cornerRadius = 35.0
        headerLabel.layer.borderColor = UIColor.darkGray.cgColor
        headerLabel.layer.borderWidth = 3.0
        
        baseNode = SCNNode()
        self.scene = SCNScene()
        self.title="Your ship '\(appDelegate.gameState.getShipName())' is on the Space Station "

        changeView()
        _ = CGSize(width: self.view.frame.width, height: self.view.frame.height)

        scene.background.wrapS = SCNWrapMode.repeat
        scene.background.wrapT = SCNWrapMode.repeat
        
        
        scene.rootNode.addChildNode(baseNode)
        
        
        
        
        
        
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        scene.rootNode.addChildNode(cameraNode)
        
        // place the camera
        //increased values for y move object lower to bottom of screen
        //increase values for x move object to the left
        //increase values for z move object smaller
        cameraNode.position = SCNVector3(x: 0, y: 15, z: 50)
        cameraNode.rotation = SCNVector4(1, 0, 0, 0.1) //slightly rotate so base is pointed away from user
        
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
        
        // set the scene to the view
        scnView.scene = scene
        
        // allows the user to manipulate the camera
        scnView.allowsCameraControl = true
        scnView.autoenablesDefaultLighting=true
        
        // show statistics such as fps and timing information
        scnView.showsStatistics = false
        
        // configure the view
        scnView.backgroundColor = UIColor.black
        //add a tap gesture recognizer
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        scnView.addGestureRecognizer(tapGesture)
        
        
    
        for _ in 1...50 {
            //addAsteroid()
        }
        
    }
    @objc
    func handleTap(_ gestureRecognize: UIGestureRecognizer) {
        // retrieve the SCNView
    }
    
    func addObject(name: String, position: SCNVector3?, scale: SCNVector3?) {
        let shipScene = SCNScene(named: name)!
        var _: SCNAnimationPlayer! = nil
        
        let shipSceneChildNodes = shipScene.rootNode.childNodes
        for childNode in shipSceneChildNodes {
            if(position != nil) {
                childNode.position = position!
            }
            if(scale != nil) {
                childNode.scale = scale!
            }
            baseNode.addChildNode(childNode)
            baseNode.scale = SCNVector3(0.50, 0.50, 0.50)
            baseNode.position = SCNVector3(0,0,0)
            //print(child.animationKeys)
            
            
        }
        
        //        for key in shipScene.rootNode.animationKeys {
        //            // for every animation key
        //            animationPlayer = shipScene.rootNode.animationPlayer(forKey: key)
        //
        //            self.scnView.scene!.rootNode.addAnimationPlayer(animationPlayer, forKey: key)
        //            animationPlayer.play()
        //
        //
        //        }
        
    }
    func addAsteroid(position: SCNVector3? = nil, scale: SCNVector3? = nil) {
        
        var myScale = scale
        if(scale == nil) {
            let minValue = 1
            let maxValue = 5
            let xScale = Int.random(in: minValue ..< maxValue)
            let yScale = Int.random(in: minValue ..< maxValue)
            let zScale = Int.random(in: minValue ..< maxValue)
            myScale = SCNVector3(xScale, yScale, zScale)
        }
        
        var myPosition = position
        if(position == nil) {
            
            //not too close, not too far
            let minValue = 10
            let maxValue = 100
            
            
            var xVal = Int.random(in: minValue ..< maxValue)
            var yVal = Int.random(in: minValue ..< maxValue)
            var zVal = Int.random(in: minValue ..< maxValue)
            //randomly do positive or negative
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
    
}
