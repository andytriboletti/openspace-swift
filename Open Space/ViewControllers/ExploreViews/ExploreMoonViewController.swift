import UIKit
import SceneKit

class ExploreMoonViewController: UIViewController, SCNSceneRendererDelegate {
    var sceneView: SCNView!

    override func viewDidLoad() {
        super.viewDidLoad()
        //sceneView = SCNView(frame: view.bounds)
        
        sceneView = SCNView(frame: UIScreen.main.bounds)
        view.addSubview(sceneView)
        
        // Configure the sceneView properties
        sceneView.delegate = self
        sceneView.autoenablesDefaultLighting = true
        sceneView.allowsCameraControl = true
        
        // Create a new SceneKit scene
        let scene = SCNScene()
        
        // Set the background image
        scene.background.contents = UIImage(named: "starry-sky-998641.jpg")
        
        // Add the floor node to the scene
        let floorNode = createFloorNode()
        scene.rootNode.addChildNode(floorNode)
        
        // Add the spheres on the floor
        createSpheresOnFloor(scene: scene)
        
        // Set the scene on the sceneView
        sceneView.scene = scene
        sceneView.contentMode = .scaleAspectFill

    }
    
    func createFloorNode() -> SCNNode {
        let floor = SCNFloor()
        floor.firstMaterial?.diffuse.contents = UIImage(named: "lroc_color_poles_8k.jpg")
        
        let floorNode = SCNNode(geometry: floor)
        floorNode.position = SCNVector3(0, 0, 0) // Set the floor's position
        
        return floorNode
    }


    
    func createSpheresOnFloor(scene: SCNScene) {
        let numRows = 5
        let numColumns = 4
        let sphereSize: CGFloat = 1.0
        let spacing: CGFloat = 2.0
        let startX = -(CGFloat(numColumns - 1) * spacing) / 2.0
        let startZ = -(CGFloat(numRows - 1) * spacing) / 2.0
        
        for row in 0..<numRows {
            for column in 0..<numColumns {
                let sphere = SCNSphere(radius: sphereSize)
                sphere.firstMaterial?.diffuse.contents = UIColor.red
                
                let sphereNode = SCNNode(geometry: sphere)
                sphereNode.position = SCNVector3(startX + CGFloat(column) * spacing, 0, startZ + CGFloat(row) * spacing)
                
                scene.rootNode.addChildNode(sphereNode)
            }
        }
    }
}
