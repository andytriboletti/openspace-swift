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
                case .success(let (location, username, yourSpheres, neighborSpheres, spaceStation)):
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
                        print("Error converting data")
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

                    switch location {
                    case "nearEarth":
                        self.appDelegate.gameState.locationState = LocationState.nearEarth
                    case "nearISS":
                        self.appDelegate.gameState.locationState = LocationState.nearISS
                    case "nearMoon":
                        self.appDelegate.gameState.locationState = LocationState.nearMoon
                    case "nearMars":
                        self.appDelegate.gameState.locationState = LocationState.nearMars
                    case "nearYourSpaceStation":
                        self.appDelegate.gameState.locationState = LocationState.nearYourSpaceStation
                    case "nearNothing":
                        self.appDelegate.gameState.locationState = LocationState.nearNothing
                    default:
                        print("Unknown location: \(location)")
                    }

                    self.setNearFromLocationState()

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
