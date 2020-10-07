//
//  EarthLocationState.swift
//  Open Space
//
//  Created by Andy Triboletti on 3/20/20.
//  Copyright © 2020 GreenRobot LLC. All rights reserved.
//

import Foundation

public enum EarthLocationState: String, CaseIterable {
    //: CaseIterable {
    case nearGreatWallofChina = "pexels-tom-fisk-1653823_great-wall.jpg";
    case nearTajMahal = "pexels_taj-mahal-india-1603650.jpg";
    case nearPetra = "pexels-abdullah-ghatasheh-1631665.jpg";
    //case nearChristTheRedeemer
    //case nearMachuPichu
    //case nearChichenItza
    //case nearColosseum
    //case nearGreatPyramidOfGiza

//
    static func random<G: RandomNumberGenerator>(using generator: inout G) -> EarthLocationState {
        return EarthLocationState.allCases.randomElement(using: &generator)!
    }

    static func random() -> EarthLocationState {
        var g = SystemRandomNumberGenerator()
        return EarthLocationState.random(using: &g)
    }


}

extension Dictionary where Key: ExpressibleByStringLiteral {
    subscript<Index: RawRepresentable>(index: Index) -> Value? where Index.RawValue == String {
        get {
            return self[index.rawValue as! Key]
        }

        set {
            self[index.rawValue as! Key] = newValue
        }
    }
} 
