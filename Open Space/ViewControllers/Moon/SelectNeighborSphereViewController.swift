//
//  SelectNeighborSphereViewController.swift
//  Open Space
//
//  Created by Andrew Triboletti on 3/28/24.
//  Copyright © 2024 GreenRobot LLC. All rights reserved.
//

import UIKit
class SelectNeighborSphereViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var collectionView: UICollectionView!

    let data = ["Item 1", "Item 2", "Item 3", "Item 4", "Item 5"]

    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.dataSource = self
        collectionView.delegate = self

        collectionView.register(NeighborSphereCell.self, forCellWithReuseIdentifier: "neighborSphereCell")
    }

    // MARK: - UICollectionViewDataSource

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return data.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "neighborSphereCell", for: indexPath) as? NeighborSphereCell else {
                    fatalError("Failed to dequeue NeighborSphereCell.")
                }
                cell.titleLabel.text = data[indexPath.item]
                return cell
    }

    // MARK: - UICollectionViewDelegateFlowLayout

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 50)
    }
}
