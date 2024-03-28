//
//  LocationCollectionViewCell.swift
//  Open Space
//
//  Created by Andy Triboletti on 2/21/20.
//  Copyright © 2020 GreenRobot LLC. All rights reserved.
//

import UIKit

class LocationCollectionViewCell: UICollectionViewCell {
    @IBOutlet var cellImage: UIImageView!
    @IBOutlet var cellLabel: UILabel?

    override func awakeFromNib() {
        super.awakeFromNib()

        let redView = UIView(frame: bounds)
        redView.backgroundColor = .green
        self.backgroundView = redView

        let blueView = UIView(frame: bounds)
        blueView.backgroundColor = .blue
        self.selectedBackgroundView = blueView
    }

}
