//
//  GameState.swift
//  Open Space
//
//  Created by Andy Triboletti on 2/21/20.
//  Copyright © 2020 GreenRobot LLC. All rights reserved.
//

import Foundation
import Defaults

class GameState {

    var goingToLocationState: LocationState?
    // var locationState:LocationState = LocationState.nearEarth
    var locationState: LocationState = LocationState.nearMoon
    var earthLocationState: EarthLocationState = EarthLocationState.random()
    // random name generator: https://www.samcodes.co.uk/project/markov-namegen/
    var shipNames: Array = ["Anderik", "Artophy", "Eleuz", "Codile", "Krillow"]
    var currentShipName: String {
        // let theName = shipNames[4]
        // return theName
        return Defaults[.shipName]
    }
    var currentShipModel: String {
        return Defaults[.currentShipModel]
    }
    var closestOtherPlayerShipModel: String = "space11.dae"
    var closestOtherPlayerShipName: String = "Centa"

    var possibleShips: Array = ["anderik.scn", "artophy.scn", "eleuz.scn"]
    var shipNamesAndModels: Dictionary = ["anderik.scn": "Anderik", "artophy.scn": "Artophy", "eleuz.scn": "Eleuz"]

    func getShipName() -> String {
        return self.shipNamesAndModels[self.currentShipName]!
    }
}
