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
    var progressView: UIProgressView!

    var objFilePaths: [URL] = []
    var isLoading = false
    var isLoaded = false
    private var isDisplaying = false

    var zipFileURLs: [URL] = []
    var downloadStatus: [Bool] = []
    var completedDownloads = 0

    let serialQueue = DispatchQueue(label: "com.greenrobot.openspace.serialQueue")

    override func viewDidLoad() {
        super.viewDidLoad()
        baseNode = SCNNode()
        let neighborUsername = Defaults[.neighborUsername]
        headerLabel.text = "Viewing \(neighborUsername)'s sphere"

        setupLoadingIndicatorAndLabel()
        loadingIndicator.startAnimating()

        downloadZipFileURLs()

        downloadStatus = Array(repeating: false, count: zipFileURLs.count)
        completedDownloads = 0
        updateLoadingLabel()
        loadingLabel.isHidden = false
        isLoaded = false
        isDisplaying = false

        if !isLoading {
            isLoading = true
            DispatchQueue.global(qos: .background).async {
                for (index, zipFileURL) in self.zipFileURLs.enumerated() {
                    self.cacheOrDownloadAndUnzipFile(from: zipFileURL, into: "zip\(index + 1)", index: index) {
                        self.checkAllDownloadsCompleted()
                    }
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

        progressView = UIProgressView(progressViewStyle: .default)
        progressView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(progressView)

        NSLayoutConstraint.activate([
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),

            loadingLabel.topAnchor.constraint(equalTo: loadingIndicator.bottomAnchor, constant: 8),
            loadingLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            progressView.topAnchor.constraint(equalTo: loadingLabel.bottomAnchor, constant: 8),
            progressView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            progressView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
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

    func cacheOrDownloadAndUnzipFile(from url: URL, into directory: String, index: Int, completion: @escaping () -> Void) {
        FileDownloader.shared.downloadFile(from: url) { cachedURL in
            guard let cachedURL = cachedURL else {
                print("Failed to download or cache the file from: \(url)")
                self.handleDownloadFailure(index: index)
                DispatchQueue.main.async {
                    self.updateLoadingLabel()
                    completion()
                }
                return
            }

            DispatchQueue.global(qos: .background).async {
                if let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                    let destinationUrl = documentsDirectory.appendingPathComponent("unzippedFolder/\(directory)")

                    if FileManager.default.fileExists(atPath: destinationUrl.path) {
                        print("Directory already exists: \(destinationUrl.path)")
                        if let objFilePath = self.findFirstOBJFile(in: destinationUrl) {
                            self.serialQueue.sync {
                                self.objFilePaths.append(objFilePath)
                            }
                        }
                        self.markDownloadComplete(index: index)
                    } else {
                        do {
                            try FileManager.default.createDirectory(at: destinationUrl, withIntermediateDirectories: true, attributes: nil)
                        } catch let createDirectoryError {
                            print("Error creating directory: \(createDirectoryError)")
                            self.handleDownloadFailure(index: index)
                            DispatchQueue.main.async {
                                self.updateLoadingLabel()
                                completion()
                            }
                            return
                        }

                        let success = SSZipArchive.unzipFile(atPath: cachedURL.path, toDestination: destinationUrl.path)

                        if success {
                            print("Files unzipped successfully at \(destinationUrl.path)")
                            if let objFilePath = self.findFirstOBJFile(in: destinationUrl) {
                                self.serialQueue.sync {
                                    self.objFilePaths.append(objFilePath)
                                }
                            }
                            self.markDownloadComplete(index: index)
                        } else {
                            print("Failed to unzip the file at \(cachedURL.path)")
                            self.handleDownloadFailure(index: index)
                        }
                    }
                }
                DispatchQueue.main.async {
                    self.updateLoadingLabel()
                    completion()
                }
            }
        }
    }

    func updateLoadingLabel() {
        DispatchQueue.main.async {
            self.loadingLabel.text = "Loading \(self.completedDownloads) / \(self.zipFileURLs.count)"
            let progress = Float(self.completedDownloads) / Float(self.zipFileURLs.count)
            self.progressView.setProgress(progress, animated: true)
        }
    }

    func markDownloadComplete(index: Int) {
        serialQueue.async {
            if !self.downloadStatus[index] {
                self.downloadStatus[index] = true
                self.completedDownloads += 1
                DispatchQueue.main.async {
                    self.updateLoadingLabel()
                }
            }
        }
    }

    func handleDownloadFailure(index: Int) {
        serialQueue.async {
            self.downloadStatus[index] = false
            DispatchQueue.main.async {
                self.updateLoadingLabel()
            }
        }
    }

    func checkAllDownloadsCompleted() {
        serialQueue.async {
            if self.completedDownloads == self.zipFileURLs.count && !self.isDisplaying {
                self.isDisplaying = true
                DispatchQueue.main.async {
                    self.progressView.setProgress(0, animated: false)
                    self.loadingLabel.text = "Preparing to display objects..."
                    self.displayOBJFiles()
                }
            }
        }
    }


    func displayOBJFiles() {
        guard !isLoaded && objFilePaths.count > 0 else {
            print("Not enough OBJ files to display or already displayed")
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

        let totalObjects = objFilePaths.count
        var objectsAdded = 0

        DispatchQueue.global(qos: .userInitiated).async {
            for (index, objFilePath) in self.objFilePaths.enumerated() {
                autoreleasepool {
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
                        objectsAdded += 1
                        print("Added object at index \(index) to the scene")

                        DispatchQueue.main.async {
                            let progress = Float(objectsAdded) / Float(totalObjects)
                            self.progressView.setProgress(progress, animated: true)
                            self.loadingLabel.text = "Displaying \(objectsAdded) / \(totalObjects)"
                        }
                    } catch {
                        print("Failed to load OBJ file at index \(index): \(error.localizedDescription)")
                    }
                }
            }

            DispatchQueue.main.async {
                self.scnView.scene = scene
                self.scnView.autoenablesDefaultLighting = true
                self.scnView.allowsCameraControl = true

                self.loadingIndicator.stopAnimating()
                self.loadingLabel.isHidden = true
                self.progressView.isHidden = true
                self.isLoaded = true
                self.isDisplaying = false

                self.view.setNeedsLayout()
                self.view.layoutIfNeeded()

                self.loadingIndicator.removeFromSuperview()

                print("Scene setup complete")
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
}
