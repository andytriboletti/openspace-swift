//
//  NeighborSphereCellCollectionViewCell.swift
//  Open Space
//
//  Created by Andrew Triboletti on 3/28/24.
//  Copyright © 2024 GreenRobot LLC. All rights reserved.
//

import UIKit
class NeighborSphereCell: UICollectionViewCell {
    let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCell()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupCell()
    }

    func setupCell() {
        addSubview(titleLabel)
        titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    }
}
