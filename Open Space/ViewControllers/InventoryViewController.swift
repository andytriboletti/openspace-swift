import UIKit
import Defaults

class InventoryViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    //@IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var passengerLabel1: UILabel!
    @IBOutlet weak var passengerLabel2: UILabel!
    @IBOutlet weak var cargoLabel1: UILabel!

    var minerals: [OpenspaceAPI.UserMineral] = []  // Use the fully qualified name

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getUserMinerals(email: Defaults[.email])
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        passengerLabel1.text="Ship Passengers - Max: 4 Passengers"
        passengerLabel2.text="4 Passengers onboard, headed to ISS"
        cargoLabel1.text="Ship Cargo - Max 5,000 kg"
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
        print("Number of rows: \(minerals.count)")
        return minerals.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CargoCell", for: indexPath)

        let mineral = minerals[indexPath.row]
        cell.textLabel?.text = "Mineral: \(mineral.mineralName)  Weight: \(mineral.kilograms) kg"

        return cell
    }
}
