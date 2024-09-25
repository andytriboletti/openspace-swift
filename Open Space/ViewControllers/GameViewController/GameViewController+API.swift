//
//  GameViewController+API.swift
//  Open Space
//
//  Created by Andrew Triboletti on 7/1/24.
//  Copyright © 2024 GreenRobot LLC. All rights reserved.
//

import UIKit
import Defaults

#if targetEnvironment(macCatalyst)

#else
import GoogleMobileAds
#endif

extension GameViewController {

    func getLocation() {
        guard let email = Defaults[.email] as String?, let authToken = Defaults[.authToken] as String? else {
            //print("Email or authToken is missing")
            return
        }

        OpenspaceAPI.shared.getLocation(email: email, authToken: authToken) { [weak self] (result: Result<LocationData, Error>) in
            guard let self = self else { return }

            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    self.handleLocationSuccess(data: data)
                case .failure(let error):
                    print("Error: \(error.localizedDescription)")
                }
            }
        }
    }

    private func handleLocationSuccess(data: LocationData) {
        //print("handleLocationSuccess called with data: \(data)")

        if let username = data.username, !username.isEmpty {
            Defaults[.username] = username
        } else {
            Defaults[.username] = ""
            self.askForUserName()
        }

        do {
            let yourSpheresData = try JSONSerialization.data(withJSONObject: data.yourSpheres ?? [])
            let neighborSpheresData = try JSONSerialization.data(withJSONObject: data.neighborSpheres ?? [])
            Defaults[.yourSpheres] = yourSpheresData
            Defaults[.neighborSpheres] = neighborSpheresData
        } catch {
            //print("Error converting spheres data: \(error)")
        }

        if let spaceStation = data.spaceStation,
           let meshLocation = spaceStation["mesh_location"] as? String,
           let previewLocation = spaceStation["preview_location"] as? String,
           let stationName = spaceStation["spacestation_name"] as? String,
           let stationId = spaceStation["station_id"] as? String {

            Defaults[.stationMeshLocation] = meshLocation
            Defaults[.stationPreviewLocation] = previewLocation
            Defaults[.stationName] = stationName
            Defaults[.stationId] = stationId
        }

        Defaults[.currency] = data.currency
        Defaults[.currentEnergy] = data.currentEnergy
        Defaults[.totalEnergy] = data.totalEnergy

        if let passengerLimit = data.passengerLimit {
            Defaults[.passengerLimit] = passengerLimit
        }

        if let cargoLimit = data.cargoLimit {
            Defaults[.cargoLimit] = cargoLimit
        }

        if let userId = data.userId {
            Defaults[.userId] = userId
        }

        if let premium = data.premium {
            Defaults[.premium] = premium
        }
        if let spheresAllowed = data.spheresAllowed {
            Defaults[.spheresAllowed] = spheresAllowed
        }

        switch data.location {
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
        case "onEarth":
            self.appDelegate.gameState.locationState = .onEarth
        case "onISS":
            self.appDelegate.gameState.locationState = .onISS
        case "onMoon":
            self.appDelegate.gameState.locationState = .onMoon
        case "onMars":
            self.appDelegate.gameState.locationState = .onMars
        case "nearNothing":
            self.appDelegate.gameState.locationState = .nearNothing
        default:
            print("Unknown location: \(data.location)")
        }

        self.setNearFromLocationState()
        self.setCurrencyAndEnergyLabels()

#if targetEnvironment(macCatalyst)

#else

let isPremium = Defaults[.premium]
if(isPremium == 0 && googleAdLoaded == 0) {
    bannerView = GADBannerView(adSize: GADAdSizeBanner)
    bannerView.adSize = GADAdSizeBanner
    addBannerViewToView(bannerView)

    // Set the ad unit ID and view controller that contains the GADBannerView.
#if DEBUG
    bannerView.adUnitID = MyData.testBannerAd
#else
    bannerView.adUnitID = MyData.bannerAd
#endif
    bannerView.rootViewController = self
    bannerView.delegate = self // Set the delegate to receive events

    print("Loading ad with unit ID: \(bannerView.adUnitID)") // Debugging log
    bannerView.load(GADRequest())

    self.googleAdLoaded = 1
}

#endif

    }


    func submitUsername(username: String, completion: @escaping (String?, String?) -> Void) {
        if isValidUsername(username) {
            errorMessage = nil
            self.username = username
            //print("Username set: \(String(describing: self.username))")

            let email = Defaults[.email]

            OpenspaceAPI.shared.submitToServer(username: username, email: email) { result in
                switch result {
                case .success:
                    Defaults[.username] = username
                    //print("Successfully submitted to server")
                    completion(username, nil)
                case .failure(let error):
                    //print("Error submitting to server: \(error.localizedDescription)")
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
