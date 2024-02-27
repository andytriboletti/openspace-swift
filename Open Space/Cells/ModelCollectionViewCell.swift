//
//  ModelCollectionViewCell.swift
//  Open Space
//
//  Created by Andrew Triboletti on 2/27/24.
//  Copyright © 2024 GreenRobot LLC. All rights reserved.
//

import Foundation
import UIKit

class ModelCollectionViewCell: UICollectionViewCell {
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
