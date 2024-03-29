//
//  SelectNeighborSphereViewController.swift
//  Open Space
//
//  Created by Andrew Triboletti on 3/28/24.
//  Copyright © 2024 GreenRobot LLC. All rights reserved.
//

import UIKit
import Defaults

class SelectNeighborSphereViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var collectionView: UICollectionView!

    // var data = ["Item 1", "Item 2", "Item 3", "Item 4", "Item 5"]
    var neighbors: [OpenspaceAPI.Neighbor] = []

    func fetchData() {
        let email = Defaults[.email]
        let authToken = Defaults[.authToken]

        OpenspaceAPI.shared.fetchNeighbors(email: email, authToken: authToken) { result in
            switch result {
            case .success(let responseData):
                self.neighbors = responseData
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                }
            case .failure(let error):
                print("Error fetching data: \(error)")
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.dataSource = self
        collectionView.delegate = self

        collectionView.register(NeighborSphereCell.self, forCellWithReuseIdentifier: "neighborSphereCell")
        fetchData()
    }

    // MARK: - UICollectionViewDataSource

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return neighbors.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "neighborSphereCell", for: indexPath) as? NeighborSphereCell else {
                    fatalError("Failed to dequeue NeighborSphereCell.")
                }
        cell.titleLabel.text = neighbors[indexPath.item].username
                return cell
    }

    // MARK: - UICollectionViewDelegateFlowLayout

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 50)
    }
    // MARK: - UICollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
         performSegue(withIdentifier: "NeighborSphereInventorySegue", sender: indexPath)
     }

}
