//
//  GameViewController+API.swift
//  Open Space
//
//  Created by Andrew Triboletti on 7/1/24.
//  Copyright © 2024 GreenRobot LLC. All rights reserved.
//

import UIKit
import Defaults

extension GameViewController {
    
    func getLocation() {
        let email = Defaults[.email]
        let authToken = Defaults[.authToken]

        OpenspaceAPI.shared.getLocation(email: email, authToken: authToken) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    let (location, username, yourSpheres, neighborSpheres, spaceStation, currency, currentEnergy, totalEnergy) = data

                    if let username = username, !username.isEmpty {
                        Defaults[.username] = username
                    } else {
                        self.askForUserName()
                    }

                    if let yourSpheresData = try? JSONSerialization.data(withJSONObject: yourSpheres ?? []),
                       let neighborSpheresData = try? JSONSerialization.data(withJSONObject: neighborSpheres ?? []) {
                        Defaults[.yourSpheres] = yourSpheresData
                        Defaults[.neighborSpheres] = neighborSpheresData
                    } else {
                        print("Error converting spheres data")
                    }

                    if let spaceStation = spaceStation,
                       let meshLocation = spaceStation["mesh_location"] as? String,
                       let previewLocation = spaceStation["preview_location"] as? String,
                       let stationName = spaceStation["spacestation_name"] as? String,
                       let stationId = spaceStation["station_id"] as? String {

                        Defaults[.stationMeshLocation] = meshLocation
                        Defaults[.stationPreviewLocation] = previewLocation
                        Defaults[.stationName] = stationName
                        Defaults[.stationId] = stationId
                    }

                    Defaults[.currency] = currency
                    Defaults[.currentEnergy] = currentEnergy
                    Defaults[.totalEnergy] = totalEnergy

                    switch location {
                    case "nearEarth":
                        self.appDelegate.gameState.locationState = .nearEarth
                    case "nearISS":
                        self.appDelegate.gameState.locationState = .nearISS
                    case "nearMoon":
                        self.appDelegate.gameState.locationState = .nearMoon
                    case "nearMars":
                        self.appDelegate.gameState.locationState = .nearMars
                    case "nearYourSpaceStation":
                        self.appDelegate.gameState.locationState = .nearYourSpaceStation
                    case "nearNothing":
                        self.appDelegate.gameState.locationState = .nearNothing
                    default:
                        print("Unknown location: \(location)")
                    }

                    self.setNearFromLocationState()
                    self.setCurrencyAndEnergyLabels()

                case .failure(let error):
                    print("Error fetching location: \(error.localizedDescription)")
                }
            }
        }
    }

    func submitUsername(username: String, completion: @escaping (String?, String?) -> Void) {
        if isValidUsername(username) {
            errorMessage = nil
            self.username = username
            print("Username set: \(String(describing: self.username))")

            let email = Defaults[.email]

            OpenspaceAPI.shared.submitToServer(username: username, email: email) { result in
                switch result {
                case .success:
                    Defaults[.username] = username
                    print("Successfully submitted to server")
                    completion(username, nil)
                case .failure(let error):
                    print("Error submitting to server: \(error.localizedDescription)")
                    completion(nil, "Error submitting to server: \(error.localizedDescription)")
                }
            }
        } else {
            errorMessage = "Username must contain only letters and numbers and be between 3 and 20 characters."
            completion(nil, errorMessage)
        }
    }

    func isValidUsername(_ username: String) -> Bool {
        let usernameRegex = "^[a-zA-Z0-9]{3,20}$"
        let usernamePredicate = NSPredicate(format: "SELF MATCHES %@", usernameRegex)
        return usernamePredicate.evaluate(with: username)
    }

    func sendMessage() {
        webSocketManager.socket.write(string: "Hello, server!")
    }

    func disconnect() {
        webSocketManager.socket.disconnect()
    }
}
