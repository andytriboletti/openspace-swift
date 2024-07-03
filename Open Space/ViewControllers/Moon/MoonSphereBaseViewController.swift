import UIKit
import SceneKit
import Defaults

class MoonSphereBaseViewController: UIViewController, SCNSceneRendererDelegate {
    @IBOutlet var headerLabel: PaddingLabel!
    @IBOutlet var sceneView: SCNView!

    @IBOutlet var enterYourSphereButton: UIButton!
    @IBOutlet var exploreNeighborSphere: UIButton!
    @IBOutlet var claimAnotherSphereButton: UIButton!
    @IBOutlet var keyLabel: UILabel!
    var noNeighborSpheresLabel: UILabel?

    var yourSpheres: [[String: Any]]?
     var neighborSpheres: [[String: Any]]?
    var scene = SCNScene()
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

        // Create a full-screen SCNView
        // sceneView = SCNView(frame: view.bounds)
        // sceneView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        // view.addSubview(sceneView)

        // Configure the sceneView properties
        sceneView.delegate = self
        sceneView.autoenablesDefaultLighting = true
        sceneView.allowsCameraControl = true

        // Create a new SceneKit scene

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

    }

    func displayAlert() {
        // Create the UIAlertController
        let alertController = UIAlertController(title: "Functionality Coming Soon",
                                                message: "This functionality will be available soon.",
                                                preferredStyle: .alert)

        // Create the OK action
        let okAction = UIAlertAction(title: "OK", style: .default) { _ in
            // Handle OK button tap if needed
        }

        // Add the OK action to the alert controller
        alertController.addAction(okAction)

        // Present the alert controller
        self.present(alertController, animated: true, completion: nil)
    }
    @objc func claimAnotherSphereMethod() {
        displayAlert()

//
//        print("claim another sphere")
//        if let price = IAPManager.shared.getPrice(for: ProductIdentifiers.newSphere) {
//                   showPurchaseAlert(price: price)
//               } else {
//                   showPurchaseAlert(price: "$0.99")
//
//                   print("Product price not available")
//               }
    }

    func showPurchaseAlert(price: String) {
        // Create the alert controller with the price
        let msgText = "Do you want to purchase the ability to claim a new sphere for \(price)?"
        let alertController = UIAlertController(title: "Confirm Purchase: Claim Another Sphere", message: msgText, preferredStyle: .alert)

        // Create OK action
        let okAction = UIAlertAction(title: "OK", style: .default) { _ in
            // Call your method to initiate the purchase here
            self.purchaseNewSphere()
        }
        alertController.addAction(okAction)

        // Create Cancel action
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)

        // Present the alert controller
        present(alertController, animated: true, completion: nil)
    }

    // Call this method to initiate the purchase flow
    func purchaseNewSphere() {
        if let product = IAPManager.shared.products.first {
            IAPManager.shared.purchaseProduct(with: ProductIdentifiers.newSphere)
        } else {
            print("Product not available")
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        getLocation()

    }

    func refresh() {
        getLocation()

    }
    func setupNeighbor() {
        // Check if neighborSpheres is empty
        if let neighborSpheresData = Defaults[.neighborSpheres] as? Data {
            // Attempt to convert data to [[String: Any]]
            do {
                if let neighborSpheres = try JSONSerialization.jsonObject(with: neighborSpheresData, options: []) as? [[String: Any]], neighborSpheres.isEmpty {
                    // Handle the case when neighborSpheres is empty
                    // Create and add the label
                    let label = UILabel()
                    label.text = "No neighbor spheres found"
                    label.textColor = .white
                    label.textAlignment = .center
                    label.translatesAutoresizingMaskIntoConstraints = false
                    view.addSubview(label)
                    noNeighborSpheresLabel = label

                    // Position the label at the center of the view
                    NSLayoutConstraint.activate([
                        label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                        label.centerYAnchor.constraint(equalTo: view.centerYAnchor)
                    ])

                    // Hide the exploreNeighborSphere button
                    exploreNeighborSphere.isHidden = true
                }
            } catch {
                // Handle JSON serialization error
                print("Error: \(error)")
            }
        }

    }
    override var prefersStatusBarHidden: Bool {
        return true // Hide the status bar
    }

    func createFloorNode() -> SCNNode {
        let floor = SCNFloor()
        floor.firstMaterial?.diffuse.contents = UIImage(named: "lroc_color_poles_8k.jpg")

        let floorNode = SCNNode(geometry: floor)
        floorNode.position = SCNVector3(0, 0, 0) // Set the floor's position

        return floorNode
    }
    func setupYourSpheres() {
        // Remove any existing targets
        enterYourSphereButton.removeTarget(nil, action: nil, for: .touchUpInside)

        if yourSpheres?.count == 0 {
            enterYourSphereButton.setTitle("CLAIM YOUR FIRST SPHERE", for: .normal)
            enterYourSphereButton.addTarget(self, action: #selector(claimFirstSphere), for: .touchUpInside)
            claimAnotherSphereButton.isHidden=true

        } else {
            // it's not empty set the action to go to the sphere view
            enterYourSphereButton.setTitle("ENTER YOUR SPHERE", for: .normal)
            enterYourSphereButton.addTarget(self, action: #selector(goToSphereView), for: .touchUpInside)
            claimAnotherSphereButton.isHidden=false
        }
    }

    @objc func goToSphereView() {
        print("go to sphere")
        if let firstSphere = yourSpheres?.first, let sphereName = firstSphere["sphere_name"] as? String {
            print("The sphereName from the first object in yourSpheres is: \(sphereName)")
            let sphereId = firstSphere["sphere_id"] as? String
            Defaults[.selectedSphereName] = sphereName
            Defaults[.selectedSphereId] = sphereId!
            self.performSegue(withIdentifier: "goToSphereView", sender: self)

        } else {
            print("Unable to retrieve sphere_name from the first object in yourSpheres.")
        }

    }
    @objc func claimFirstSphere() {
        let alertController = UIAlertController(title: "Name Your Sphere", message: "Please enter a name for your sphere:", preferredStyle: .alert)

        alertController.addTextField { textField in
            textField.placeholder = "Sphere Name"
        }

        let createAction = UIAlertAction(title: "Create", style: .default) { [weak self] _ in
            guard let self = self else { return }
            if let sphereName = alertController.textFields?.first?.text {
                // Call OpenSpaceAPI function to create the sphere
                self.createSphere(with: sphereName)
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)

        alertController.addAction(createAction)
        alertController.addAction(cancelAction)

        present(alertController, animated: true)
    }

    func createSphere(with name: String) {
        // Call the OpenSpaceAPI function to create the sphere with the provided name
        let email = Defaults[.email]
        let authToken = Defaults[.authToken]
        OpenspaceAPI.shared.createSphere(email: email, authToken: authToken, sphereName: name) { [self] result in
            switch result {
            case .success:
                print("Sphere created successfully")
                refresh()
                // Handle success, if needed
            case .failure(let error):
                print("Error creating sphere: \(error)")
                // Handle error, if needed
            }
        }
    }
    func getLocation() {
        let email = Defaults[.email]
        let authToken = Defaults[.authToken]

        OpenspaceAPI.shared.getLocation(email: email, authToken: authToken) { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success(let (location, username, yourSpheres, neighborSpheres, spaceStation)):
                // Save your_spheres and neighbor_spheres
                self.yourSpheres = yourSpheres
                self.neighborSpheres = neighborSpheres

                // Check if yourSpheres is of the correct type
                if let yourSpheresArray = yourSpheres as? [[String: String]] {
                    self.yourSpheres = yourSpheresArray
                } else {
                    // Handle the case where yourSpheres is not of the correct type or empty
                    self.yourSpheres = []
                }

                // Check if neighborSpheres is of the correct type
                if let neighborSpheresArray = neighborSpheres as? [[String: String]] {
                    self.neighborSpheres = neighborSpheresArray
                } else {
                    // Handle the case where neighborSpheres is not of the correct type or empty
                    self.neighborSpheres = []
                }

                // Save space station data to Defaults
                if let spaceStation = spaceStation,
                   let meshLocation = spaceStation["mesh_location"] as? String,
                   let stationName = spaceStation["spacestation_name"] as? String,
                   let stationId = spaceStation["station_id"] as? String {
                    Defaults[.stationMeshLocation] = meshLocation
                    Defaults[.stationName] = stationName
                    Defaults[.stationId] = stationId
                }

                self.setupYourSpheres()
                self.setupNeighbor()

                // Add the spheres on the floor
                self.createSpheresOnFloor(scene: self.scene)

            case .failure(let error):
                // Handle error
                print("Error: \(error.localizedDescription)")
            }
        }
    }

    func createSpheresOnFloor(scene: SCNScene) {
        let numRows = 5
        let numColumns = 4
        let sphereSize: CGFloat = 1.0
        let spacing: CGFloat = 2.0
        let startX = -(CGFloat(numColumns - 1) * spacing) / 2.0
        let startZ = -(CGFloat(numRows - 1) * spacing) / 2.0

        // Determine the number of owned spheres
        let numOwnedSpheres = yourSpheres!.count

        // Determine the number of neighbor spheres
        let numNeighborSpheres = neighborSpheres!.count // Assuming you calculate this correctly

        for row in 0..<numRows {
            for column in 0..<numColumns {
                let sphere = SCNSphere(radius: sphereSize)

                // Set the color based on the ownership
                if row * numColumns + column < numOwnedSpheres {
                    // Green color for owned spheres
                    sphere.firstMaterial?.diffuse.contents = UIColor.green
                } else if row * numColumns + column < numOwnedSpheres + numNeighborSpheres {
                    // Blue color for neighbor spheres
                    sphere.firstMaterial?.diffuse.contents = UIColor.blue
                } else {
                    // Red color for unowned spheres
                    sphere.firstMaterial?.diffuse.contents = UIColor.red
                }

                let sphereNode = SCNNode(geometry: sphere)
                sphereNode.position = SCNVector3(startX + CGFloat(column) * spacing, 0, startZ + CGFloat(row) * spacing)

                scene.rootNode.addChildNode(sphereNode)
            }
        }
    }

}
