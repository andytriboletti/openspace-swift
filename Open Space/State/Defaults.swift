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
    static let earningFromSpheresDaily = Key<Int>("earningFromSpheresDaily", default: 0)
    static let numberOfSpheres = Key<Int>("numberOfSpheres", default: 0)
    static let earningFromObjectsDaily = Key<Int>("earningFromObjectsDaily", default: 0)
    static let theNumberOfObjects = Key<Int>("theNumberOfObjects", default: 0)
    static let hasWatchedOnboarding = Key<Int>("hasWatchedOnboarding", default: 0)

    // When each full-screen ad was last shown (seconds since 1970; 0 = never). See AdPolicy.
    static let lastTravelAdShown = Key<Double>("lastTravelAdShown", default: 0)
    static let lastAppOpenAdShown = Key<Double>("lastAppOpenAdShown", default: 0)

}
import SwiftUI
extension Image {
    static let greenOrange = Image("replicator")
}

import Security

/// The server credential (appToken) and the Firebase ID token are kept in the Keychain,
/// on this device only and out of backups, instead of in UserDefaults (a plain plist).
/// Values an older app version saved in UserDefaults are moved over the first time they're read.
enum AppSecrets {
    static var appToken: String {
        get { value(for: "appToken", legacyKey: .appToken) }
        set { store(newValue, for: "appToken") }
    }

    static var authToken: String {
        get { value(for: "authToken", legacyKey: .authToken) }
        set { store(newValue, for: "authToken") }
    }

    private static let service = "com.greenrobot.openspace.credentials"
    private static var cache: [String: String] = [:]
    private static let lock = NSLock()

    private static func value(for account: String, legacyKey: Defaults.Key<String>) -> String {
        lock.lock(); defer { lock.unlock() }
        if let cached = cache[account] { return cached }

        var result = readKeychain(account) ?? ""
        if result.isEmpty, !Defaults[legacyKey].isEmpty {
            result = Defaults[legacyKey]
            writeKeychain(result, account: account)
        }
        Defaults[legacyKey] = ""   // never leave a copy in UserDefaults
        cache[account] = result
        return result
    }

    private static func store(_ value: String, for account: String) {
        lock.lock(); defer { lock.unlock() }
        writeKeychain(value, account: account)
        cache[account] = value
    }

    private static func baseQuery(_ account: String) -> [String: Any] {
        var query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]
        #if targetEnvironment(macCatalyst)
        query[kSecUseDataProtectionKeychain as String] = true
        #endif
        return query
    }

    private static func writeKeychain(_ value: String, account: String) {
        SecItemDelete(baseQuery(account) as CFDictionary)
        guard !value.isEmpty else { return }
        var query = baseQuery(account)
        query[kSecValueData as String] = Data(value.utf8)
        query[kSecAttrAccessible as String] = kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
        SecItemAdd(query as CFDictionary, nil)
    }

    private static func readKeychain(_ account: String) -> String? {
        var query = baseQuery(account)
        query[kSecReturnData as String] = true
        query[kSecMatchLimit as String] = kSecMatchLimitOne
        var item: CFTypeRef?
        guard SecItemCopyMatching(query as CFDictionary, &item) == errSecSuccess,
              let data = item as? Data else { return nil }
        return String(data: data, encoding: .utf8)
    }
}
