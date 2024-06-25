//
//  DumbAI.swift
//  GridHack
//
//  Created by Andy Triboletti on 2/1/20.
//  Copyright © 2020 GreenRobot LLC. All rights reserved.
//

import Foundation
import UIKit
import SceneKit
import SpriteKit

class DumbAI {

    static func selectSquareToBeBuiltRandomly() {
        let appDelegate = UIApplication.shared.delegate as? AppDelegate

        let location = findOpenOnMap(appDelegate: appDelegate!)
        if location == nil {
            // no open locations on map
            return
        }

        GridHackUtils().setEnemyTapped(location: location!)

    }
    static func findOpenOnMap(appDelegate: AppDelegate) -> CGPoint? {
        let myPoints = appDelegate.gridHackGameState.points
        for iii: Int in (1...myPoints.count - 1).reversed() {
            for jjj: Int in (1...myPoints[iii].count - 1).reversed() {
                // half of the time decrease either iii or jjj by 1
                let number = Int.random(in: 0 ..< 3 )
                print("random: \(number)")
                var myIII = iii
                var myJJJ = jjj
                if number == 1 && iii != 1 {
                    myIII = iii - 1
                } else if number == 2 && jjj != 1 {
                    myJJJ = jjj - 1
                }
                let point: GridState = myPoints[myIII][myJJJ]
                if point == GridState.open {
                    return CGPoint(x: myIII, y: myJJJ)
                }
            }
        }
        return nil
    }

}
