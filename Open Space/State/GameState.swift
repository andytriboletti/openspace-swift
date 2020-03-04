//
//  GameState.swift
//  Open Space
//
//  Created by Andy Triboletti on 2/21/20.
//  Copyright © 2020 GreenRobot LLC. All rights reserved.
//

import Foundation

class GameState {
    var locationState:LocationState = LocationState.nearEarth
    var shipNames:Array = ["Anderik", "Eleuz", "Artophy"]
    var currentShipName:String {
        let theName = shipNames[2]
        return theName
    }
    var currentShipModel:String = "spaceshipb.scn"
    var closestOtherPlayerShipModel:String = "space11.dae"
    var closestOtherPlayerShipName:String = "Centa"

}
