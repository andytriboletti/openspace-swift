//
//  NeighborSphereInventoryViewController.swift
//  Open Space
//
//  Created by Andrew Triboletti on 3/29/24.
//  Copyright © 2024 GreenRobot LLC. All rights reserved.
//
import Foundation
import UIKit
import SceneKit
import SSZipArchive
import Defaults

class NeighborSphereInventoryViewController: UIViewController {
    var baseNode: SCNNode!
    @IBOutlet var scnView: SCNView!
    @IBOutlet var headerLabel: UILabel!

    var objFilePaths: [URL] = []

    // Define zipFileURLs as a variable
       var zipFileURLs: [URL] = []

    override func viewDidLoad() {
          super.viewDidLoad()
          baseNode = SCNNode()

          // Example: Download zip file URLs dynamically
          downloadZipFileURLs()

          // Download and unzip all files
          for (index, zipFileURL) in zipFileURLs.enumerated() {
              downloadAndUnzipFile(from: zipFileURL, into: "zip\(index + 1)")
          }
      }
    // Method to dynamically download zip file URLs
    func downloadZipFileURLs() {
        // Example: Download zip file URLs dynamically
        // Here you should implement your logic to fetch the URLs dynamically
        // For now, we'll just use some hardcoded URLs as an example
        zipFileURLs = [
            URL(string: "https://wordcraft3d.s3.amazonaws.com/modified_2024-03-11_20-49-37.zip")!,
            URL(string: "https://wordcraft3d.s3.amazonaws.com/modified_2024-03-11_19-21-18.zip")!,
            URL(string: "https://wordcraft3d.s3.amazonaws.com/modified_2024-03-11_16-23-17.zip")!
        ]
    }

    func downloadAndUnzipFile(from url: URL, into directory: String) {
        let task = URLSession.shared.downloadTask(with: url) { (tempLocalUrl, _, error) in
            if let tempLocalUrl = tempLocalUrl, error == nil {
                // Temporary location where the zip file is downloaded
                if let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                    // Directory to extract the zip contents
                    let destinationUrl = documentsDirectory.appendingPathComponent("unzippedFolder/\(directory)")

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

                        // Find and store the .obj file paths
                        if let objFilePath = self.findFirstOBJFile(in: destinationUrl) {
                            self.objFilePaths.append(objFilePath)
                        }

                        // Check if all zip files are processed
                        if self.objFilePaths.count == self.zipFileURLs.count {
                            DispatchQueue.main.async {
                                self.displayOBJFiles()
                            }
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

    func displayOBJFiles() {
        guard objFilePaths.count >= 2 else {
            return
        }

        let rootNode = SCNNode()

        for (index, objFilePath) in objFilePaths.enumerated() {
            do {
                // Directly create an SCNScene from the .obj file URL
                let scene = try SCNScene(url: objFilePath, options: nil)
                let positionX: Float = Float(index) * 1 // Adjust the spacing between objects

                // Position the object along the X-axis
                let objectNode = scene.rootNode
                objectNode.position.x = positionX

                // Adjust the scale of the object
                objectNode.scale = SCNVector3(0.5, 0.5, 0.5) // Adjust the scale as needed

                // Add the object node to the root node
                rootNode.addChildNode(objectNode)
            } catch {
                print("Failed to load the obj file: \(error)")
            }
        }

        // Set the scene to the scnView directly without casting
        scnView.scene = SCNScene()
        scnView.scene?.rootNode.addChildNode(rootNode)

        // Add some basic lighting to the scene
        scnView.autoenablesDefaultLighting = true

        // Allow the user to control the camera
        scnView.allowsCameraControl = true
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
}
