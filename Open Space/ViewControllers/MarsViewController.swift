//
//  MarsViewController.swift
//  Open Space
//
//  Created by Andy Triboletti on 2/20/20.
//  Copyright © 2020 GreenRobot LLC. All rights reserved.
//

import UIKit
import MaterialComponents.MaterialButtons
import MaterialComponents.MaterialButtons_Theming
import SceneKit

class MarsViewController: UIViewController {
    @IBOutlet var takeOffButton: MDCButton!
    
    var baseNode:SCNNode!
    @IBOutlet var scnView: SCNView!

    
    @IBAction func takeOffAction() {
        self.performSegue(withIdentifier: "takeOff", sender: self)
    }
    @objc func shipsAction(_ sender: UIBarButtonItem) {
        
        self.performSegue(withIdentifier: "selectShip", sender: sender)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        baseNode = SCNNode()
        let scene = SCNScene()

        let backgroundFilename = "PIA01120orig.jpg"
        let image = UIImage(named: backgroundFilename)!
        
        let size = CGSize(width: self.view.frame.width, height: self.view.frame.height)
        let aspectScaledToFitImage = image.af_imageAspectScaled(toFill: size)
        scene.background.contents = aspectScaledToFitImage
        scene.background.wrapS = SCNWrapMode.repeat
        scene.background.wrapT = SCNWrapMode.repeat
                
        //addObject(name: "space11.dae", position: nil, scale: SCNVector3(10.0,10.0,10.0))
        
        scene.rootNode.addChildNode(baseNode)

        
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
        
        // configure the view
        scnView.backgroundColor = UIColor.black
        
        
        
        self.takeOffButton.applyTextTheme(withScheme: appDelegate.containerScheme)
        self.takeOffButton.applyContainedTheme(withScheme: appDelegate.containerScheme)
        
        
        let shipButton = UIBarButtonItem(title: "Ships", style: .done, target: self, action: #selector(shipsAction(_:)))
        self.navigationItem.leftBarButtonItem = shipButton
        
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
