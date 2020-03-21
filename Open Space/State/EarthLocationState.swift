//
//  EarthLocationState.swift
//  Open Space
//
//  Created by Andy Triboletti on 3/20/20.
//  Copyright © 2020 GreenRobot LLC. All rights reserved.
//

import Foundation

public enum EarthLocationState: CaseIterable {
    case nearGreatWallofChina
    case nearPetra
    case nearChristTheRedeemer
    case nearMachuPichu
    case nearChichenItza
    case nearColosseum
    case nearTajMahal
    case nearGreatPyramidOfGiza
    //[0: "Great Wall of China", 1: "Petra", 2: "Christ the Redeemer", 3: "Machu Picchu", 4: "Chichen Itza", 5: "Colosseum", 6: "Taj Mahal", 7: "Great Pyramid of Giza"]
    
    static func random<G: RandomNumberGenerator>(using generator: inout G) -> EarthLocationState {
        return EarthLocationState.allCases.randomElement(using: &generator)!
    }

    static func random() -> EarthLocationState {
        var g = SystemRandomNumberGenerator()
        return EarthLocationState.random(using: &g)
    }
}
