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
    static let selectedMeshLocation = Key<String>("selectedMeshLocation", default: "")
    static let traveling = Key<String>("traveling", default: "false")
    static let userId = Key<String>("userId", default: "0")
    static let neighborUsername = Key<String>("neighborUsername", default: "")
    // New keys for your_spheres and neighbor_spheres
    // New keys for your_spheres and neighbor_spheres
    static let yourSpheres = Key<Data>("yourSpheres", default: Data())
    static let neighborSpheres = Key<Data>("neighborSpheres", default: Data())
    static let selectedSphereName = Key<String>("selectedSphereName", default: "")
    static let selectedSphereId = Key<String>("selectedSphereId", default: "")
}
