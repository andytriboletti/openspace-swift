//
//  SpaceStationConfig.swift
//  Open Space
//
//  Created by Andrew Triboletti on 7/15/24.
//  Copyright © 2024 GreenRobot LLC. All rights reserved.
//

import Foundation
import UIKit
import Defaults

struct SpaceStationConfig: Codable {
    var name: String
    var parts: Int
    var torusMajor: Double
    var torusMinor: Double
    var bevelbox: Double
    var cylinder: Double
    var cylinderHeight: Double
    var storage: Double
    var color1: CodableColor
    var color2: CodableColor
    var location: String

    static func generateRandomConfig(locations: [String]) -> SpaceStationConfig {
        let randomNumber = Int.random(in: 1000...9999)
        return SpaceStationConfig(
            name: Defaults[.username] + "'s SpaceStation " + String(randomNumber),
            parts: Int.random(in: 3...8),
            torusMajor: Double.random(in: 2.0...5.0),
            torusMinor: Double.random(in: 0.1...0.5),
            bevelbox: Double.random(in: 0.2...0.5),
            cylinder: Double.random(in: 0.5...3.0),
            cylinderHeight: Double.random(in: 0.3...1.0),
            storage: Double.random(in: 0.5...1.0),
            color1: UIColor.random.codableColor,
            color2: UIColor.random.codableColor,
            location: locations.randomElement() ?? "Low Earth Orbit (LEO)"
        )
    }

}
