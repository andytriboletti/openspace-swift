import UIKit
import Alamofire
import AlamofireImage
import Defaults

class SelectLocationViewController: AlertViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    var locations: [Int: String] = [:]
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var collectionViewFlowLayout: UICollectionViewFlowLayout!

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.locations.count
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }

    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if (collectionView.cellForItem(at: indexPath) as? LocationCollectionViewCell) != nil {
            // cell.backgroundColor = .green
        }
    }

    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        if collectionView.cellForItem(at: indexPath) != nil {
            // cell.contentView.backgroundColor = .red
        }
    }

    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        if collectionView.cellForItem(at: indexPath) != nil {
            // cell.contentView.backgroundColor = nil
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("selected")
        print(indexPath.row)
        print(indexPath.section)

        if let cell = collectionView.cellForItem(at: indexPath) as? LocationCollectionViewCell {
            // Handle space station selection
//            if indexPath.row == locations.count - 1, let meshLocation = Defaults[.stationMeshLocation] as? String, !meshLocation.isEmpty {
//                goToStationViewController()
//                return
//            }

            // Regular location selection handling
            var goingToLocation = LocationState.allCases[indexPath.row]
            appDelegate.gameState.goingToLocationState = goingToLocation

            var whereString: String

            switch goingToLocation {
            case .nearEarth:
                whereString = "nearEarth"
            case .nearISS:
                whereString = "nearISS"
            case .nearMars:
                whereString = "nearMars"
            case .nearMoon:
                whereString = "nearMoon"
            case .nearYourSpaceStation:
                whereString = "nearYourSpaceStation"
            case .nearNothing:
                whereString = "nearNothing"


            }

            print(whereString) // Output: "premium"

            self.saveLocation(location: whereString)
            Defaults[.traveling] = "true"
            self.performSegue(withIdentifier: "goToGame", sender: self)
        }
    }

    // Navigate to StationViewController
    func goToStationViewController() {
        if let stationVC = storyboard?.instantiateViewController(withIdentifier: "StationViewController") as? StationViewController {
            self.navigationController?.pushViewController(stationVC, animated: true)
        }
    }

    // Save location of user
    func saveLocation(location: String) {
        let email = Defaults[.email] // Replace with the actual email
        let authToken = Defaults[.authToken] // Replace with the actual auth token

        OpenspaceAPI.shared.saveLocation(email: email, authToken: authToken, location: location) { [weak self] message, error in
            if let error = error {
                // Handle the error
                print("Error: \(error.localizedDescription)")
            } else if let message = message {
                // User deleted successfully
                print("Success: \(message)")
            }
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "locationIdentifier", for: indexPath) as? LocationCollectionViewCell else {
            return UICollectionViewCell()
        }

        cell.backgroundColor = .green
        var cellImage: UIImage?

        switch indexPath.row {
        case 0:
            cellImage = UIImage(named: "earth.png")
        case 1:
            cellImage = UIImage(named: "iss.png")
        case 2:
            cellImage = UIImage(named: "moon.png")
        case 3:
            cellImage = UIImage(named: "mars.png")
        case 4:
            if let previewLocation = Defaults[.stationPreviewLocation] as? String, let url = URL(string: previewLocation) {
                cellImage = UIImage(data: try! Data(contentsOf: url))
            }
        default:
            break
        }

        let size = CGSize(width: 100, height: 100)
        let aspectScaledToFitImage = cellImage?.af.imageAspectScaled(toFill: size)
        cell.cellImage.image = aspectScaledToFitImage
        let theText = self.locations[indexPath.row]
        cell.cellLabel?.text = theText

        return cell
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.locations = [0: "Earth", 1: "ISS", 2: "Moon", 3: "Mars"]

        if let stationName = Defaults[.stationName] as? String, !stationName.isEmpty {
            self.locations[4] = stationName
        }

        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical // .horizontal
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 20
        collectionView.setCollectionViewLayout(layout, animated: true)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10.0, left: 10.0, bottom: 10.0, right: 10.0) // here your custom value for spacing
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if let flowLayout = collectionViewLayout as? UICollectionViewFlowLayout {
            let widthPerItem = 200 // collectionView.frame.width / 2 - flowLayout.minimumInteritemSpacing
            return CGSize(width: widthPerItem, height: widthPerItem)
        }

        // Default size if casting fails
        return CGSize(width: 50, height: 50) // You can adjust this default size
    }

    @IBAction func cancel() {
        self.dismiss(animated: false, completion: nil)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
}
