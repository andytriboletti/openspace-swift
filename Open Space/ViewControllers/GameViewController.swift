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

class GameViewController: UIViewController {

    required init?(coder: NSCoder) {
        baseNode = SCNNode()
        super.init(coder: coder)
    }
    @IBOutlet var headerButton: MDCButton!
    
    var baseNode:SCNNode!
    @IBOutlet var scnView: SCNView!
    @IBOutlet var headerLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //let viewTabBar = tabBarItem.value(forKey: "view") as? UIView
        //let imageView = viewTabBar?.subviews[0] as? UIImageView
        //let label = viewTabBar?.subviews[0] as? UILabel
        
        let containerScheme = MDCContainerScheme()
        
        //containerScheme.colorScheme.primaryColor = .green
        
        let shapeScheme = MDCShapeScheme()
        // Small Component Shape
        shapeScheme.smallComponentShape = MDCShapeCategory(cornersWith: .cut, andSize: 4)

        // Medium Component Shape
        shapeScheme.mediumComponentShape = MDCShapeCategory(cornersWith: .rounded, andSize: 10)

        // Large Component Shape
        let largeShapeCategory = MDCShapeCategory()
        let rounded50PercentCorner = MDCCornerTreatment.corner(withRadius: 0.5,
                                                               valueType: .percentage)
        let cut8PointsCorner = MDCCornerTreatment.corner(withCut: 8)
        largeShapeCategory?.topLeftCorner = rounded50PercentCorner
        largeShapeCategory?.topRightCorner = rounded50PercentCorner
        largeShapeCategory?.bottomLeftCorner = cut8PointsCorner
        largeShapeCategory?.bottomRightCorner = cut8PointsCorner
        shapeScheme.largeComponentShape = largeShapeCategory!
        
        
        containerScheme.shapeScheme = shapeScheme
        
        self.headerLabel.text = "Your Ship is STOPPED in Deep Space."
        self.headerButton.applyTextTheme(withScheme: containerScheme)
        self.headerButton.applyContainedTheme(withScheme: containerScheme)
        //self.head
        
        //self.tabBarController!.title = "Ship Abracadabra Stopped in Deep Space"
        let scene = SCNScene()
        //imageView.contentMode = .scaleAspectFit
        let image = UIImage(named: "PIA12348orig.jpg")!
        
        let size = CGSize(width: self.view.frame.width, height: self.view.frame.height)
        let aspectScaledToFitImage = image.af_imageAspectScaled(toFill: size)
        
        self.tabBarController?.title = "Ship Abracadabra"
        
        //image!.size = self.view.frame.size
        
        scene.background.contents = aspectScaledToFitImage
        //scene.background.contentsTransform = SCNMatrix4MakeScale(Float(self.view.frame.width), Float(self.view.frame.height), 1)
        
        scene.background.wrapS = SCNWrapMode.repeat
        scene.background.wrapT = SCNWrapMode.repeat
        
        
        addObject(name: "space11.dae", position: nil, scale: nil)
        //addObject(name: "spaceshipb.dae", position: SCNVector3(00,000,500))
        addObject(name: "spaceshipb.dae", position: SCNVector3(00,000,500), scale: nil)
        addObject(name: "starregular.dae", position: SCNVector3(00,500,500), scale: SCNVector3(5,5,5))

        addObject(name: "b.dae", position: SCNVector3(400,-400,400), scale: SCNVector3(30,30,30))
       
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

