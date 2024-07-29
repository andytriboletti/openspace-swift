import UIKit
import Defaults

#if targetEnvironment(macCatalyst)
// Exclude GoogleMobileAds for Mac Catalyst
#else
import GoogleMobileAds
#endif

class InventoryViewController: BackgroundImageViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var passengerLabel1: UILabel!
    @IBOutlet weak var passengerLabel2: UILabel!
    @IBOutlet weak var cargoLabel1: UILabel!
    @IBOutlet weak var upgradeButton: UIButton!

    private var backgroundImageView: UIImageView!
    private var overlayView: UIView!

#if !targetEnvironment(macCatalyst)
    var rewardedAd: GADRewardedAd?
#endif

    var minerals: [OpenspaceAPI.UserMineral] = []  // Use the fully qualified name

    private func calculateBackgroundFrame() -> CGRect {
        let tabBarHeight = tabBarController?.tabBar.frame.height ?? 0
        return CGRect(
            x: 0,
            y: 0,
            width: view.bounds.width,
            height: view.bounds.height - tabBarHeight
        )
    }

    override func viewDidLoad() {
        //backgroundImageName = "conenebula.jpg"
        //overlayAlpha = 0.3 // Adjust as needed

        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(handlePurchaseCompletion(_:)), name: .purchaseCompleted, object: nil)

        view.backgroundColor = .clear
        tableView.backgroundColor = .clear

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "CargoCell")

        //setupBackgroundImageView()
        //setupBackgroundOverlay()
        //applyFilterBasedOnUserInterfaceStyle()

        // Adjust table view insets
        let tabBarHeight = tabBarController?.tabBar.frame.height ?? 0
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: tabBarHeight, right: 0)
        tableView.scrollIndicatorInsets = tableView.contentInset
        //styleButton(upgradeButton)

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //applyFilterBasedOnUserInterfaceStyle()
        getUserMinerals(email: Defaults[.email])
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        refreshLabels()
    }
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            tableView?.reloadData()
        }
    }


//    override func viewDidLayoutSubviews() {
//        super.viewDidLayoutSubviews()
//        let frame = calculateBackgroundFrame()
//        backgroundImageView.frame = frame
//        overlayView.frame = frame
//        //print("Background view frame updated: \(backgroundImageView.frame)")
//        //print("Main view frame: \(view.frame)")
//    }

    deinit {
        NotificationCenter.default.removeObserver(self, name: .purchaseCompleted, object: nil)
    }

//    private func setupBackgroundImageView() {
//        if backgroundImageView == nil {
//            backgroundImageView = UIImageView(frame: calculateBackgroundFrame())
//            backgroundImageView.contentMode = .scaleAspectFill
//            backgroundImageView.clipsToBounds = true
//
//            if let image = UIImage(named: "conenebula.jpg") {
//                backgroundImageView.image = image
//                //print("Background image loaded successfully")
//            } else {
//                //print("Failed to load background image")
//                backgroundImageView.backgroundColor = .red
//            }
//
//            view.insertSubview(backgroundImageView, at: 0)
//        }
//    }

//    private func setupBackgroundOverlay() {
//        overlayView = UIView(frame: calculateBackgroundFrame())
//        overlayView.backgroundColor = .systemBackground.withAlphaComponent(0.4)
//        view.insertSubview(overlayView, aboveSubview: backgroundImageView)
//    }

//    private func applyFilterBasedOnUserInterfaceStyle() {
//        guard let backgroundImage = backgroundImageView.image else {
//            //print("No background image to apply filter to")
//            return
//        }
//
//        let filteredImage: UIImage?
//        if traitCollection.userInterfaceStyle == .dark {
//            filteredImage = backgroundImage // .applyDarkFilter()
//        } else {
//            filteredImage = backgroundImage // .applyLightFilter()
//        }
//
//        if let filteredImage = filteredImage {
//            backgroundImageView.image = filteredImage
//            //print("Filter applied based on user interface style: \(traitCollection.userInterfaceStyle)")
//        } else {
//            //print("Failed to apply filter. Using original image.")
//            backgroundImageView.image = backgroundImage
//        }
//    }
//
//    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
//        super.traitCollectionDidChange(previousTraitCollection)
//        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
//            applyFilterBasedOnUserInterfaceStyle()
//        }
//    }

    @objc func handlePurchaseCompletion(_ notification: Notification) {
        //print("handlePurchaseCompletion called")
        Utils.shared.getLocation() {
            //print("Refreshing labels after location update")
            DispatchQueue.main.async {
                self.refreshLabels()
            }
        }
    }

    func refreshLabels() {
        let maxPassengers = Defaults[.passengerLimit]
        let cargoLimit = Defaults[.cargoLimit]

        passengerLabel1.text = "   Ship Passengers - Max: \(maxPassengers) Passengers   "
        passengerLabel2.text = "   Coming soon: Ability to carry passengers.   "
        cargoLabel1.text = "   Ship Cargo - Max \(cargoLimit) kg   "
    }

    func getUserMinerals(email: String) {
        OpenspaceAPI.shared.fetchUserMinerals(email: email) { [weak self] result in
            switch result {
            case .success(let userMinerals):
                self?.minerals = userMinerals
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
            case .failure(let error):
                print("Error fetching user minerals: \(error)")
            }
        }
    }

    // MARK: - UITableViewDataSource

    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 1 ? 1 : minerals.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CargoCell", for: indexPath)

        cell.backgroundColor = .clear
        cell.contentView.backgroundColor = .clear

        let bgView = UIView()
        bgView.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.3)
        cell.backgroundView = bgView

        if indexPath.section == 1 {
            cell.textLabel?.text = "Coming soon: Ability to carry mission supplies."
        } else {
            let mineral = minerals[indexPath.row]
            cell.textLabel?.text = "Mineral: \(mineral.mineralName)  Weight: \(mineral.kilograms) kg"
        }

        // Use system label color which adapts to the current theme
        cell.textLabel?.textColor = .label

        return cell
    }

    // MARK: - In-App Purchase Methods

    func showSubscriptionManagement() {
        if let url = URL(string: "https://support.apple.com/en-us/HT202039") {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }

    func purchaseUpgradePassengerLimit() {
        if IAPManager.shared.products.first != nil {
            IAPManager.shared.purchaseProduct(with: ProductIdentifiers.upgradePassengerLimit)
        } else {
            //print("Product upgradePassengerLimit not available")
        }
    }

    func purchaseUpgradeCargoLimit() {
        if IAPManager.shared.products.first != nil {
            IAPManager.shared.purchaseProduct(with: ProductIdentifiers.upgradeCargoLimit)
        } else {
            //print("Product upgradeCargoLimit not available")
        }
    }

    func showUpgradePassengerPurchaseAlert(price: String) {
        let msgText = "Do you want to purchase an upgrade to Passenger limit +1 for \(price)?"
        let alertController = UIAlertController(title: "Confirm Purchase: Upgrade To Passenger Limit", message: msgText, preferredStyle: .alert)

        let okAction = UIAlertAction(title: "OK", style: .default) { _ in
            self.purchaseUpgradePassengerLimit()
            //print("purchase upgrade premium")
        }
        alertController.addAction(okAction)

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)

        present(alertController, animated: true, completion: nil)
    }

    func showUpgradeCargoPurchaseAlert(price: String) {
        let msgText = "Do you want to purchase an upgrade to Cargo Limit +1,000kg for \(price)?"
        let alertController = UIAlertController(title: "Confirm Purchase: Upgrade To Cargo Limit", message: msgText, preferredStyle: .alert)

        let okAction = UIAlertAction(title: "OK", style: .default) { _ in
            self.purchaseUpgradeCargoLimit()
            //print("purchase upgrade premium")
        }
        alertController.addAction(okAction)

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)

        present(alertController, animated: true, completion: nil)
    }
    func displayComingSoonAlert() {
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
    @IBAction func upgradeMaxCargoButtonTapped(_ sender: UIButton) {
        //return
        //todo in-app purchase disabled for testflight. todo re-enable when released
        if(MyData.allowInAppPurhcases == 1) {
            
            let alertController = UIAlertController(title: "Upgrade Options", message: "Choose an upgrade option:", preferredStyle: .alert)
            
            let upgradePassengerAction = UIAlertAction(title: "Upgrade Passenger Limit +1", style: .default) { action in
                //print("Upgrade Passenger Limit +1 selected")
                if let price = IAPManager.shared.getPrice(for: ProductIdentifiers.upgradePassengerLimit) {
                    self.showUpgradePassengerPurchaseAlert(price: price)
                } else {
                    self.showUpgradePassengerPurchaseAlert(price: "$0.99")
                    //print("Product price not available")
                }
            }
            
            let upgradeCargoAction = UIAlertAction(title: "Upgrade Cargo Limit +1,000kg", style: .default) { action in
                //print("Upgrade Cargo Limit +1000kg selected")
                if let price = IAPManager.shared.getPrice(for: ProductIdentifiers.upgradeCargoLimit) {
                    self.showUpgradeCargoPurchaseAlert(price: price)
                } else {
                    self.showUpgradeCargoPurchaseAlert(price: "$0.99")
                    //print("Product price not available")
                }
            }
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { action in
                //print("Cancel selected")
            }
            
            alertController.addAction(upgradePassengerAction)
            alertController.addAction(upgradeCargoAction)
            alertController.addAction(cancelAction)
            
            self.present(alertController, animated: true, completion: nil)
        }
        else {
            displayComingSoonAlert()
        }
    }
}
