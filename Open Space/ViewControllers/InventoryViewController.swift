import UIKit
import Defaults

#if targetEnvironment(macCatalyst)
// Exclude GoogleMobileAds for Mac Catalyst
#else
import GoogleMobileAds
#endif

class InventoryViewController: BackgroundImageViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
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
        tableView.register(MineralTableViewCell.self, forCellReuseIdentifier: "MineralCell")
        tableView.translatesAutoresizingMaskIntoConstraints = false


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
        let cargoLimit = Defaults[.cargoLimit]
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
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return minerals.count + 1  // Minerals + 1 for the total row
    }



    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == minerals.count {
            // This is the total row
            let cell = tableView.dequeueReusableCell(withIdentifier: "CargoCell", for: indexPath)

            let totalWeight = minerals.reduce(0.0) { $0 + (Double($1.kilograms) ?? 0.0) }
            cell.textLabel?.text = "Total Minerals on Board: \(totalWeight) kg"
            cell.textLabel?.textColor = .label
            cell.textLabel?.textAlignment = .left  // Align text to the left

            // Set white background for the total row
            //cell.backgroundColor = .white
            //cell.contentView.backgroundColor = .white

            cell.textLabel?.font = UIFont.systemFont(ofSize: 17)
            cell.textLabel?.adjustsFontSizeToFitWidth = true
            cell.textLabel?.minimumScaleFactor = 0.6
            cell.textLabel?.numberOfLines = 1

            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "MineralCell", for: indexPath) as? MineralTableViewCell else {
                return UITableViewCell()
            }

            let mineral = minerals[indexPath.row]
            cell.mineralLabel.text = "Mineral: \(mineral.mineralName)  Weight: \(mineral.kilograms) kg"
            let imageName = mineral.mineralName.lowercased()
            cell.mineralImageView.image = UIImage(named: imageName)

            cell.mineralLabel.font = UIFont.systemFont(ofSize: 17)
            cell.mineralLabel.adjustsFontSizeToFitWidth = true
            cell.mineralLabel.minimumScaleFactor = 0.6
            cell.mineralLabel.numberOfLines = 1

            return cell
        }
    }



    // MARK: - In-App Purchase Methods

    func showSubscriptionManagement() {
        if let url = URL(string: "https://support.apple.com/en-us/HT202039") {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }

    func purchaseUpgradeCargoLimit() {
        if IAPManager.shared.products.first != nil {
            IAPManager.shared.purchaseProduct(with: ProductIdentifiers.upgradeCargoLimit)
        } else {
            //print("Product upgradeCargoLimit not available")
        }
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
    @IBAction func upgradeMaxCargoButtonTapped(_ sender: UIButton) {
        let price = IAPManager.shared.getPrice(for: ProductIdentifiers.upgradeCargoLimit) ?? "$0.99"
        showUpgradeCargoPurchaseAlert(price: price)
    }
}
