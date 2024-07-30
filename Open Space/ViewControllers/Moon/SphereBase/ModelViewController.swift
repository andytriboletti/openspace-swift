import Foundation
import UIKit
import SceneKit
import Zip
import MobileCoreServices
import UniformTypeIdentifiers
import SSZipArchive
import Defaults

class ModelViewController: UIViewController, UIDocumentBrowserViewControllerDelegate {
    var baseNode: SCNNode!
    @IBOutlet var scnView: SCNView!
    @IBOutlet var headerLabel: PaddingLabel!

    var sceneView: SCNView!
    var objFileName: String = ""
    var mtlFileName: String = ""
    var textureFileName: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        baseNode = SCNNode()
        headerLabel.text = Defaults[.selectedMeshPrompt]
        let zipURLString = Defaults[.selectedMeshLocation]

        if zipURLString == "" {
            headerLabel.text = "Pending: " + Defaults[.selectedMeshPrompt]
        } else if let zipFileURL = URL(string: zipURLString) {
            cacheOrDownloadAndUnzipFile(from: zipFileURL)
        }
    }

    @IBAction func exit() {
        self.dismiss(animated: false, completion: nil)
    }

    @IBAction func delete() {
        let meshId = Defaults[.selectedMeshId]

        let alertController = UIAlertController(title: "Confirmation", message: "Are you sure you want to delete this item?", preferredStyle: .alert)

        let okAction = UIAlertAction(title: "Delete", style: .default) { _ in
            let email = Defaults[.email]
            let meshId = Defaults[.selectedMeshId]
            OpenspaceAPI.shared.deleteItemFromSphere(email: email, meshId: meshId) { result in
                switch result {
                case .success:
                    DispatchQueue.main.async {
                        let successAlert = UIAlertController(title: "Success", message: "Successfully deleted item.", preferredStyle: .alert)
                        let okSuccessAction = UIAlertAction(title: "OK", style: .default) { _ in
                            self.performSegue(withIdentifier: "goToSphereInventory", sender: self)
                        }
                        successAlert.addAction(okSuccessAction)
                        self.present(successAlert, animated: true, completion: nil)
                    }
                case .failure(let error):
                    print("Error submitting delete item to server: \(error.localizedDescription)")
                }
            }
        }
        alertController.addAction(okAction)

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in }
        alertController.addAction(cancelAction)

        self.present(alertController, animated: true, completion: nil)
    }

    func cacheOrDownloadAndUnzipFile(from url: URL) {
        FileDownloader.shared.downloadFile(from: url) { cachedURL in
            guard let cachedURL = cachedURL else {
                return
            }

            DispatchQueue.global(qos: .background).async {
                if let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                    let destinationUrl = documentsDirectory.appendingPathComponent("unzippedFolder")

                    do {
                        try FileManager.default.createDirectory(at: destinationUrl, withIntermediateDirectories: true, attributes: nil)
                    } catch let createDirectoryError {
                        return
                    }

                    let success = SSZipArchive.unzipFile(atPath: cachedURL.path, toDestination: destinationUrl.path)

                    if success {
                        if let objFilePath = self.findFirstOBJFile(in: destinationUrl) {
                            DispatchQueue.main.async {
                                self.displayOBJFile(at: objFilePath)
                            }
                        }
                    }
                }
            }
        }
    }

    func findFirstOBJFile(in directoryURL: URL) -> URL? {
        do {
            let fileManager = FileManager.default
            let directoryContents = try fileManager.contentsOfDirectory(at: directoryURL, includingPropertiesForKeys: nil, options: [])

            for fileURL in directoryContents {
                if fileURL.pathExtension.lowercased() == "obj" {
                    return fileURL
                }
            }
        } catch {
            print("Error while enumerating files \(directoryURL.path): \(error.localizedDescription)")
        }
        return nil
    }

    func displayOBJFile(at objFilePath: URL) {
        do {
            // Get the directory containing the OBJ file
            let objDirectory = objFilePath.deletingLastPathComponent()

            // Create scene loading options
            let options: [SCNSceneSource.LoadingOption: Any] = [
                .createNormalsIfAbsent: true,
                .checkConsistency: true,
                .flattenScene: true,
                .convertToYUp: true
            ]

            // Load the scene
            let scene = try SCNScene(url: objFilePath, options: options)

            // Process all nodes in the scene
            scene.rootNode.enumerateChildNodes { (node, _) in
                if let geometry = node.geometry {
                    for material in geometry.materials {
                        // Check if the material has a diffuse texture
                        if let diffuseTextureName = material.diffuse.contents as? String {
                            let textureURL = objDirectory.appendingPathComponent(diffuseTextureName)
                            if FileManager.default.fileExists(atPath: textureURL.path) {
                                material.diffuse.contents = textureURL
                            }
                        }

                        // Similarly, handle other texture types (normal, specular, etc.) if needed
                    }
                }
            }

            // Apply transformations
            let ninetyDegreesInRadians = Float.pi / 2
            let oneEightyDegreesInRadians = Float.pi
            scene.rootNode.eulerAngles.y = oneEightyDegreesInRadians + ninetyDegreesInRadians
            scene.rootNode.eulerAngles.z = ninetyDegreesInRadians + oneEightyDegreesInRadians

            // Set the scene to the scnView
            scnView.scene = scene

            // Add some basic lighting to the scene
            scnView.autoenablesDefaultLighting = true

            // Allow the user to control the camera
            scnView.allowsCameraControl = true

        } catch {
            print("Failed to load the obj file: \(error)")
        }
    }

    func displayOBJFile3(at url: URL) {
        let objFilePath = url.appendingPathComponent("model.obj")

        guard let sceneSource = SCNSceneSource(url: objFilePath, options: nil) else {
            print("Failed to load scene source for \(objFilePath)")
            return
        }

        do {
            var scene = try sceneSource.scene(options: nil)
            let shipScene = scene

            let shipSceneChildNodes = shipScene.rootNode.childNodes
            for childNode in shipSceneChildNodes {
                if let geometry = childNode.geometry {
                    for material in geometry.materials {
                        material.diffuse.contents = UIColor.red
                        material.emission.contents = UIColor.red
                    }
                }
                baseNode.addChildNode(childNode)
            }

            scnView.scene = scene
            scnView.backgroundColor = UIColor.gray
            scnView.scene?.rootNode.addChildNode(baseNode)

            let ambientLight = SCNLight()
            ambientLight.type = .ambient
            ambientLight.color = UIColor(white: 0.3, alpha: 1.0)
            let ambientLightNode = SCNNode()
            ambientLightNode.light = ambientLight
            scnView.scene?.rootNode.addChildNode(ambientLightNode)

            scene = SCNScene()

            let objSceneSource = SCNSceneSource(url: objFilePath, options: nil)

            if let objNode = try objSceneSource?.scene(options: nil).rootNode.childNodes.first {
                scene.rootNode.addChildNode(objNode)
            } else {
                print("Could not load node from obj file.")
                return
            }

            guard let scnView = self.view as? SCNView else {
                print("SCNView not set up correctly in the view hierarchy.")
                return
            }

            scnView.scene = scene
            scnView.autoenablesDefaultLighting = true
            scnView.allowsCameraControl = true
        } catch {
            print("Error loading scene from \(objFilePath): \(error.localizedDescription)")
        }
    }

    func addObject2(name: String, position: SCNVector3?, scale: SCNVector3?) {
        let shipScene = SCNScene(named: name)!
        var _: SCNAnimationPlayer! = nil

        let shipSceneChildNodes = shipScene.rootNode.childNodes
        for childNode in shipSceneChildNodes {
            if position != nil {
                childNode.position = position!
            }
            if scale != nil {
                childNode.scale = scale!
            }
            baseNode.addChildNode(childNode)
            baseNode.scale = SCNVector3(1, 1, 1)
            baseNode.position = SCNVector3(0, 0, 0)
        }
    }
}
