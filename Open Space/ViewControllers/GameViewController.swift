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
    
    @IBAction func headerButtonClicked() {
        print("header clicked")

        
        // Prepare the popup assets
        let title = "Where do you want to navigate to?"
        //let message = nil
        _ = UIImage(named: "space_icon_1024.jpg")

        // Create the dialog
        let popup = PopupDialog(title: title, message: nil, image: nil)

        // Create buttons
        let buttonOne = CancelButton(title: "Cancel") {
            print("You canceled the dialog.")
        }

        // This button will not the dismiss the dialog
        let buttonTwo = DefaultButton(title: "Earth") {
            print("earth")
        }

        let buttonThree = DefaultButton(title: "Earth Moon", height: 60) {
            print("earth moon")
        }
        let buttonFour = DefaultButton(title: "Mars", height: 60) {
            print("mars")
        }
        let buttonFive = DefaultButton(title: "Spaceship Firefly", height: 60) {
            print("spaceship")
        }

        let buttons = [buttonOne, buttonTwo, buttonThree, buttonFour, buttonFive]
        popup.addButtons(buttons)

        // Present dialog
        self.present(popup, animated: true, completion: nil)
        
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
            self.headerLabel.text = "Your ship 'Centa' is near Mars. It is stopped."

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
        
        self.tabBarController?.title = "Centa Viewport"
        
        //image!.size = self.view.frame.size
        
        scene.background.contents = aspectScaledToFitImage
        //scene.background.contentsTransform = SCNMatrix4MakeScale(Float(self.view.frame.width), Float(self.view.frame.height), 1)
        
        scene.background.wrapS = SCNWrapMode.repeat
        scene.background.wrapT = SCNWrapMode.repeat
        
        
        //spaceship facing forward is y = 0 is center
        addObject(name: "space11.dae", position: nil, scale: SCNVector3(10.0,10.0,10.0))
        //addObject(name: "spaceshipb.dae", position: SCNVector3(00,000,500))
        addObject(name: "spaceshipb.dae", position: SCNVector3(00,000,500), scale: nil)
        
        addObject(name: "mars.dae", position: SCNVector3(-500, 0, -200), scale: SCNVector3(5,5,5))
        
        //static asteroid
         addObject(name: "a.dae", position: SCNVector3(100,0,-100), scale: SCNVector3(10,10,10))
        
         addObject(name: "instantmeshstation2.scn", position: SCNVector3(-400, -800, -400), scale: SCNVector3(5,5,5))
          
        
         
        //static asteroid
        //      addObject(name: "a.dae", position: SCNVector3(100,100,100), scale: SCNVector3(30,30,30))
        
        addObject(name: "starcrumpled.dae", position: SCNVector3(-1000, 300, 10), scale: SCNVector3(2,2,2))

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

