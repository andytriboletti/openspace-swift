//
//  Trump.swift
//  GridHack
//
//  Created by Andy Triboletti on 2/4/20.
//  Copyright © 2020 GreenRobot LLC. All rights reserved.
//

import Foundation
import UIKit

class Trump: Candidate {

    static func getColor() -> UIColor {
        return UIColor.red
    }
    static func getLightColor() -> UIColor {
        return UIColor(red: 1.0, green: 0.800, blue: 0.7961, alpha: 1.00)
    }
}
