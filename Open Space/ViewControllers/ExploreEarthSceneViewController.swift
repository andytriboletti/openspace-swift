//
//  BaseSceneViewController.swift
//  Open Space
//
//  Created by Andy Triboletti on 2/23/20.
//  Copyright © 2020 GreenRobot LLC. All rights reserved.
//

import UIKit
import SceneKit

class ExploreEarthSceneViewController: UIViewController {
    var baseNode:SCNNode!
    @IBOutlet var scnView: SCNView!

    @objc func shipsAction(_ sender: UIBarButtonItem) {
         
        self.dismiss(animated: false, completion: nil)
         
     }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let shipButton = UIBarButtonItem(title: "Back", style: .done, target: self, action: #selector(shipsAction(_:)))
        self.navigationItem.leftBarButtonItem = shipButton
        
        //node stuff
        baseNode = SCNNode()
        
        let scene = SCNScene()
        let backgroundFilename = EarthLocationState.AllCases.Element.self
        //let image = UIImage(named: backgroundFilename.nearTajMahal.rawValue)!
        let image = UIImage(named:appDelegate.gameState.earthLocationState.rawValue)
        let size = CGSize(width: self.view.frame.width, height: self.view.frame.height)
        let aspectScaledToFitImage = image!.af.imageAspectScaled(toFill: size)
        
        
        
        scene.background.contents = aspectScaledToFitImage
        
        scene.background.wrapS = SCNWrapMode.repeat
        scene.background.wrapT = SCNWrapMode.repeat
        
        
        
        scene.rootNode.addChildNode(baseNode)
        
        // create and add a camera to the scene
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(x: 5000, y: 5000, z: 5000)


        baseNode.addChildNode(cameraNode)

        
        scnView!.pointOfView?.position = SCNVector3(x: 5000, y: 5000, z: 5000)

        
        
        // place the camera
        //cameraNode.position = SCNVector3(x: 0, y: 0, z: 15)
        
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
        
        
        
        //how do I start zoomed out?
        //scene.rootNode.worldPosition = SCNVector3(x: 1000, y: 1000, z: 1000)
        
        let scnView = self.scnView!
        
        scnView.scene = scene
        
        scnView.allowsCameraControl = true
        //        scnView.allowsCameraControl = true
        //                   scnView.defaultCameraController.interactionMode = .pan
        //                   scnView.defaultCameraController.inertiaEnabled = true
        //
        //                   scnView.cameraControlConfiguration.rotationSensitivity=0.0
        //                   scnView.cameraControlConfiguration.truckSensitivity=0.0
        //
        //                   scnView.cameraControlConfiguration.panSensitivity = 1
        //                   scnView.defaultCameraController.maximumVerticalAngle = 0
        //                   scnView.defaultCameraController.minimumVerticalAngle = 0
        //                   scnView.defaultCameraController.maximumHorizontalAngle = 0
        //                   scnView.defaultCameraController.minimumHorizontalAngle = 0
        //
        
        //scnView.pointOfView?.rotation = SCNVector4(0, 0, 0, 0)
        //scnView.pointOfView?.movabilityHint = .fixed
        
        // show statistics such as fps and timing information
        //scnView.showsStatistics = false
        scnView.autoenablesDefaultLighting=true
        
        // configure the view
        scnView.backgroundColor = UIColor.black

    }
    func addObject(name: String, position: SCNVector3?, scale: SCNVector3?) {
        //return
        
        
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
    
    
    
    func addObject(name: String, position: SCNVector3?, scale: Float) {
        addObject(name: name, position: position, scale: SCNVector3(x: scale, y: scale, z: scale))
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
    
}
