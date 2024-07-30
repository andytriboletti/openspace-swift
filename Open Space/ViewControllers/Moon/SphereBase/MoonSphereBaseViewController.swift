import UIKit
import SceneKit
import Defaults

class MoonSphereBaseViewController: BackgroundImageViewController, SCNSceneRendererDelegate {
    @IBOutlet var headerLabel: PaddingLabel!
    @IBOutlet var sceneView: SCNView!

    @IBOutlet var enterYourSphereButton: UIButton!
    @IBOutlet var exploreNeighborSphere: UIButton!
    @IBOutlet var claimAnotherSphereButton: UIButton!
    @IBOutlet var keyLabel: UILabel!
    @IBOutlet var youHaveNumberOfSpheres: UILabel!
    var noNeighborSpheresLabel: UILabel?

    var yourSpheres: [[String: Any]]?
    var neighborSpheres: [[String: Any]]?
    var scene = SCNScene()
    var cameraNode = SCNNode()  // Define the camera node here

    override func viewDidLoad() {
        super.viewDidLoad()
        let labelText = "Your Spheres: Green     Neighbor Spheres: Blue     Unoccupied Spheres: Red"

        let attributedText = NSMutableAttributedString(string: labelText)

        // Set color for "Your Spheres: Green"
        attributedText.addAttribute(.foregroundColor, value: UIColor.green, range: NSRange(location: 0, length: 19))

        // Set color for "Neighbor Spheres: Blue"
        attributedText.addAttribute(.foregroundColor, value: UIColor.blue, range: NSRange(location: 20, length: 26))

        // Set color for "Unoccupied Spheres: Red"
        attributedText.addAttribute(.foregroundColor, value: UIColor.red, range: NSRange(location: 50, length: 24))

        // Assign attributedText to your UILabel
        keyLabel.attributedText = attributedText

        // Configure the sceneView properties
        sceneView.delegate = self
        sceneView.autoenablesDefaultLighting = true
        sceneView.allowsCameraControl = false

        // Set the background image
        scene.background.contents = UIImage(named: "starry-sky-998641.jpg")

        // Add the floor node to the scene
        let floorNode = createFloorNode()
        scene.rootNode.addChildNode(floorNode)

        // Set the scene on the sceneView
        sceneView.scene = scene

        // Set the properties for headerLabel
        headerLabel.text = "Welcome To The Moon! Where Do You Want To Go?"
        headerLabel.textColor = UIColor.white
        headerLabel.backgroundColor = UIColor.black

        // Check if neighborSpheres is empty
        claimAnotherSphereButton.addTarget(self, action: #selector(claimAnotherSphereMethod), for: .touchUpInside)
        NotificationCenter.default.addObserver(self, selector: #selector(handlePurchaseCompletion(_:)), name: .purchaseCompleted, object: nil)

        // Add camera node and animate it
        //setupCamera()
        //animateCamera()
        //createSpheresOnFloor(scene: scene) // Ensure spheres are created on the floor
        //getLocation()
        //setupCamera()
        //animateCamera()
    }

    func refreshLabels() {
        getLocation()
    }

    @objc func handlePurchaseCompletion(_ notification: Notification) {
        Utils.shared.getLocation() {
            DispatchQueue.main.async {
                self.refreshLabels()
            }
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self, name: .purchaseCompleted, object: nil)
    }

    func displayAlert() {
        let alertController = UIAlertController(title: "Functionality Coming Soon",
                                                message: "This functionality will be available soon.",
                                                preferredStyle: .alert)

        let okAction = UIAlertAction(title: "OK", style: .default) { _ in }
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }

    @objc func claimAnotherSphereMethod() {
        if Defaults[.spheresAllowed] > yourSpheres!.count {
            alertToCreateSphere()
        } else {
            //return
            //todo in-app purchase disabled for testflight. todo re-enable when released
            if(MyData.allowInAppPurhcases == 1) {

                if let price = IAPManager.shared.getPrice(for: ProductIdentifiers.newSphere) {
                    showPurchaseAlert(price: price)
                } else {
                    showPurchaseAlert(price: "$0.99")
                    //print("Product price not available")
                }
            }
            else {
                displayAlert()
            }

        }
    }

    func showPurchaseAlert(price: String) {
        let msgText = "Do you want to purchase the ability to claim a new sphere for \(price)?"
        let alertController = UIAlertController(title: "Confirm Purchase: Claim Another Sphere", message: msgText, preferredStyle: .alert)

        let okAction = UIAlertAction(title: "OK", style: .default) { _ in
            self.purchaseNewSphere()
        }
        alertController.addAction(okAction)

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)

        present(alertController, animated: true, completion: nil)
    }

    func purchaseNewSphere() {
        if let product = IAPManager.shared.products.first {
            IAPManager.shared.purchaseProduct(with: ProductIdentifiers.newSphere)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getLocation()
    }

    func refresh() {
        getLocation()
    }

    func setupNeighbor() {
        if let neighborSpheresData = Defaults[.neighborSpheres] as? Data {
            do {
                if let neighborSpheres = try JSONSerialization.jsonObject(with: neighborSpheresData, options: []) as? [[String: Any]], neighborSpheres.isEmpty {
                    let label = UILabel()
                    label.text = "No neighbor spheres found"
                    label.textColor = .white
                    label.textAlignment = .center
                    label.translatesAutoresizingMaskIntoConstraints = false
                    view.addSubview(label)
                    noNeighborSpheresLabel = label

                    NSLayoutConstraint.activate([
                        label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                        label.centerYAnchor.constraint(equalTo: view.centerYAnchor)
                    ])

                    exploreNeighborSphere.isHidden = true
                }
            } catch {
                // Handle JSON serialization error
            }
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    func setupYourSpheres() {
        DispatchQueue.main.async { [self] in
            self.enterYourSphereButton.removeTarget(nil, action: nil, for: .touchUpInside)

            if yourSpheres?.count == 0 {
                self.enterYourSphereButton.setTitle("CLAIM YOUR FIRST SPHERE", for: .normal)
                self.enterYourSphereButton.addTarget(self, action: #selector(claimFirstSphere), for: .touchUpInside)
                self.claimAnotherSphereButton.isHidden = true
            } else {
                self.enterYourSphereButton.setTitle("Enter Your Sphere", for: .normal)
                self.enterYourSphereButton.addTarget(self, action: #selector(goToSphereView), for: .touchUpInside)
                self.claimAnotherSphereButton.isHidden = false
                if Defaults[.spheresAllowed] > yourSpheres!.count {
                    self.claimAnotherSphereButton.setTitle("Claim Another Sphere", for: .normal)
                } else {
                    self.claimAnotherSphereButton.setTitle("Increase Your Sphere Limit", for: .normal)
                }
            }

            if Defaults[.spheresAllowed] > yourSpheres!.count && yourSpheres!.count != 0 {
                alertToCreateSphere()
            }
        }
    }

    func presentSphereSelectionPopup() {
        let alertController = UIAlertController(title: "Select a Sphere", message: "Please choose a sphere to view.", preferredStyle: .alert)

        guard let spheres = self.yourSpheres else {
            return
        }

        for sphere in spheres {
            if let sphereName = sphere["sphere_name"] as? String, let sphereId = sphere["sphere_id"] as? String {
                let action = UIAlertAction(title: sphereName, style: .default) { _ in
                    Defaults[.selectedSphereName] = sphereName
                    Defaults[.selectedSphereId] = sphereId
                    self.performSegue(withIdentifier: "goToSphereView", sender: self)
                }
                alertController.addAction(action)
            }
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)

        self.present(alertController, animated: true, completion: nil)
    }

    @objc func goToSphereView() {
        presentSphereSelectionPopup()
    }

    @objc func claimFirstSphere() {
        alertToCreateSphere()
    }

    func alertToCreateSphere() {
        let alertController = UIAlertController(title: "Name Your Sphere", message: "Please enter a name for your sphere:", preferredStyle: .alert)

        alertController.addTextField { textField in
            textField.placeholder = "Sphere Name"
        }

        let createAction = UIAlertAction(title: "Create", style: .default) { [weak self] _ in
            guard let self = self else { return }
            if let sphereName = alertController.textFields?.first?.text {
                self.createSphere(with: sphereName)
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)

        alertController.addAction(createAction)
        alertController.addAction(cancelAction)

        present(alertController, animated: true)
    }

    func createSphere(with name: String) {
        let email = Defaults[.email]
        let authToken = Defaults[.authToken]

        OpenspaceAPI.shared.createSphere(email: email, authToken: authToken, sphereName: name) { [weak self] result in
            switch result {
            case .success:
                self?.refresh()
            case .failure(let error):
                self?.showAlert(with: "Error", message: error.localizedDescription)
            }
        }
    }

    private func showAlert(with title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }

    func getLocation() {
        guard let email = Defaults[.email] as String?, let authToken = Defaults[.authToken] as String? else {
            return
        }

        OpenspaceAPI.shared.getLocation(email: email, authToken: authToken) { [weak self] result in
            guard let self = self else { return }

            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    self.handleLocationSuccess(data: data)
                case .failure(let error):
                    print("Error: \(error.localizedDescription)")
                }
            }
        }
    }

    private func handleLocationSuccess(data: LocationData) {
        if let yourSpheresArray = data.yourSpheres as? [[String: String]] {
            self.yourSpheres = yourSpheresArray
        } else {
            self.yourSpheres = []
        }

        if let neighborSpheresArray = data.neighborSpheres as? [[String: String]] {
            self.neighborSpheres = neighborSpheresArray
        } else {
            self.neighborSpheres = []
        }
            let sphereCount = self.yourSpheres?.count ?? 0
            let allowedSpheres = data.spheresAllowed ?? 0

            if sphereCount == 1 {
                self.youHaveNumberOfSpheres.text = "   You have \(sphereCount) Sphere. You are allowed \(allowedSpheres) Sphere\(allowedSpheres == 1 ? "" : "s").   "
            } else {
                self.youHaveNumberOfSpheres.text = "   You have \(sphereCount) Spheres. You are allowed \(allowedSpheres) Sphere\(allowedSpheres == 1 ? "" : "s").   "
            }

            do {
                let yourSpheresData = try JSONSerialization.data(withJSONObject: data.yourSpheres ?? [])
                let neighborSpheresData = try JSONSerialization.data(withJSONObject: data.neighborSpheres ?? [])
                Defaults[.yourSpheres] = yourSpheresData
                Defaults[.neighborSpheres] = neighborSpheresData
            } catch {
                print("Error converting spheres data: \(error)")
            }

            if let spaceStation = data.spaceStation,
               let meshLocation = spaceStation["mesh_location"] as? String,
               let previewLocation = spaceStation["preview_location"] as? String,
               let stationName = spaceStation["spacestation_name"] as? String,
               let stationId = spaceStation["station_id"] as? String {

                Defaults[.stationMeshLocation] = meshLocation
                Defaults[.stationPreviewLocation] = previewLocation
                Defaults[.stationName] = stationName
                Defaults[.stationId] = stationId
            }

            Defaults[.currency] = data.currency
            Defaults[.currentEnergy] = data.currentEnergy
            Defaults[.totalEnergy] = data.totalEnergy

            if let passengerLimit = data.passengerLimit {
                Defaults[.passengerLimit] = passengerLimit
            }

            if let cargoLimit = data.cargoLimit {
                Defaults[.cargoLimit] = cargoLimit
            }

            if let premium = data.premium {
                Defaults[.premium] = premium
            }

            if let spheresAllowed = data.spheresAllowed {
                Defaults[.spheresAllowed] = spheresAllowed
            }

            self.setupYourSpheres()
            self.setupNeighbor()

            self.createSpheresOnFloor(scene: self.scene)
            //print("create spheres")

        }
    }

