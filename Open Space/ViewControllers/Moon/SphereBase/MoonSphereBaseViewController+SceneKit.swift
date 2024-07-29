import SceneKit
import UIKit

extension MoonSphereBaseViewController {
    func setupCameraAndAnimate(radius: Float) {
        // Define the central point of the spheres
        let centerPoint = SCNVector3(0, 0, 0)

        // Set up the camera node
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(0, 10, radius)
        scene.rootNode.addChildNode(cameraNode)
        sceneView.pointOfView = cameraNode

        // Ensure the camera looks at the center of the scene
        cameraNode.look(at: centerPoint)

        // Adjust the camera's field of view
        cameraNode.camera?.fieldOfView = 60

        // Animate the camera forward and backward a bit
        let forwardZ = radius / 2.0
        let backwardZ = radius * 1.5
        let moveForward = SCNAction.move(to: SCNVector3(0, 10, forwardZ), duration: 10.0)
        let moveBackward = SCNAction.move(to: SCNVector3(0, 10, backwardZ), duration: 10.0)
        let sequence = SCNAction.sequence([moveForward, moveBackward])
        let repeatSequence = SCNAction.repeatForever(sequence)
        cameraNode.runAction(repeatSequence)
    }

    func createFloorNode() -> SCNNode {
        let floor = SCNFloor()
        floor.firstMaterial?.diffuse.contents = UIImage(named: "lroc_color_poles_8k.jpg")

        let floorNode = SCNNode(geometry: floor)
        floorNode.position = SCNVector3(0, 0, 0)

        return floorNode
    }

    func createSpheresOnFloor(scene: SCNScene) {
        let numRows = 10
        let numColumns = 10
        let sphereSize: CGFloat = 1.0
        let spacing: CGFloat = 2.0
        let startX = -(CGFloat(numColumns - 1) * spacing) / 2.0
        let startZ = -(CGFloat(numRows - 1) * spacing) / 2.0

        let numOwnedSpheres = yourSpheres?.count ?? 0
        let numNeighborSpheres = neighborSpheres?.count ?? 0

        for row in 0..<numRows {
            for column in 0..<numColumns {
                let sphere = SCNSphere(radius: sphereSize)

                if row * numColumns + column < numOwnedSpheres {
                    sphere.firstMaterial?.diffuse.contents = UIColor.green
                } else if row * numColumns + column < numOwnedSpheres + numNeighborSpheres {
                    sphere.firstMaterial?.diffuse.contents = UIColor.blue
                } else {
                    sphere.firstMaterial?.diffuse.contents = UIColor.red
                }

                let sphereNode = SCNNode(geometry: sphere)
                sphereNode.position = SCNVector3(startX + CGFloat(column) * spacing, 0, startZ + CGFloat(row) * spacing)

                scene.rootNode.addChildNode(sphereNode)
            }
        }

        // Calculate the radius based on the number of rows and columns
        let maxDimension = max(numRows, numColumns)
        let radius = Float(maxDimension) * Float(spacing) / 2.0
        setupCameraAndAnimate(radius: radius)
    }
}
