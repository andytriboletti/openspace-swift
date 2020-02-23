//
//  BaseSceneViewController.swift
//  Open Space
//
//  Created by Andy Triboletti on 2/23/20.
//  Copyright © 2020 GreenRobot LLC. All rights reserved.
//

import UIKit
import SceneKit

class BaseSceneViewController: UIViewController {
    var baseNode:SCNNode!
    @IBOutlet var scnView: SCNView!
       
    
     override func viewDidLoad() {
            super.viewDidLoad()
                
            baseNode = SCNNode()
            let scene = SCNScene()
            self.title="Mt Rushmore"
            
            let backgroundFilename = "PIA01120orig.jpg"
            let image = UIImage(named: backgroundFilename)!
            
            let size = CGSize(width: self.view.frame.width, height: self.view.frame.height)
            let aspectScaledToFitImage = image.af_imageAspectScaled(toFill: size)
            scene.background.wrapS = SCNWrapMode.repeat
            scene.background.wrapT = SCNWrapMode.repeat
            

            
            
            
            // create and add a camera to the scene
            let cameraNode = SCNNode()
            cameraNode.camera = SCNCamera()
            
            // place the camera
            cameraNode.position = SCNVector3(x: 0, y: 0, z: 15)
            scene.rootNode.addChildNode(cameraNode)

        
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
        
//            var mountain = SCNScene(named: "mtwashington.scn")
            scnView.scene = scene
            scene.background.contents = aspectScaledToFitImage

            
            scnView.autoenablesDefaultLighting=true

            // show statistics such as fps and timing information
            scnView.showsStatistics = true
            scnView.allowsCameraControl = true

            addObject(name: "mars.dae", position: SCNVector3(1,1,1), scale: SCNVector3(1,1,1))
            
            scene.rootNode.addChildNode(baseNode)


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
