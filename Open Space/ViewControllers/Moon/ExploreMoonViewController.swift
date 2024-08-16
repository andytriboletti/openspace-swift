import UIKit
import SceneKit
import Alamofire
import Defaults
import SwiftUI
import PopupView
#if targetEnvironment(macCatalyst)
// Exclude GoogleMobileAds for Mac Catalyst
#else
import GoogleMobileAds
#endif

class ExploreMoonViewController: UIViewController {
    private var hostingController: UIHostingController<PopupContainerView>?

    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet var spaceportButton: UIButton!
    @IBOutlet var tradingPostButton: UIButton!
    @IBOutlet var treasureButton: UIButton!
    @IBOutlet var rewardedButton: UIButton!
    @IBOutlet var takeOffButton: UIButton!
    @IBOutlet var headerLabel: PaddingLabel!

    #if !targetEnvironment(macCatalyst)
        var rewardedAd: GADRewardedAd?
    #endif

    var baseNode: SCNNode!
    @IBOutlet var scnView: SCNView!

    func loadRewardedAd() async {
        #if !targetEnvironment(macCatalyst)
        do {
            #if DEBUG
            rewardedAd = try await GADRewardedAd.load(
                withAdUnitID: MyData.testRewardedVideo, request: GADRequest())
            #else
            rewardedAd = try await GADRewardedAd.load(
                withAdUnitID: MyData.rewardedVideoOnMoon, request: GADRequest())
            #endif

            let serverSideVerificationOptions = GADServerSideVerificationOptions()
            serverSideVerificationOptions.userIdentifier = Defaults[.userId].description
            rewardedAd?.serverSideVerificationOptions = serverSideVerificationOptions

            // Ad successfully loaded, show the button
            DispatchQueue.main.async {
                self.showRewardedButton()
            }
        } catch {
            // Ad failed to load, update the button state
            DispatchQueue.main.async {
                self.updateRewardedButtonForError()
            }
        }
        #endif
    }

    @IBAction func takeOffAction() {
        self.performSegue(withIdentifier: "takeOffFromMoon", sender: self)
    }

    @objc func shipsAction(_ sender: UIBarButtonItem) {
        self.performSegue(withIdentifier: "selectShip", sender: sender)
    }

    func addButtonToStackView() {
        treasureButton = UIButton(type: .system)
        treasureButton.backgroundColor = .systemBlue
        treasureButton.setTitleColor(.white, for: .normal)
        treasureButton.layer.cornerRadius = 8
        treasureButton.contentEdgeInsets = UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20)
        treasureButton.setTitle("Claim Hourly Treasure!", for: .normal)
        treasureButton.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        stackView.addArrangedSubview(treasureButton)
        treasureButton.translatesAutoresizingMaskIntoConstraints = false
        treasureButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
    }

    func addRewardedButtonToStackView() {
        rewardedButton = UIButton(type: .system)
        rewardedButton.backgroundColor = .systemBlue
        rewardedButton.setTitleColor(.white, for: .normal)
        rewardedButton.layer.cornerRadius = 8
        rewardedButton.contentEdgeInsets = UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20)
        rewardedButton.setTitle("Loading...", for: .normal)
        rewardedButton.addTarget(self, action: #selector(buttonTappedRewarded), for: .touchUpInside)
        stackView.addArrangedSubview(rewardedButton)
        rewardedButton.translatesAutoresizingMaskIntoConstraints = false
        rewardedButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        hideRewardedButton() // Initially hide the button
    }

    @objc func buttonTappedRewarded() {
        #if !targetEnvironment(macCatalyst)
        if let rewardedAd = rewardedAd {
            rewardedAd.present(fromRootViewController: self) {
                let reward = rewardedAd.adReward
                // Handle the reward
            }
        } else {
            showError(message: "Ad not available yet.")
        }
        #endif
    }

    func showRewardedButton() {
        #if !targetEnvironment(macCatalyst)
        rewardedButton.setTitle("Watch a Video Ad To Claim Treasure Now", for: .normal)
        rewardedButton.isHidden = false
        #endif
    }

    func hideRewardedButton() {
        #if !targetEnvironment(macCatalyst)
        rewardedButton.isHidden = true
        #endif
    }

    func updateRewardedButtonForError() {
        #if !targetEnvironment(macCatalyst)
        rewardedButton.setTitle("Ad not available yet", for: .normal)
        rewardedButton.isHidden = false
        #endif
    }

    func showError(message: String) {
        let alertController = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        checkDailyTreasureAvailability()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.addButtonToStackView()

        Task {
            await loadRewardedAd()
        }

        #if !targetEnvironment(macCatalyst)
            self.addRewardedButtonToStackView()
        #endif

        headerLabel.layer.masksToBounds = true
        headerLabel.layer.cornerRadius = 35.0
        headerLabel.layer.borderColor = UIColor.darkGray.cgColor
        headerLabel.layer.borderWidth = 3.0

        baseNode = SCNNode()
        let scene = SCNScene()
        self.title = "Your ship '\(appDelegate.gameState.getShipName())' is on the Moon"

        let backgroundFilename = "moonbackgroundwithearth.jpg"
        let image = UIImage(named: backgroundFilename)!

        let size = CGSize(width: self.view.frame.width, height: self.view.frame.height)
        let aspectScaledToFitImage = image.af.imageAspectScaled(toFill: size)
        scene.background.contents = aspectScaledToFitImage
        scene.background.wrapS = SCNWrapMode.repeat
        scene.background.wrapT = SCNWrapMode.repeat

        scene.rootNode.addChildNode(baseNode)

        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        scene.rootNode.addChildNode(cameraNode)

        cameraNode.position = SCNVector3(x: 0, y: 15, z: 50)
        cameraNode.rotation = SCNVector4(1, 0, 0, 0.1)

        baseNode.rotation = SCNVector4(0, -1, 0, 3.14 / 2)

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

        let scnView = self.scnView!
        scnView.scene = scene
        scnView.autoenablesDefaultLighting = true
        scnView.backgroundColor = UIColor.black

        addObject(name: "flagcool.scn", position: SCNVector3(1, 1, 1), scale: nil)
    }

    func loadAdAwait() async {
        do {
            try await loadRewardedAd()
        } catch {
            // Handle any errors that occur during loading
            //print("Error loading rewarded ad: \(error)")
        }
    }

    @objc
    func handleTap(_ gestureRecognize: UIGestureRecognizer) {
        // retrieve the SCNView
    }

    func addObject(name: String, position: SCNVector3?, scale: SCNVector3?) {
        let shipScene = SCNScene(named: name)!
        var animationPlayer: SCNAnimationPlayer! = nil

        let shipSceneChildNodes = shipScene.rootNode.childNodes
        for childNode in shipSceneChildNodes {
            if let position = position {
                childNode.position = position
            }
            if let scale = scale {
                childNode.scale = scale
            }
            baseNode.addChildNode(childNode)
            baseNode.scale = SCNVector3(0.50, 0.50, 0.50)
            baseNode.position = SCNVector3(0, 0, 0)
        }

        for key in shipScene.rootNode.animationKeys {
            animationPlayer = shipScene.rootNode.animationPlayer(forKey: key)
            self.scnView.scene!.rootNode.addAnimationPlayer(animationPlayer, forKey: key)
            animationPlayer.play()
        }
    }

    func addAsteroid(position: SCNVector3? = nil, scale: SCNVector3? = nil) {
        var myScale = scale
        if scale == nil {
            let minValue = 1
            let maxValue = 5
            let xScale = Int.random(in: minValue ..< maxValue)
            let yScale = Int.random(in: minValue ..< maxValue)
            let zScale = Int.random(in: minValue ..< maxValue)
            myScale = SCNVector3(xScale, yScale, zScale)
        }

        var myPosition = position
        if position == nil {
            let minValue = 10
            let maxValue = 100
            var xVal = Int.random(in: minValue ..< maxValue)
            var yVal = Int.random(in: minValue ..< maxValue)
            var zVal = Int.random(in: minValue ..< maxValue)
            if arc4random_uniform(2) == 0 {
                xVal *= -1
            }
            if arc4random_uniform(2) == 0 {
                yVal *= -1
            }
            if arc4random_uniform(2) == 0 {
                zVal *= -1
            }
            myPosition = SCNVector3(xVal, yVal, zVal)
        }
        addObject(name: "a.scn", position: myPosition, scale: myScale)
    }

    func showError() {
        let alertController = UIAlertController(title: "Error", message: "Unable to claim the daily treasure.", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }

    func showSuccessMessage(mineral: String, amount: Int) {
        let popupContainerView = PopupContainerView(
            mineral: mineral,
            amount: amount,
            checkDailyTreasureAvailability: checkDailyTreasureAvailability,
            dismiss: { [weak self] in
                self?.dismissPopup()
            }
        )

        hostingController = UIHostingController(rootView: popupContainerView)

        if let hostingView = hostingController?.view {
            hostingView.backgroundColor = .clear
            hostingView.translatesAutoresizingMaskIntoConstraints = false

            addChild(hostingController!)
            view.addSubview(hostingView)

            NSLayoutConstraint.activate([
                hostingView.topAnchor.constraint(equalTo: view.topAnchor),
                hostingView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                hostingView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                hostingView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])

            hostingController?.didMove(toParent: self)
        }
    }

    private func dismissPopup() {
        hostingController?.willMove(toParent: nil)
        hostingController?.view.removeFromSuperview()
        hostingController?.removeFromParent()
        hostingController = nil

        checkDailyTreasureAvailability()
    }

    @objc func buttonTapped() {
        OpenspaceAPI.shared.claimDailyTreasure(planet: "moon") { result in
            switch result {
            case .success(let (status, mineral, amount)):
                if status == "claimed" {
                    DispatchQueue.main.async {
                        self.showSuccessMessage(mineral: mineral, amount: amount)
                    }
                } else if status == "over_limit" {
                    DispatchQueue.main.async {
                        self.showOverLimitMessage()
                    }
                } else {
                    DispatchQueue.main.async {
                        self.showError()
                    }
                }
            case .failure(let error):
                print("Error claiming daily treasure: \(error.localizedDescription)")
            }
        }
    }

    func showOverLimitMessage() {
        let alertController = UIAlertController(title: "Cargo Limit Exceeded", message: "Not enough cargo space on the ship to claim the minerals.", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alertController, animated: true, completion: nil)
    }

    func checkDailyTreasureAvailability() {
        OpenspaceAPI.shared.checkDailyTreasureAvailability(planet: "moon") { result in
            switch result {
            case .success(let response):
                if let data = response.data(using: .utf8),
                   let jsonResponse = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let status = jsonResponse["status"] as? String {
                    if status == "claimed" {
                        DispatchQueue.main.async {
                            self.showClaimedText()
                            self.hideTreasureButton()
                        }
                    } else if status == "available" {
                        DispatchQueue.main.async {
                            self.showTreasureButton()
                        }
                    }
                } else {
                    self.showError()
                }
            case .failure(let error):
                print("Error checking daily treasure availability: \(error.localizedDescription)")
                self.showError()
            }
        }
    }

    var claimedLabel: UILabel?

    func showClaimedText() {
        guard claimedLabel == nil else {
            return
        }

        treasureButton.isHidden = true

        claimedLabel = UILabel()
        claimedLabel?.text = "Hourly treasure already claimed."
        claimedLabel?.textAlignment = .center
        claimedLabel?.textColor = .white

        if let label = claimedLabel {
            stackView.addArrangedSubview(label)
        }
    }

    func showTreasureButton() {
        treasureButton.isHidden = false
    }

    func hideTreasureButton() {
        treasureButton.isHidden = true
    }
}
