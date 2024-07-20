import Foundation
import UIKit
import SceneKit
import SSZipArchive
import Defaults

class NeighborSphereInventoryViewController: UIViewController {
    var baseNode: SCNNode!
    @IBOutlet var scnView: SCNView!
    @IBOutlet var headerLabel: UILabel!

    var loadingIndicator: UIActivityIndicatorView!
    var loadingLabel: UILabel!

    var objFilePaths: [URL] = []
    var isLoading = false
    var isLoaded = false

    var zipFileURLs: [URL] = []
    var downloadStatus: [Bool] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        baseNode = SCNNode()
        let neighborUsername = Defaults[.neighborUsername]
        headerLabel.text = "Viewing \(neighborUsername)'s sphere"

        setupLoadingIndicatorAndLabel()
        loadingIndicator.startAnimating()

        // Example: Download zip file URLs dynamically
        downloadZipFileURLs()

        // Initialize download status array
        downloadStatus = Array(repeating: false, count: zipFileURLs.count)

        // Download and unzip all files on a background thread
        if !isLoading {
            isLoading = true
            DispatchQueue.global(qos: .background).async {
                for (index, zipFileURL) in self.zipFileURLs.enumerated() {
                    self.cacheOrDownloadAndUnzipFile(from: zipFileURL, into: "zip\(index + 1)", index: index)
                }
            }
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        loadingIndicator.startAnimating()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        loadingIndicator.stopAnimating()
        isLoading = false
    }

    func setupLoadingIndicatorAndLabel() {
        loadingIndicator = UIActivityIndicatorView(style: .large)
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(loadingIndicator)

        loadingLabel = UILabel()
        loadingLabel.translatesAutoresizingMaskIntoConstraints = false
        loadingLabel.textAlignment = .center
        view.addSubview(loadingLabel)

        NSLayoutConstraint.activate([
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),

            loadingLabel.topAnchor.constraint(equalTo: loadingIndicator.bottomAnchor, constant: 8),
            loadingLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }

    func downloadZipFileURLs() {
        zipFileURLs = [
            URL(string: "https://wordcraft3d.s3.amazonaws.com/modified_2024-03-11_20-49-37.zip")!,
            URL(string: "https://wordcraft3d.s3.amazonaws.com/modified_2024-03-11_19-21-18.zip")!,
            URL(string: "https://wordcraft3d.s3.amazonaws.com/modified_2024-03-11_16-23-17.zip")!,
            URL(string: "https://wordcraft3d.s3.amazonaws.com/modified_2024-03-11_20-49-37.zip")!,
            URL(string: "https://wordcraft3d.s3.amazonaws.com/modified_2024-03-11_19-21-18.zip")!,
            URL(string: "https://wordcraft3d.s3.amazonaws.com/modified_2024-03-11_16-23-17.zip")!,
            URL(string: "https://wordcraft3d.s3.amazonaws.com/modified_2024-03-11_20-49-37.zip")!,
            URL(string: "https://wordcraft3d.s3.amazonaws.com/modified_2024-03-11_19-21-18.zip")!,
            URL(string: "https://wordcraft3d.s3.amazonaws.com/modified_2024-03-11_16-23-17.zip")!,
            URL(string: "https://wordcraft3d.s3.amazonaws.com/modified_2024-03-11_16-23-17.zip")!,
            URL(string: "https://wordcraft3d.s3.amazonaws.com/modified_2024-03-11_20-49-37.zip")!,
            URL(string: "https://wordcraft3d.s3.amazonaws.com/modified_2024-03-11_19-21-18.zip")!,
            URL(string: "https://wordcraft3d.s3.amazonaws.com/modified_2024-03-11_16-23-17.zip")!,
            URL(string: "https://wordcraft3d.s3.amazonaws.com/modified_2024-03-11_20-49-37.zip")!,
            URL(string: "https://wordcraft3d.s3.amazonaws.com/modified_2024-03-11_19-21-18.zip")!,
            URL(string: "https://wordcraft3d.s3.amazonaws.com/modified_2024-03-11_16-23-17.zip")!,
            URL(string: "https://wordcraft3d.s3.amazonaws.com/modified_2024-03-11_20-49-37.zip")!,
            URL(string: "https://wordcraft3d.s3.amazonaws.com/modified_2024-03-11_19-21-18.zip")!,
            URL(string: "https://wordcraft3d.s3.amazonaws.com/modified_2024-03-11_16-23-17.zip")!,
            URL(string: "https://wordcraft3d.s3.amazonaws.com/modified_2024-03-11_16-23-17.zip")!
        ]
    }

    func cacheOrDownloadAndUnzipFile(from url: URL, into directory: String, index: Int) {
        FileDownloader.shared.downloadFile(from: url) { cachedURL in
            guard let cachedURL = cachedURL else {
                print("Failed to download or cache the file from: \(url)")
                self.updateLoadingLabel(failure: true)
                return
            }

            DispatchQueue.global(qos: .background).async {
                if let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                    let destinationUrl = documentsDirectory.appendingPathComponent("unzippedFolder/\(directory)")

                    if FileManager.default.fileExists(atPath: destinationUrl.path) {
                        print("Directory already exists: \(destinationUrl.path)")
                        if let objFilePath = self.findFirstOBJFile(in: destinationUrl) {
                            self.objFilePaths.append(objFilePath)
                        }
                        self.markDownloadComplete(index: index)
                    } else {
                        do {
                            try FileManager.default.createDirectory(at: destinationUrl, withIntermediateDirectories: true, attributes: nil)
                        } catch let createDirectoryError {
                            print("Error creating directory: \(createDirectoryError)")
                            self.updateLoadingLabel(failure: true)
                            return
                        }

                        let success = SSZipArchive.unzipFile(atPath: cachedURL.path, toDestination: destinationUrl.path)

                        if success {
                            print("Files unzipped successfully at \(destinationUrl.path)")

                            if let objFilePath = self.findFirstOBJFile(in: destinationUrl) {
                                self.objFilePaths.append(objFilePath)
                            }
                            self.markDownloadComplete(index: index)
                        } else {
                            print("Failed to unzip the file at \(cachedURL.path)")
                            self.updateLoadingLabel(failure: true)
                        }
                    }
                }
            }
        }
    }
    func updateLoadingLabel(failure: Bool = false) {
        DispatchQueue.main.async {
            let count = self.objFilePaths.count + (failure ? 1 : 0)
            self.loadingLabel.text = "Loading \(count) / \(self.zipFileURLs.count)"
            print("Updated loading label: \(self.loadingLabel.text ?? "")")
        }
    }

    func markDownloadComplete(index: Int) {
        DispatchQueue.main.async {
            self.downloadStatus[index] = true
            print("Marked download complete for index: \(index)")
            self.updateLoadingLabel()

            if self.downloadStatus.allSatisfy({ $0 }) {
                print("All downloads complete. Calling displayOBJFiles()")
                self.displayOBJFiles()
            }
        }
    }




    func displayOBJFiles() {
            guard objFilePaths.count > 0 else {
                print("Not enough OBJ files to display")
                return
            }

            print("Starting to display OBJ files")

            let scene = SCNScene()
            let rootNode = scene.rootNode
            let objectsPerRow = 10
            let objectSpacing: Float = 1.0
            let rowSpacing: Float = 2.0

            // Add ambient light
            let ambientLight = SCNNode()
            ambientLight.light = SCNLight()
            ambientLight.light!.type = .ambient
            ambientLight.light!.intensity = 100
            rootNode.addChildNode(ambientLight)

            // Add directional light
            let directionalLight = SCNNode()
            directionalLight.light = SCNLight()
            directionalLight.light!.type = .directional
            directionalLight.light!.intensity = 1000
            directionalLight.position = SCNVector3(x: 0, y: 10, z: 10)
            rootNode.addChildNode(directionalLight)

            for (index, objFilePath) in objFilePaths.enumerated() {
                do {
                    let objScene = try SCNScene(url: objFilePath, options: [.createNormalsIfAbsent: true])
                    let rowIndex = index / objectsPerRow
                    let columnIndex = index % objectsPerRow

                    let positionX: Float = Float(columnIndex) * objectSpacing
                    let positionY: Float = Float(rowIndex) * rowSpacing

                    for childNode in objScene.rootNode.childNodes {
                        let objectNode = childNode.clone()
                        objectNode.position = SCNVector3(positionX, positionY, 0)
                        rootNode.addChildNode(objectNode)
                    }
                    print("Added object at index \(index) to the scene")
                } catch {
                    print("Failed to load OBJ file at index \(index): \(error.localizedDescription)")
                }
            }

            DispatchQueue.main.async {
                self.scnView.scene = scene
                self.scnView.autoenablesDefaultLighting = true
                self.scnView.allowsCameraControl = true

                print("Scene setup complete")

                // Stop the loading indicator and hide the loading label
                self.loadingIndicator.stopAnimating()
                self.loadingLabel.isHidden = true
                self.isLoaded = true

                // Force UI update
                self.view.setNeedsLayout()
                self.view.layoutIfNeeded()

                // Check if the loading indicator is still visible
                if self.loadingIndicator.isAnimating {
                    print("WARNING: Loading indicator is still animating after being stopped")
                }

                if !self.loadingIndicator.isHidden {
                    print("WARNING: Loading indicator is still visible after being stopped")
                    self.loadingIndicator.isHidden = true
                }

                // Check for any ongoing animations
                if let layers = self.loadingIndicator.layer.sublayers {
                    for layer in layers {
                        if let animationKeys = layer.animationKeys(), !animationKeys.isEmpty {
                            print("WARNING: Layer still has ongoing animations: \(animationKeys)")
                            layer.removeAllAnimations()
                        }
                    }
                }

                // As a last resort, remove the loading indicator from the view hierarchy
                self.loadingIndicator.removeFromSuperview()

                print("Loading indicator stopped, removed from view, label hidden, and isLoaded set to true")
            }
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
}
