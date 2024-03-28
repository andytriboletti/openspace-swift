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
    case nearGreatWallofChina = "pexels-tom-fisk-1653823_great-wall.jpg"
    case nearTajMahal = "pexels_taj-mahal-india-1603650.jpg"
    case nearPetra = "pexels-abdullah-ghatasheh-1631665.jpg"
    case nearMachuPichu = "pexels-pixabay-259967-machu-picchu.jpg"
    case nearChichenItza = "pexels-alex-azabache-3290068-chicken-itza.jpg"
    case nearColosseum = "pexels-chait-goli-1797161-colosseum.jpg"
    case nearChristTheRedeemer = "pexels-fly-rj-2818895-christ.jpg"
    case nearGreatPyramidOfGiza = "pexels-pixabay-262786-pyramid.jpg"

//
    static func random<G: RandomNumberGenerator>(using generator: inout G) -> EarthLocationState {
        return EarthLocationState.allCases.randomElement(using: &generator)!
    }

    static func random() -> EarthLocationState {
        var srng = SystemRandomNumberGenerator()
        return EarthLocationState.random(using: &srng)
    }

}

extension Dictionary where Key: ExpressibleByStringLiteral {
    subscript<Index: RawRepresentable>(index: Index) -> Value? where Index.RawValue == String {
        get {
            if let key = index.rawValue as? Key {
                return self[key]
            } else {
                // Handle the case where the cast failed (e.g., return a default value or throw an error)
                // For example:
                // return defaultValue
            }
            return nil
        }

        set {
            // self[index.rawValue as! Key] = newValue

            if let key = index.rawValue as? Key {
                self[key] = newValue
            }

        }
    }
}
