import UIKit
import Defaults

class SelectNeighborSphereViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var collectionView: UICollectionView!

    var neighbors: [OpenspaceAPI.Neighbor] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.dataSource = self
        collectionView.delegate = self

        // Register the cell class with the identifier
        collectionView.register(NeighborSphereCell.self, forCellWithReuseIdentifier: "neighborSphereCell")

        fetchData()
    }

    func fetchData() {
        let email = Defaults[.email]
        let authToken = Defaults[.authToken]

        OpenspaceAPI.shared.fetchNeighbors(email: email, authToken: authToken) { result in
            switch result {
            case .success(let neighbors):
                self.neighbors = neighbors
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                }
            case .failure(let error):
                print("Error fetching data: \(error)")
            }
        }
    }

    // MARK: - UICollectionViewDataSource

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1 // Assuming there's always one section
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return neighbors.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "neighborSphereCell", for: indexPath) as? NeighborSphereCell else {
            fatalError("Failed to dequeue NeighborSphereCell.")
        }

        // Ensure the index is within bounds
        if indexPath.item < neighbors.count {
            cell.titleLabel.text = neighbors[indexPath.item].username
        } else {
            cell.titleLabel.text = ""
        }

        return cell
    }

    // MARK: - UICollectionViewDelegateFlowLayout

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 50)
    }

    // MARK: - UICollectionViewDelegate

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // Ensure the index is within bounds
        if indexPath.item < neighbors.count {
            Defaults[.neighborUsername] = neighbors[indexPath.item].username
            Defaults[.neighborSphereId] = neighbors[indexPath.item].sphereId
            performSegue(withIdentifier: "NeighborSphereInventorySegue", sender: indexPath)
        }
    }
}
