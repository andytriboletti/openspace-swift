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
            print("pending model")
        } else if let zipFileURL = URL(string: zipURLString) {
            cacheOrDownloadAndUnzipFile(from: zipFileURL)
        } else {
            print("Invalid URL string for selected mesh location.")
        }
    }


    @IBAction func exit() {
        print("exit")

        self.dismiss(animated: false, completion: nil)
    }

    @IBAction func delete() {
        let meshId = Defaults[.selectedMeshId]
        print("delete todo seletedMeshId:")
        print(meshId)
        print("end mesh id")

        let alertController = UIAlertController(title: "Confirmation", message: "Are you sure you want to delete this item?", preferredStyle: .alert)

        // OK Action
        let okAction = UIAlertAction(title: "Delete", style: .default) { _ in
            // Perform action upon OK
            print("OK tapped. todo delete")


            let email = Defaults[.email]
            let meshId = Defaults[.selectedMeshId]
            OpenspaceAPI.shared.deleteItemFromSphere(email: email, meshId: meshId) { result in
                switch result {
                case .success:
                    DispatchQueue.main.async {
                        //popup an alert saying "Successfully deleted item. After clicking OK, you are taken to the previous view controller
                        print("Successfully deleted item submitted to server")
                        let successAlert = UIAlertController(title: "Success", message: "Successfully deleted item.", preferredStyle: .alert)
                            let okSuccessAction = UIAlertAction(title: "OK", style: .default) { _ in
                                // Navigate to the previous view controller
                                //self.navigationController?.popViewController(animated: true)
                                //self.dismiss(animated: true, completion: nil)
                                // Perform the segue to navigate back
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

        // Cancel Action
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in
            // Perform action upon Cancel
            print("Cancel tapped")
            // Add your logic here, if needed
        }
        alertController.addAction(cancelAction)

        // Present the alert controller
        self.present(alertController, animated: true, completion: nil)


    }

    func cacheOrDownloadAndUnzipFile(from url: URL) {
        FileDownloader.shared.downloadFile(from: url) { cachedURL in
            guard let cachedURL = cachedURL else {
                print("Failed to download or cache the file from: \(url)")
                return
            }

            DispatchQueue.global(qos: .background).async {
                if let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                    let destinationUrl = documentsDirectory.appendingPathComponent("unzippedFolder")

                    // Ensure that the directory is created before unzipping
                    do {
                        try FileManager.default.createDirectory(at: destinationUrl, withIntermediateDirectories: true, attributes: nil)
                    } catch let createDirectoryError {
                        print("Error creating directory: \(createDirectoryError)")
                        return
                    }

                    // Unzip the downloaded file
                    let success = SSZipArchive.unzipFile(atPath: cachedURL.path, toDestination: destinationUrl.path)

                    if success {
                        print("Files unzipped successfully at \(destinationUrl.path)")

                        // Display the first .obj file
                        if let objFilePath = self.findFirstOBJFile(in: destinationUrl) {
                            DispatchQueue.main.async {
                                self.displayOBJFile(at: objFilePath)
                            }
                        } else {
                            print("No .obj file found in the directory.")
                        }
                    } else {
                        print("Failed to unzip the file at \(cachedURL.path)")
                    }
                }
            }
        }
    }

    func documentBrowser(_ controller: UIDocumentBrowserViewController, didRequestDocumentCreationWithHandler importHandler: @escaping (URL?, UIDocumentBrowserViewController.ImportMode) -> Void) {
        // Your implementation to create a new document
        // This could involve presenting a UI to the user to specify details of the new document, or creating a document programmatically
        // Once the document is created, call the importHandler with the URL of the newly created document
        // If creation fails, call the importHandler with a nil URL and appropriate ImportMode

        print("documentBrowser !!")
    }

    func findFirstOBJFile(in directoryURL: URL) -> URL? {
        do {
            let fileManager = FileManager.default
            let directoryContents = try fileManager.contentsOfDirectory(at: directoryURL, includingPropertiesForKeys: nil, options: [])

            print("Contents of directory at \(directoryURL.path): \(directoryContents)")

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
            // Conversion from degrees to radians
            let ninetyDegreesInRadians = Float.pi / 2 // 90 degrees
            let oneEightyDegreesInRadians = Float.pi  // 180 degrees

            // Directly create an SCNScene from the .obj file URL
            let scene = try SCNScene(url: objFilePath, options: nil)

            // First, try rotating around the y-axis to face towards you
            scene.rootNode.eulerAngles.y = oneEightyDegreesInRadians + ninetyDegreesInRadians
            scene.rootNode.eulerAngles.z = ninetyDegreesInRadians + oneEightyDegreesInRadians

            // Set the scene to the scnView directly without casting
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

        // Create a Scene source with the .obj file
        guard let sceneSource = SCNSceneSource(url: objFilePath, options: nil) else {
            print("Failed to load scene source for \(objFilePath)")
            return
        }

        // Load the scene from the source
        do {
            var scene = try sceneSource.scene(options: nil)
            let shipScene = scene
            // Assuming baseNode is previously defined and accessible in this context
            let shipSceneChildNodes = shipScene.rootNode.childNodes
            for childNode in shipSceneChildNodes {
                // Change material color to red
                if let geometry = childNode.geometry {
                    for material in geometry.materials {
                        material.diffuse.contents = UIColor.red
                        material.emission.contents = UIColor.red // Makes the color appear more vivid
                    }
                }

                // Add child nodes to the base node
                baseNode.addChildNode(childNode)
            }

            // Add the scene to your scene view
            scnView.scene = scene
            scnView.backgroundColor = UIColor.gray // Example background color
            scnView.scene?.rootNode.addChildNode(baseNode)

            // Add ambient light to the scene
            let ambientLight = SCNLight()
            ambientLight.type = .ambient
            ambientLight.color = UIColor(white: 0.3, alpha: 1.0) // Adjust brightness as needed
            let ambientLightNode = SCNNode()
            ambientLightNode.light = ambientLight
            scnView.scene?.rootNode.addChildNode(ambientLightNode)

            // Create an SCNScene
            scene = SCNScene()

            // Attempt to load the model
            let objSceneSource = SCNSceneSource(url: objFilePath, options: nil)

            // Load all scene entries as nodes
            if let objNode = try objSceneSource?.scene(options: nil).rootNode.childNodes.first {
                // Add the loaded node to the scene
                scene.rootNode.addChildNode(objNode)
            } else {
                print("Could not load node from obj file.")
                return
            }

            // Assuming you have an SCNView in your storyboard or created programmatically
            guard let scnView = self.view as? SCNView else {
                print("SCNView not set up correctly in the view hierarchy.")
                return
            }

            // Set the scene to the view
            scnView.scene = scene

            // Add some basic lighting to the scene
            scnView.autoenablesDefaultLighting = true

            // Allow the user to control the camera
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
            // print(child.animationKeys)

        }
    }
}
