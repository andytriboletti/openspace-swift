//
//  GameState.swift
//  Open Space
//
//  Created by Andy Triboletti on 2/21/20.
//  Copyright © 2020 GreenRobot LLC. All rights reserved.
//

import Foundation

class GameState {
    
    var goingToLocationState:LocationState?
    var locationState:LocationState = LocationState.nearEarth
    var earthLocationState:EarthLocationState = EarthLocationState.random()
    //random name generator: https://www.samcodes.co.uk/project/markov-namegen/
    var shipNames:Array = ["Anderik", "Eleuz", "Artophy", "Codile", "Krillow"]
    var currentShipName:String {
        let theName = shipNames[4]
        return theName
    }
    var currentShipModel:String = "spaceshipb.scn"
    var closestOtherPlayerShipModel:String = "space11.dae"
    var closestOtherPlayerShipName:String = "Centa"

}
