import UIKit
import QuartzCore
import SceneKit
import Alamofire
import AlamofireImage
import PopupDialog
import SCLAlertView
import DynamicBlurView
import Defaults
import SwiftUI
import SSZipArchive

class GameViewController: UIViewController {
    var stationFilePaths: [URL] = []

    var webSocketManager: WebSocketManager!
    var errorMessage: String?

    var baseNode: SCNNode!
    var tempNode: SCNNode!
    var spaceShip: [SCNNode]!
    var tapGesture: UITapGestureRecognizer?
    @IBOutlet var currencyLabel: UILabel!
    @IBOutlet var energyLabel: UILabel!

    @IBOutlet var headerButton: UIButton!

    @IBOutlet var headerButton2: UIButton!
    @IBOutlet var headerButtonView: UIView!
    @IBOutlet var headerButton2View: UIView!
    @IBOutlet var spaceShipsButton: UIBarButtonItem!
    var username: String?
    @IBOutlet var scnView: SCNView!
    @IBOutlet var headerLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        let myUsername = Defaults[.username]
        print("my username:")
        print(myUsername)
    }

    override func viewWillAppear(_ animated: Bool) {
        scnView.scene?.rootNode.enumerateChildNodes { (node, _) in
            node.removeFromParentNode()
        }

        let cameraNode = SCNNode()
        let camera = SCNCamera()

        self.baseNode = SCNNode()
        self.tempNode = SCNNode()
        let scene = SCNScene()

        super.viewDidLoad()

        setupHeader()

        let backgroundFilename = "starry-sky-998641.jpg"
        let image = UIImage(named: backgroundFilename)!
        let rose = UIColor(red: 1.000, green: 0.314, blue: 0.314, alpha: 0.5)
        let semi = rose.withAlphaComponent(0.1)
        let size = CGSize(width: self.view.frame.width, height: self.view.frame.height)
        let aspectScaledToFitImage = image.af.imageAspectScaled(toFill: size)

        scene.background.contents = aspectScaledToFitImage
        scene.background.wrapS = .repeat
        scene.background.wrapT = .repeat
        spaceShip = addObject(name: Defaults[.currentShipModel], position: nil, scale: SCNVector3(10, 10, 10))

        for _ in 1...50 {
            addAsteroid()
        }

        _ = addObject(name: "a.scn", position: SCNVector3(5000, 5000, 5000), scale: SCNVector3(100, 100, 100))

        cameraNode.camera = camera
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 15)

        baseNode.addChildNode(cameraNode)

        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light!.type = .omni
        lightNode.position = SCNVector3(x: 0, y: 10, z: 10)
        scene.rootNode.addChildNode(lightNode)

        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light!.type = .ambient
        ambientLightNode.light!.color = UIColor.darkGray
        scene.rootNode.addChildNode(ambientLightNode)

        refresh()

        scene.rootNode.addChildNode(baseNode)
        baseNode.addChildNode(tempNode)

        self.scnView!.scene = scene
        self.scnView!.allowsCameraControl = true
        self.scnView!.showsStatistics = false
        self.scnView!.autoenablesDefaultLighting = true

        self.tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        scnView.addGestureRecognizer(self.tapGesture!)

        cacheFiles()
    }

    func cacheFiles() {
        let fileURLs = [
            URL(string: "https://wordcraft3d.s3.amazonaws.com/modified_2024-03-11_20-49-37.zip")!,
            URL(string: "https://wordcraft3d.s3.amazonaws.com/modified_2024-03-11_19-21-18.zip")!,
            URL(string: "https://wordcraft3d.s3.amazonaws.com/modified_2024-03-11_16-23-17.zip")!

        ]

        for fileURL in fileURLs {
            FileDownloader.shared.downloadFile(from: fileURL) { cachedURL in
                if let cachedURL = cachedURL {
                    print("File downloaded and cached at: \(cachedURL.path)")
                } else {
                    print("Failed to download file from: \(fileURL)")
                }
            }
        }

    }

    override func viewDidDisappear(_ animated: Bool) {
        tempNode?.enumerateChildNodes { (node, _) in
            node.removeFromParentNode()
        }
        tempNode?.removeFromParentNode()

        if self.tapGesture != nil {
            scnView.removeGestureRecognizer(self.tapGesture!)
        }
        super.viewDidDisappear(animated)
    }

    func refresh() {
        getLocation()
    }

    override var shouldAutorotate: Bool {
        return true
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }
}
