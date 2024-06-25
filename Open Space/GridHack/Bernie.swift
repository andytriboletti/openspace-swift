//
//  Bernie.swift
//  GridHack
//
//  Created by Andy Triboletti on 2/4/20.
//  Copyright © 2020 GreenRobot LLC. All rights reserved.
//

import Foundation
import UIKit
class Bernie: Candidate {

    static func getColor() -> UIColor {
        return UIColor.blue
    }

    static func getLightColor() -> UIColor {
        // 67.8% red, 84.7% green and 90.2% blue
        return UIColor(red: 0.678, green: 0.847, blue: 0.902, alpha: 1.00)
    }
}
