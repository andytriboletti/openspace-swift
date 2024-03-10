//
//  ModelViewController.swift
//  Open Space
//
//  Created by Andrew Triboletti on 3/9/24.
//  Copyright © 2024 GreenRobot LLC. All rights reserved.
//
import Foundation
import UIKit
import SceneKit
import Zip
import MobileCoreServices
import UniformTypeIdentifiers
import SSZipArchive
class ModelViewController: UIViewController, UIDocumentBrowserViewControllerDelegate {
    var baseNode: SCNNode!
    @IBOutlet var scnView: SCNView!
    @IBOutlet var headerLabel: PaddingLabel!
    
    var sceneView: SCNView!
    var objFileName: String = ""
    var mtlFileName: String = ""
    var textureFileName: String = ""
    
    func downloadAndUnzipFile(from url: URL) {
        let task = URLSession.shared.downloadTask(with: url) { (tempLocalUrl, response, error) in
            if let tempLocalUrl = tempLocalUrl, error == nil {
                // Temporary location where the zip file is downloaded
                if let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                    let destinationUrl = documentsDirectory.appendingPathComponent("unzippedFolder/gorilla")
                    
                    // Ensure that the directory is created before unzipping
                    do {
                        try FileManager.default.createDirectory(at: destinationUrl, withIntermediateDirectories: true, attributes: nil)
                    } catch let createDirectoryError {
                        print("Error creating directory: \(createDirectoryError)")
                        return
                    }
                    
                    // Unzip the downloaded file
                    let success = SSZipArchive.unzipFile(atPath: tempLocalUrl.path, toDestination: destinationUrl.path)
                    
                    if success {
                        print("Files unzipped successfully at \(destinationUrl.path)")
                        
                        // Display the first .obj file
                        if let objFilePath = self.findFirstOBJFile(in: destinationUrl) {
                            DispatchQueue.main.async {
                                self.displayOBJFile3(at: objFilePath)
                            }
                        } else {
                            print("No .obj file found in the directory.")
                        }
                    } else {
                        print("Failed to unzip the file at \(tempLocalUrl.path)")
                    }
                }
            } else {
                print("Error downloading or unzipping the file: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
        task.resume()
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
            let contents = try fileManager.contentsOfDirectory(at: directoryURL, includingPropertiesForKeys: nil)
            
            
            
            let directoryContents = try FileManager.default.contentsOfDirectory(at: directoryURL, includingPropertiesForKeys: nil, options: [])
            
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
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        baseNode = SCNNode()
        
        
        let zipFileURL = URL(string: "https://server.openspace.greenrobot.com/gorilla.zip")!
        
        downloadAndUnzipFile(from: zipFileURL)
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
            let scene = try sceneSource.scene(options: nil)
            let shipScene = scene
            // Assuming baseNode is previously defined and accessible in this context
            let shipSceneChildNodes = shipScene.rootNode.childNodes
            for childNode in shipSceneChildNodes {
                // Add child nodes to the base node
                baseNode.addChildNode(childNode)
            }
            
            
            // Add the scene to your scene view
            scnView.scene = scene
            scnView.backgroundColor = UIColor.gray // Example background color
            scnView.scene?.rootNode.addChildNode(baseNode)
            
            
            
            addObject2(name: "model.obj", position: SCNVector3(10, 10, 10), scale: SCNVector3(10, 10, 10))
            
        } catch {
            print("Error loading scene from \(objFilePath): \(error.localizedDescription)")
        }
    }
    func addObject2(name: String, position: SCNVector3?, scale: SCNVector3?) {
        let shipScene = SCNScene(named: name)!
        var _: SCNAnimationPlayer! = nil
        
        let shipSceneChildNodes = shipScene.rootNode.childNodes
        for childNode in shipSceneChildNodes {
            if(position != nil) {
                childNode.position = position!
            }
            if(scale != nil) {
                childNode.scale = scale!
            }
            baseNode.addChildNode(childNode)
            baseNode.scale = SCNVector3(1,1,1)
            baseNode.position = SCNVector3(0,0,0)
            //print(child.animationKeys)
            
            
        }
    }
}
