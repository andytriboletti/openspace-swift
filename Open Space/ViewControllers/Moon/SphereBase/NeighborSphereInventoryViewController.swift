import UIKit
import SceneKit
import SSZipArchive
import Defaults
import Alamofire

class NeighborSphereInventoryViewController: UIViewController {
    var baseNode: SCNNode!
    @IBOutlet var scnView: SCNView!
    @IBOutlet var headerLabel: UILabel!

    var loadingContainerView: UIView!
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
    private var reportButton: UIButton?

    override func viewDidLoad() {
        super.viewDidLoad()
        baseNode = SCNNode()
        let neighborUsername = Defaults[.neighborUsername]
        headerLabel.text = "Viewing \(neighborUsername)'s sphere"
        setupReportButton()

        setupLoadingViews()
        startLoading()

        fetchZipFileURLs()
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

    func setupLoadingViews() {
        loadingContainerView = UIView()
        loadingContainerView.translatesAutoresizingMaskIntoConstraints = false
        loadingContainerView.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.8)
        view.addSubview(loadingContainerView)

        loadingIndicator = UIActivityIndicatorView(style: .large)
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        loadingContainerView.addSubview(loadingIndicator)

        loadingLabel = UILabel()
        loadingLabel.translatesAutoresizingMaskIntoConstraints = false
        loadingLabel.textAlignment = .center
        loadingLabel.numberOfLines = 0
        loadingContainerView.addSubview(loadingLabel)

        progressView = UIProgressView(progressViewStyle: .default)
        progressView.translatesAutoresizingMaskIntoConstraints = false
        loadingContainerView.addSubview(progressView)

        NSLayoutConstraint.activate([
            loadingContainerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingContainerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            loadingContainerView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
            loadingContainerView.heightAnchor.constraint(equalToConstant: 120),

            loadingIndicator.topAnchor.constraint(equalTo: loadingContainerView.topAnchor, constant: 16),
            loadingIndicator.centerXAnchor.constraint(equalTo: loadingContainerView.centerXAnchor),

            loadingLabel.topAnchor.constraint(equalTo: loadingIndicator.bottomAnchor, constant: 8),
            loadingLabel.leadingAnchor.constraint(equalTo: loadingContainerView.leadingAnchor, constant: 16),
            loadingLabel.trailingAnchor.constraint(equalTo: loadingContainerView.trailingAnchor, constant: -16),

            progressView.topAnchor.constraint(equalTo: loadingLabel.bottomAnchor, constant: 8),
            progressView.leadingAnchor.constraint(equalTo: loadingContainerView.leadingAnchor, constant: 16),
            progressView.trailingAnchor.constraint(equalTo: loadingContainerView.trailingAnchor, constant: -16),
            progressView.bottomAnchor.constraint(equalTo: loadingContainerView.bottomAnchor, constant: -16)
        ])
    }

    func startLoading() {
        loadingContainerView.isHidden = false
        loadingIndicator.startAnimating()
        loadingLabel.text = "Preparing..."
        progressView.progress = 0
    }

    func updateLoadingProgress(current: Int, total: Int, phase: String) {
        DispatchQueue.main.async {
            self.loadingLabel.text = "\(phase) \(current) / \(total)"
            self.progressView.progress = Float(current) / Float(total)
        }
    }

    func stopLoading() {
        DispatchQueue.main.async {
            self.loadingContainerView.isHidden = true
            self.loadingIndicator.stopAnimating()
        }
    }

    func fetchZipFileURLs() {
        let email = Defaults[.email]
        let authToken = "123todo"
        let sphereId = Defaults[.neighborSphereId]

        OpenspaceAPI.shared.fetchSphereDetails(email: email, authToken: authToken, sphereId: sphereId) { result in
            switch result {
            case .success(let zipFileURLs):
                self.zipFileURLs = zipFileURLs
                self.downloadStatus = Array(repeating: false, count: self.zipFileURLs.count)
                self.completedDownloads = 0
                self.isLoaded = false
                self.isDisplaying = false

                if !self.isLoading {
                    self.isLoading = true
                    DispatchQueue.global(qos: .background).async {
                        for (index, zipFileURL) in self.zipFileURLs.enumerated() {
                            self.cacheOrDownloadAndUnzipFile(from: zipFileURL, into: "zip\(index + 1)", index: index) {
                                self.checkAllDownloadsCompleted()
                            }
                        }
                    }
                }
            case .failure(let error):
                print("Failed to fetch zip file URLs: \(error)")
            }
        }
    }


    func cacheOrDownloadAndUnzipFile(from url: URL, into directory: String, index: Int, completion: @escaping () -> Void) {
        FileDownloader.shared.downloadFile(from: url) { cachedURL in
            guard let cachedURL = cachedURL else {
                //print("Failed to download or cache the file from: \(url)")
                self.handleDownloadFailure(index: index)
                DispatchQueue.main.async {
                    self.updateLoadingProgress(current: self.completedDownloads, total: self.zipFileURLs.count, phase: "Downloading")
                    completion()
                }
                return
            }

            // Extract the modification time from the filename
            let filename = cachedURL.lastPathComponent
            let modificationTime = filename.components(separatedBy: "_").last?.components(separatedBy: ".").first ?? "unknown"

            // Create the directory name with the extracted modification time
            let directoryName = "\(directory)_\(modificationTime)"

            DispatchQueue.global(qos: .background).async {
                if let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                    let destinationUrl = documentsDirectory.appendingPathComponent("unzippedFolder/\(directoryName)")

                    if FileManager.default.fileExists(atPath: destinationUrl.path) {
                        //print("Directory already exists: \(destinationUrl.path)")
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
                            //print("Error creating directory: \(createDirectoryError)")
                            self.handleDownloadFailure(index: index)
                            DispatchQueue.main.async {
                                self.updateLoadingProgress(current: self.completedDownloads, total: self.zipFileURLs.count, phase: "Downloading")
                                completion()
                            }
                            return
                        }

                        let success = SSZipArchive.unzipFile(atPath: cachedURL.path, toDestination: destinationUrl.path)

                        if success {
                            //print("Files unzipped successfully at \(destinationUrl.path)")
                            if let objFilePath = self.findFirstOBJFile(in: destinationUrl) {
                                self.serialQueue.sync {
                                    self.objFilePaths.append(objFilePath)
                                }
                            }
                            self.markDownloadComplete(index: index)
                        } else {
                            //print("Failed to unzip the file at \(cachedURL.path)")
                            self.handleDownloadFailure(index: index)
                        }
                    }
                }
                DispatchQueue.main.async {
                    self.updateLoadingProgress(current: self.completedDownloads, total: self.zipFileURLs.count, phase: "Downloading")
                    completion()
                }
            }
        }
    }






    func markDownloadComplete(index: Int) {
        serialQueue.async {
            if !self.downloadStatus[index] {
                self.downloadStatus[index] = true
                self.completedDownloads += 1
            }
        }
    }

    func handleDownloadFailure(index: Int) {
        serialQueue.async {
            self.downloadStatus[index] = false
        }
    }

    func checkAllDownloadsCompleted() {
        serialQueue.async {
            if self.completedDownloads == self.zipFileURLs.count && !self.isDisplaying {
                self.isDisplaying = true
                DispatchQueue.main.async {
                    self.updateLoadingProgress(current: 0, total: self.objFilePaths.count, phase: "Preparing to display")
                    self.displayOBJFiles()
                }
            }
        }
    }

    func displayOBJFiles() {
        guard !isLoaded && objFilePaths.count > 0 else {
            //print("Not enough OBJ files to display or already displayed")
            return
        }

        //print("Starting to display OBJ files")

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
                        //print("Added object at index \(index) to the scene")

                        DispatchQueue.main.async {
                            self.updateLoadingProgress(current: index + 1, total: totalObjects, phase: "Displaying")
                        }
                    } catch {
                        //print("Failed to load OBJ file at index \(index): \(error.localizedDescription)")
                    }
                }
            }

            DispatchQueue.main.async {
                self.scnView.scene = scene
                self.scnView.autoenablesDefaultLighting = true
                self.scnView.allowsCameraControl = true

                self.stopLoading()
                self.isLoaded = true
                self.isDisplaying = false

                self.view.setNeedsLayout()
                self.view.layoutIfNeeded()

                //print("Scene setup complete")
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
            //print("Error while enumerating files \(directoryURL.path): \(error.localizedDescription)")
        }
        return nil
    }

    // MARK: - Report or block (App Review guideline 1.2: user-generated content)

    /// Adds "Report or Block" under the header. Hidden on the player's own sphere.
    private func setupReportButton() {
        let neighborId = Defaults[.neighborUserId]
        guard neighborId > 0, neighborId != Defaults[.userId],
              let stack = headerLabel.superview as? UIStackView else { return }

        var config = UIButton.Configuration.plain()
        config.title = "Report or Block"
        config.image = UIImage(systemName: "flag")
        config.imagePadding = 6
        let button = UIButton(configuration: config)
        button.addTarget(self, action: #selector(reportOrBlockTapped), for: .touchUpInside)
        let index = (stack.arrangedSubviews.firstIndex(of: headerLabel) ?? 0) + 1
        stack.insertArrangedSubview(button, at: index)
        reportButton = button
    }

    @objc private func reportOrBlockTapped() {
        let name = Defaults[.neighborUsername]
        let sheet = UIAlertController(title: "\(name)'s sphere", message: nil, preferredStyle: .actionSheet)
        sheet.addAction(UIAlertAction(title: "Report This Sphere", style: .default) { [weak self] _ in self?.chooseReportReason() })
        sheet.addAction(UIAlertAction(title: "Block \(name)", style: .destructive) { [weak self] _ in self?.confirmBlock() })
        sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        presentSheet(sheet)
    }

    private func chooseReportReason() {
        let sheet = UIAlertController(title: "Why are you reporting this sphere?", message: nil, preferredStyle: .actionSheet)
        sheet.addAction(UIAlertAction(title: "Offensive or inappropriate", style: .default) { [weak self] _ in self?.sendReport(.offensive, details: "") })
        sheet.addAction(UIAlertAction(title: "Spam or misleading", style: .default) { [weak self] _ in self?.sendReport(.spam, details: "") })
        sheet.addAction(UIAlertAction(title: "Something else", style: .default) { [weak self] _ in self?.askForDetails() })
        sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        presentSheet(sheet)
    }

    private func askForDetails() {
        let alert = UIAlertController(title: "Report This Sphere", message: "Tell us what's wrong (optional).", preferredStyle: .alert)
        alert.addTextField { $0.placeholder = "Details" }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Send", style: .default) { [weak self, weak alert] _ in
            self?.sendReport(.other, details: alert?.textFields?.first?.text ?? "")
        })
        present(alert, animated: true)
    }

    private func sendReport(_ reason: OpenspaceAPI.ReportReason, details: String) {
        let name = Defaults[.neighborUsername]
        OpenspaceAPI.shared.reportPlayer(userId: Defaults[.neighborUserId], sphereId: Defaults[.neighborSphereId],
                                         reason: reason, details: details) { [weak self] (result: Result<String, Error>) in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch result {
                case .success:
                    let alert = UIAlertController(title: "Thanks for reporting",
                                                  message: "We review every report within 24 hours. You can also block \(name) so you no longer see their spheres.",
                                                  preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Block \(name)", style: .destructive) { _ in self.block() })
                    alert.addAction(UIAlertAction(title: "Done", style: .cancel))
                    self.present(alert, animated: true)
                case .failure:
                    self.showMessage(title: "Couldn't send the report", message: "Please check your connection and try again.")
                }
            }
        }
    }

    private func confirmBlock() {
        let name = Defaults[.neighborUsername]
        let alert = UIAlertController(title: "Block \(name)?", message: "You won't see \(name)'s spheres anymore.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Block", style: .destructive) { [weak self] _ in self?.block() })
        present(alert, animated: true)
    }

    private func block() {
        let name = Defaults[.neighborUsername]
        OpenspaceAPI.shared.blockPlayer(userId: Defaults[.neighborUserId]) { [weak self] (result: Result<String, Error>) in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch result {
                case .success:
                    let alert = UIAlertController(title: "\(name) is blocked", message: "Their spheres won't appear for you anymore.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
                        // Back to a fresh neighbor list, which no longer includes this player.
                        self.performSegue(withIdentifier: "backToNeighbors", sender: self)
                    })
                    self.present(alert, animated: true)
                case .failure:
                    self.showMessage(title: "Couldn't block \(name)", message: "Please check your connection and try again.")
                }
            }
        }
    }

    private func showMessage(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    /// Action sheets need an anchor on iPad and Mac, where they show as popovers.
    private func presentSheet(_ sheet: UIAlertController) {
        if let popover = sheet.popoverPresentationController {
            let anchor: UIView = reportButton ?? view
            popover.sourceView = anchor
            popover.sourceRect = anchor.bounds
        }
        present(sheet, animated: true)
    }
}
