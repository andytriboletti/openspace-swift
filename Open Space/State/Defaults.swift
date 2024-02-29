//
//  Defaults.swift
//  Open Space
//
//  Created by Andy Triboletti on 4/29/21.
//  Copyright © 2021 GreenRobot LLC. All rights reserved.
//

import Defaults

extension Defaults.Keys {
    static let shipName = Key<String>("shipName", default: "anderik.scn")
    //            ^            ^         ^                ^
    //           Key          Type   UserDefaults name   Default value
    static let currentShipModel = Key<String>("currentShipModel", default: "anderik.scn")
    static let email = Key<String>("email", default: "")
    static let username = Key<String>("username", default: "")
    static let authToken = Key<String>("authToken", default: "")

}
