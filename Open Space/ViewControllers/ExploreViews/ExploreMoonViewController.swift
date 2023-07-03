import UIKit
import SceneKit
class ExploreMoonViewController: UIViewController {

    var scene: SCNScene!
    var sceneView: SCNView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Existing scene setup code...

        scene = SCNScene()

        let floorGeometry = SCNFloor()
        let floorNode = SCNNode(geometry: floorGeometry)
        floorNode.position = SCNVector3(0, 0, 0)
        floorNode.opacity = 1.0

        let floorMaterial = SCNMaterial()
        floorMaterial.diffuse.contents = UIColor.green
        floorGeometry.firstMaterial = floorMaterial

        // Safely unwrap the geometry property
        if let existingGeometry = floorNode.geometry {
            existingGeometry.firstMaterial = floorMaterial
        } else {
            // Handle the case where the geometry is nil
            print("Error: Floor geometry is nil.")
        }

        scene.rootNode.addChildNode(floorNode)

        // Create the SCNView and add it to the view hierarchy
        self.sceneView = SCNView(frame: view.bounds)
        self.sceneView.scene = scene
        self.sceneView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        
        
        self.sceneView!.allowsCameraControl = true
        
        // show statistics such as fps and timing information
        self.sceneView!.showsStatistics = false
        self.sceneView!.autoenablesDefaultLighting=true
        
        // configure the view
        self.sceneView!.backgroundColor = UIColor.black
        
        view.addSubview(sceneView)

        // Additional scene setup code...
    }

    // Other methods and code...
}
