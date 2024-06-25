//
//  File.swift
//  GridHack
//
//  Created by Andy Triboletti on 2/4/20.
//  Copyright © 2020 GreenRobot LLC. All rights reserved.
//

import Foundation
import UIKit
class Friendly: AttributeProtcol {
    weak var appDelegate: AppDelegate!
    init() {
        self.appDelegate = UIApplication.shared.delegate as? AppDelegate
    }
    func getColor() -> UIColor {
        if self.appDelegate.team! == "bernie" {
            return Bernie.getColor()
        } else if self.appDelegate.team! == "trump" {
            return Trump.getColor()
        }

        // should not happen
        return UIColor.green
    }
    func getLightColor() -> UIColor {
        if Friendly().appDelegate.team! == "bernie" {
            return Bernie.getLightColor()
        } else if Friendly().appDelegate.team! == "trump" {
            return Trump.getLightColor()
        }
        // should not happen
        return UIColor.purple
    }

    func getBuilderTexture() -> String {
        if appDelegate.team! == "bernie" {
            return "instigator_bernie_1024.png"
        } else {
            return "instigator_trump_1024.png"
        }
    }
    func getAttackerTexture() -> String {
        if appDelegate.team! == "bernie" {
            return "protester_bernie_1024.png"
        } else {
            return "protester_trump_1024.png"
        }
    }

    func getHackerTexture() -> String {
        if appDelegate.team! == "bernie" {
            return "independent_bernie_1024.png"
        } else {
            return "independent_trump_1024.png"
        }
    }
}
