//
//  File.swift
//  Open Space
//
//  Created by Andy Triboletti on 2/22/20.
//  Copyright © 2020 GreenRobot LLC. All rights reserved.
//

public enum LocationState: CaseIterable {
    case nearEarth
    case nearISS
    case nearMoon
    case nearMars
    case nearNothing
    
    static func random<G: RandomNumberGenerator>(using generator: inout G) -> LocationState {
        return LocationState.allCases.randomElement(using: &generator)!
    }

    static func random() -> LocationState {
        var g = SystemRandomNumberGenerator()
        return LocationState.random(using: &g)
    }
}
extension CaseIterable where Self: Equatable {

    var index: Self.AllCases.Index? {
        return Self.allCases.firstIndex { self == $0 }
    }
}
