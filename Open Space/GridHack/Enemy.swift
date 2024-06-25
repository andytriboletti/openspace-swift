//
//  Enemy.swift
//  GridHack
//
//  Created by Andy Triboletti on 2/4/20.
//  Copyright © 2020 GreenRobot LLC. All rights reserved.
//

import Foundation
import UIKit

class Enemy: AttributeProtcol {
    weak var appDelegate: AppDelegate!

    init() {
        self.appDelegate = UIApplication.shared.delegate as? AppDelegate

    }

    func getBuilderTexture() -> String {
        if appDelegate.team! == "trump" {
            return "instigator_bernie_1024.png"
        } else {
            return "instigator_trump_1024.png"
        }
    }
    func getAttackerTexture() -> String {
        if appDelegate.team! == "trump" {
            return "protester_bernie_1024.png"
        } else {
            return "protester_trump_1024.png"
        }
    }

    func getHackerTexture() -> String {
        if appDelegate.team! == "trump" {
            return "independent_bernie_1024.png"
        } else {
            return "independent_trump_1024.png"
        }
    }

    func getColor() -> UIColor {
        if appDelegate.team! == "bernie" {
            return Trump.getColor()
        } else if appDelegate.team! == "trump" {
            return Bernie.getColor()
        }

        // should not happen
        return UIColor.green
    }
    func getLightColor() -> UIColor {
        if appDelegate.team! == "bernie" {
            return Trump.getLightColor()
        } else if appDelegate.team! == "trump" {
            return Bernie.getLightColor()
        }
        // should not happen
        return UIColor.purple
    }

}
