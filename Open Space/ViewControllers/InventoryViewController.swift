import UIKit
import Defaults

#if targetEnvironment(macCatalyst)
// Exclude GoogleMobileAds for Mac Catalyst
#else
import GoogleMobileAds
#endif

class InventoryViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    //@IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var passengerLabel1: UILabel!
    @IBOutlet weak var passengerLabel2: UILabel!
    @IBOutlet weak var cargoLabel1: UILabel!
    @IBOutlet weak var upgradeButton: UIButton!

#if !targetEnvironment(macCatalyst)
    var rewardedAd: GADRewardedAd?
#endif

    var minerals: [OpenspaceAPI.UserMineral] = []  // Use the fully qualified name

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getUserMinerals(email: Defaults[.email])
    }

    internal func numberOfSections(in tableView: UITableView) -> Int {
       return 2
    }

    func showSubscriptionManagement() {
        if let url = URL(string: "https://support.apple.com/en-us/HT202039") {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    func purchaseUpgradePassengerLimit() {
        if IAPManager.shared.products.first != nil {
            IAPManager.shared.purchaseProduct(with: ProductIdentifiers.upgradePassengerLimit)
        } else {
            print("Product upgradePassengerLimit not available")
        }
    }
    func purchaseUpgradeCargoLimit() {
        if IAPManager.shared.products.first != nil {
            IAPManager.shared.purchaseProduct(with: ProductIdentifiers.upgradeCargoLimit)
        } else {
            print("Product upgradeCargoLimit not available")
        }
    }

    func showUpgradePassengerPurchaseAlert(price: String) {
        // Create the alert controller with the price
        let msgText = "Do you want to purchase an upgrade to Passenger limit +1 for \(price)?"
        let alertController = UIAlertController(title: "Confirm Purchase: Upgrade To Passenger Limit", message: msgText, preferredStyle: .alert)

        // Create OK action
        let okAction = UIAlertAction(title: "OK", style: .default) { _ in
            // Call your method to initiate the purchase here
            self.purchaseUpgradePassengerLimit()
            print("purchase upgrade premium")
        }
        alertController.addAction(okAction)

        // Create Cancel action
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)

        // Present the alert controller
        present(alertController, animated: true, completion: nil)
    }


    func showUpgradeCargoPurchaseAlert(price: String) {
        // Create the alert controller with the price
        let msgText = "Do you want to purchase an upgrade to Cargo Limit +1,000kg for \(price)?"
        let alertController = UIAlertController(title: "Confirm Purchase: Upgrade To Cargo Limit", message: msgText, preferredStyle: .alert)

        // Create OK action
        let okAction = UIAlertAction(title: "OK", style: .default) { _ in
            // Call your method to initiate the purchase here
            self.purchaseUpgradeCargoLimit()
            print("purchase upgrade premium")
        }
        alertController.addAction(okAction)

        // Create Cancel action
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)

        // Present the alert controller
        present(alertController, animated: true, completion: nil)
    }

    @IBAction func upgradeMaxCargoButtonTapped(_ sender: UIButton) {
        // Create an alert controller
        let alertController = UIAlertController(title: "Upgrade Options", message: "Choose an upgrade option:", preferredStyle: .alert)

        // Add the "Upgrade Passenger Limit" action
        let upgradePassengerAction = UIAlertAction(title: "Upgrade Passenger Limit +1", style: .default) { action in
            // Handle the upgrade passenger limit action
            print("Upgrade Passenger Limit +1 selected")
            if let price = IAPManager.shared.getPrice(for: ProductIdentifiers.upgradePassengerLimit) {
                self.showUpgradePassengerPurchaseAlert(price: price)
            } else {
                self.showUpgradePassengerPurchaseAlert(price: "$0.99")
                print("Product price not available")
            }
            //self.showUpgradePassengerPurchaseAlert()
            // Add your code to upgrade passenger limit here
        }

        // Add the "Upgrade Cargo Limit" action
        let upgradeCargoAction = UIAlertAction(title: "Upgrade Cargo Limit +1,000kg", style: .default) { action in
            // Handle the upgrade cargo limit action
            print("Upgrade Cargo Limit +1000kg selected")
            if let price = IAPManager.shared.getPrice(for: ProductIdentifiers.upgradeCargoLimit) {
                self.showUpgradeCargoPurchaseAlert(price: price)
            } else {
                self.showUpgradeCargoPurchaseAlert(price: "$0.99")
                print("Product price not available")
            }
            // Add your code to upgrade cargo limit here
        }

        // Add the "Cancel" action
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { action in
            // Handle the cancel action
            print("Cancel selected")
        }

        // Add actions to the alert controller
        alertController.addAction(upgradePassengerAction)
        alertController.addAction(upgradeCargoAction)
        alertController.addAction(cancelAction)

        // Present the alert controller
        self.present(alertController, animated: true, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        let maxPassengers = Defaults[.passengerLimit]
        let cargoLimit = Defaults[.cargoLimit]

        passengerLabel1.text="Ship Passengers - Max: \(maxPassengers) Passengers"
        passengerLabel2.text="4 Passengers onboard, headed to ISS"
        cargoLabel1.text="Ship Cargo - Max \(cargoLimit) kg"
    }

    func getUserMinerals(email: String) {
        OpenspaceAPI.shared.fetchUserMinerals(email: email) { [weak self] result in
            switch result {
            case .success(let userMinerals):
                self?.minerals = userMinerals
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                    //self?.errorLabel.isHidden = true
                }
            case .failure(let error):
                print("Error fetching user minerals: \(error)")
                DispatchQueue.main.async {
                    //self?.errorLabel.text = "Error fetching minerals"
                    //self?.errorLabel.isHidden = false
                }
            }
        }
    }

    // UITableViewDataSource methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(section == 1) {
            return 1
        }
        else {
            print("Number of rows: \(minerals.count)")
            return minerals.count
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CargoCell", for: indexPath)

        if(indexPath.section == 1) {
            let weight = 1000

            cell.textLabel?.text = "Mission Supplies headed to ISS - Weight: \(weight) kg"
        }
        else {
            let mineral = minerals[indexPath.row]
            cell.textLabel?.text = "Mineral: \(mineral.mineralName)  Weight: \(mineral.kilograms) kg"
        }
        return cell
    }
}
