//
//  Defaults.swift
//  Open Space
//
//  Created by Andy Triboletti on 4/29/21.
//  Copyright © 2021 GreenRobot LLC. All rights reserved.
//

import Defaults

extension Defaults.Keys {
    static let shipName = Key<String>("shipName", default: "Kristoff")
    //            ^            ^         ^                ^
    //           Key          Type   UserDefaults name   Default value
}
