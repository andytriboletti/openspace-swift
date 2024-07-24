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
    static let selectedMeshPrompt = Key<String>("selectedMeshPrompt", default: "")
    static let selectedMeshId = Key<Int>("selectedMeshId", default: 0)
    static let traveling = Key<String>("traveling", default: "false")
    static let userId = Key<Int>("userId", default: 0)
    static let premium = Key<Int>("premium", default: 0)
    static let neighborUsername = Key<String>("neighborUsername", default: "")
    static let neighborSphereId = Key<Int>("neighborSphereId", default: -1)
    // New keys for your_spheres and neighbor_spheres
    // New keys for your_spheres and neighbor_spheres
    static let yourSpheres = Key<Data>("yourSpheres", default: Data())
    static let neighborSpheres = Key<Data>("neighborSpheres", default: Data())
    static let selectedSphereName = Key<String>("selectedSphereName", default: "")
    static let selectedSphereId = Key<String>("selectedSphereId", default: "")
    static let team = Key<String>("team", default: "bernie")
    static let stationMeshLocation = Key<String>("stationMeshLocation", default: "")
    static let stationPreviewLocation = Key<String>("stationPreviewLocation", default: "")
    static let stationName = Key<String>("stationName", default: "")
    static let stationId = Key<String>("stationId", default: "")
    static let currency = Key<Int>("currency", default: 1000)
    static let currentEnergy = Key<Int>("currentEnergy", default: 5)
    static let totalEnergy = Key<Int>("totalEnergy", default: 5)
    static let passengerLimit = Key<Int>("passengerLimit", default: 0)
    static let cargoLimit = Key<Int>("cargoLimit", default: 0)
    static let spheresAllowed = Key<Int>("spheresAllowed", default: 0)
    static let appToken = Key<String>("appToken", default: "")

    //minerals
    static let regolithCargoAmount = Key<Int>("regolithCargoAmount", default: 0)
    static let waterIceCargoAmount = Key<Int>("waterIceCargoAmount", default: 0)
    static let helium3CargoAmount = Key<Int>("helium3CargoAmount", default: 0)
    static let silicateCargoAmount = Key<Int>("silicateCargoAmount", default: 0)
    static let jarositeCargoAmount = Key<Int>("jarositeCargoAmount", default: 0)
    static let hematiteCargoAmount = Key<Int>("hematiteCargoAmount", default: 0)
    static let goethiteCargoAmount = Key<Int>("goethiteCargoAmount", default: 0)
    static let opalCargoAmount = Key<Int>("opalCargoAmount", default: 0)

}
