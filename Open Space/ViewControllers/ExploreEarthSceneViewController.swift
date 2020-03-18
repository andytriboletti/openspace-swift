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
       
    
     override func viewDidLoad() {
            super.viewDidLoad()
                
            
                //node stuff
                baseNode = SCNNode()

                let scene = SCNScene()
                let backgroundFilename = "PIA17563orig.jpg"
                let image = UIImage(named: backgroundFilename)!
                
                let size = CGSize(width: self.view.frame.width, height: self.view.frame.height)
                let aspectScaledToFitImage = image.af_imageAspectScaled(toFill: size)
                
                
                
                scene.background.contents = aspectScaledToFitImage

                scene.background.wrapS = SCNWrapMode.repeat
                scene.background.wrapT = SCNWrapMode.repeat
            
                addObject(name: appDelegate.gameState.currentShipModel, position: nil, scale: SCNVector3(10.0,10.0,10.0))

        
                //addObject(name: "mtrushmore.scn", position: SCNVector3(-2000,-1000,-1000), scale: 0.2)
            addObject(name: "mtwashington.scn", position: SCNVector3(-800,-800,-800), scale: 0.25)
                
                addObject(name: appDelegate.gameState.closestOtherPlayerShipModel, position: SCNVector3(00,000,500), scale: nil)
              
                
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
                        
                // create and add a camera to the scene
                let cameraNode = SCNNode()
                cameraNode.camera = SCNCamera()
                scene.rootNode.addChildNode(cameraNode)
                
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
                
                
                let scnView = self.scnView!
                //addObject(name: "mtrushmore.scn", position: nil, scale: nil)

                // var myScene = SCNScene(named: "mtrushmore.scn")
                //var myScene = SCNScene(named: "mtwashington.scn")
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
                   
                   //scnView!.pointOfView?.rotation = SCNVector4(0, 0, 0, 0)
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
}
