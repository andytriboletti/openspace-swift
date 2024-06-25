//
//  FactoryFactory.swift
//  GridHack
//
//  Created by Andy Triboletti on 2/8/20.
//  Copyright © 2020 GreenRobot LLC. All rights reserved.
//

import Foundation
import UIKit
import SceneKit
import SpriteKit
class FactoryFactory {
    static func degreesToRadians(degrees: Double) -> Double { return degrees * .pi / 180.0 }
    static func radiansToDegrees(radians: Double) -> Double { return radians * 180.0 / .pi }

    static func getBearingBetweenTwoPoints1(point1: CGPoint, point2: CGPoint) -> Double {

        var myPoint2 = point2
        // myPoint2.y = point1.y

        let lat1 = degreesToRadians(degrees: Double(point1.x))
        let lon1 = degreesToRadians(degrees: Double(point1.y))

        let lat2 = degreesToRadians(degrees: Double(myPoint2.x))
        let lon2 = degreesToRadians(degrees: Double(myPoint2.y))

        let dLon = lon2 - lon1

        let y = sin(dLon) * cos(lat2)
        let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon)
        let radiansBearing = atan2(y, x)

        return radiansBearing
        // return radiansToDegrees(radians: radiansBearing)
    }

}
