import Foundation
import UIKit
import SceneKit
//import Zip
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

    var loadingContainerView: UIView!
    var loadingIndicator: UIActivityIndicatorView!
    var loadingLabel: UILabel!
    var progressView: UIProgressView!

    override func viewDidLoad() {
        super.viewDidLoad()
        baseNode = SCNNode()
        headerLabel.text = Defaults[.selectedMeshPrompt]
        let zipURLString = Defaults[.selectedMeshLocation]

        setupLoadingViews()

        if zipURLString == "" {
            headerLabel.text = "Pending: " + Defaults[.selectedMeshPrompt]
        } else if let zipFileURL = URL(string: zipURLString) {
            startLoading()
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

    func cacheOrDownloadAndUnzipFile(from url: URL) {
        startLoading()
        FileDownloader.shared.downloadFile(from: url) { cachedURL in
            guard let cachedURL = cachedURL else {
                self.stopLoading()
                return
            }

            DispatchQueue.global(qos: .background).async {
                if let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                    let destinationUrl = documentsDirectory.appendingPathComponent("unzippedFolder")

                    do {
                        try FileManager.default.createDirectory(at: destinationUrl, withIntermediateDirectories: true, attributes: nil)
                    } catch let createDirectoryError {
                        self.stopLoading()
                        return
                    }

                    self.updateLoadingProgress(current: 0, total: 1, phase: "Unzipping")
                    let success = SSZipArchive.unzipFile(atPath: cachedURL.path, toDestination: destinationUrl.path)

                    if success {
                        if let objFilePath = self.findFirstOBJFile(in: destinationUrl) {
                            DispatchQueue.main.async {
                                self.updateLoadingProgress(current: 1, total: 1, phase: "Displaying")
                                self.displayOBJFile(at: objFilePath)
                                self.stopLoading()
                            }
                        } else {
                            self.stopLoading()
                        }
                    } else {
                        self.stopLoading()
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
            let objDirectory = objFilePath.deletingLastPathComponent()

            let options: [SCNSceneSource.LoadingOption: Any] = [
                .createNormalsIfAbsent: true,
                .checkConsistency: true,
                .flattenScene: true,
                .convertToYUp: true
            ]

            let scene = try SCNScene(url: objFilePath, options: options)

            scene.rootNode.enumerateChildNodes { (node, _) in
                if let geometry = node.geometry {
                    for material in geometry.materials {
                        if let diffuseTextureName = material.diffuse.contents as? String {
                            let textureURL = objDirectory.appendingPathComponent(diffuseTextureName)
                            if FileManager.default.fileExists(atPath: textureURL.path) {
                                material.diffuse.contents = textureURL
                            }
                        }
                    }
                }
            }

            let ninetyDegreesInRadians = Float.pi / 2
            let oneEightyDegreesInRadians = Float.pi
            scene.rootNode.eulerAngles.y = oneEightyDegreesInRadians + ninetyDegreesInRadians
            scene.rootNode.eulerAngles.z = ninetyDegreesInRadians + oneEightyDegreesInRadians

            scnView.scene = scene
            scnView.autoenablesDefaultLighting = true
            scnView.allowsCameraControl = true

        } catch {
            print("Failed to load the obj file: \(error)")
        }
    }
}
