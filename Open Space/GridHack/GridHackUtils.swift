//
//  Utils.swift
//  GridHack
//
//  Created by Andy Triboletti on 2/1/20.
//  Copyright © 2020 GreenRobot LLC. All rights reserved.
//

import Foundation
import UIKit
import SceneKit
import Alamofire
import FirebaseAuth
import SwiftyJSON
import Defaults

// swiftlint:disable:next type_body_length
class GridHackUtils {

    static func nodeWithFile(path: String) -> SCNNode {

        if let scene = SCNScene(named: path) {

            let node = scene.rootNode.childNodes[0] as SCNNode
            return node

        } else {
            print("Invalid path supplied")
            return SCNNode()
        }

    }

    init() {

    }
    func removeEnemy(enemyToRemove: MyCharacter) {
        GridHackUtils().resetDistanceBetweenEnemyBuilders(location: enemyToRemove.location!)
        GridHackUtils().resetDistanceBetweenEnemyAttackers(location: enemyToRemove.location!)

        enemyToRemove.scnNode?.removeFromParentNode()
        print("eliminating enemy unit ...onto the next one")
        let firstIndex = appDelegate.gridHackGameState.enemies!.firstIndex(of: enemyToRemove)
        appDelegate.gridHackGameState.enemies!.remove(at: firstIndex!)

    }
    func removeFriendly(friendlyToRemove: MyCharacter) {
        GridHackUtils().resetDistanceBetweenFriendlyBuilders(location: friendlyToRemove.location!)
        GridHackUtils().resetDistanceBetweenFriendlyAttackers(location: friendlyToRemove.location!)

        friendlyToRemove.scnNode?.removeFromParentNode()
        print("eliminating friendly unit ...onto the next one")
        let firstIndex = appDelegate.gridHackGameState.friendlys!.firstIndex(of: friendlyToRemove)
        appDelegate.gridHackGameState.friendlys!.remove(at: firstIndex!)
    }
    func resetDistanceBetweenEnemyBuilders(location: CGPoint) {
        appDelegate.gridHackGameState.distanceBetweenEnemyBuilders[Int(location.x)][Int(location.y)] = 100.0
    }
    func resetDistanceBetweenEnemyAttackers(location: CGPoint) {
        appDelegate.gridHackGameState.distanceBetweenEnemyAttackers[Int(location.x)][Int(location.y)] = 100.0
    }
    func resetDistanceBetweenFriendlyBuilders(location: CGPoint) {
        appDelegate.gridHackGameState.distanceBetweenFriendlyBuilders[Int(location.x)][Int(location.y)] = 100.0
    }
    func resetDistanceBetweenFriendlyAttackers(location: CGPoint) {
        appDelegate.gridHackGameState.distanceBetweenFriendlyAttackers[Int(location.x)][Int(location.y)] = 100.0
    }
    func findEnemyUnitFromCoordinates(coordinates: CGPoint, enemyType: String? = nil) -> MyCharacter? {
        for enemy: MyCharacter in appDelegate.gridHackGameState.enemies! {
            if enemy.location == coordinates {
                if enemyType != nil {
                    if enemyType == enemy.characterType {
                        return enemy
                    }
                } else {
                    return enemy
                }
            }
        }
        // else not found
        return nil
    }
    func findFriendlyUnitFromCoordinates(coordinates: CGPoint, friendlyType: String?) -> MyCharacter? {
        for friendly: MyCharacter in appDelegate.gridHackGameState.friendlys! {
            if friendly.location == coordinates {
                if friendlyType != nil {
                    if friendlyType == friendly.characterType {
                        return friendly
                    }
                } else {
                    return friendly
                }

            }
        }
        // else not found
        return nil
    }
    func calcDistanceToEnemyBuilders(fromPoint: CGPoint) {
        for xIndex: Int in 1...appDelegate.gridHackGameState.points[0].count - 1 {
            for yIndex: Int in 1...appDelegate.gridHackGameState.points[xIndex].count - 1 {
                if appDelegate.gridHackGameState.enemies?.count == 0 {
                    return
                }
                for enemy in appDelegate.gridHackGameState.enemies! {
                    if enemy.characterType == "builder" {
                        let dist = distance(enemy.location!, CGPoint(x: xIndex, y: yIndex))
                        appDelegate.gridHackGameState.distanceBetweenEnemyBuilders[xIndex][yIndex] = Float(dist)
                    }
                }
            }
        }
    }

    func calcDistanceToEnemyAttackers(fromPoint: CGPoint) {
        for xIndex: Int in 1...appDelegate.gridHackGameState.points[0].count - 1 {
            for yIndex: Int in 1...appDelegate.gridHackGameState.points[xIndex].count - 1 {
                if appDelegate.gridHackGameState.enemies?.count == 0 {
                    return
                }
                for enemy in appDelegate.gridHackGameState.enemies! {
                    if enemy.characterType == "attacker" {
                        let dist = distance(enemy.location!, CGPoint(x: xIndex, y: yIndex))
                        appDelegate.gridHackGameState.distanceBetweenEnemyAttackers[xIndex][yIndex] = Float(dist)
                    }
                }
            }
        }
    }

    func calcDistanceToFriendlyAttackers(fromPoint: CGPoint) {
        for xIndex: Int in 1...appDelegate.gridHackGameState.points[0].count - 1 {
            for yIndex: Int in 1...appDelegate.gridHackGameState.points[xIndex].count - 1 {
                if appDelegate.gridHackGameState.friendlys?.count == 0 {
                    return
                }
                for unit in appDelegate.gridHackGameState.friendlys! {
                    if unit.characterType == "attacker" {
                        let dist = distance(unit.location!, CGPoint(x: xIndex, y: yIndex))
                        appDelegate.gridHackGameState.distanceBetweenFriendlyAttackers[xIndex][yIndex] = Float(dist)
                    }
                }
            }
        }
    }

    func howManyUnitsOfType(characterString: String) -> Int {
        var howManyUnits = 0
        for unit in appDelegate.gridHackGameState.friendlys! where unit.characterType == characterString {
            howManyUnits += 1
        }
        return howManyUnits
    }
    func howManyFriendlyBuilders() -> Int {
        return howManyUnitsOfType(characterString: "builder")
    }
    func howManyFriendlyAttackers() -> Int {
        return howManyUnitsOfType(characterString: "attacker")
    }
    func howManyFriendlyHackers() -> Int {
        return howManyUnitsOfType(characterString: "hacker")
    }

    func calcDistanceToEnemyHackers(fromPoint: CGPoint) {
        for xIndex: Int in 1...appDelegate.gridHackGameState.points[0].count - 1 {
            for yIndex: Int in 1...appDelegate.gridHackGameState.points[xIndex].count - 1 {
                if appDelegate.gridHackGameState.enemies?.count == 0 {
                    return
                }
                for enemy in appDelegate.gridHackGameState.enemies! {
                    if enemy.characterType == "hacker" {
                        let dist = distance(enemy.location!, CGPoint(x: xIndex, y: yIndex))
                        appDelegate.gridHackGameState.distanceBetweenEnemyHackers[xIndex][yIndex] = Float(dist)
                    }
                }
            }
        }
    }

    func calcDistanceToFriendlyHackers(fromPoint: CGPoint) {
        for xIndex: Int in 1...appDelegate.gridHackGameState.points[0].count - 1 {
            for yIndex: Int in 1...appDelegate.gridHackGameState.points[xIndex].count - 1 {
                if appDelegate.gridHackGameState.friendlys?.count == 0 {
                    return
                }
                for unit in appDelegate.gridHackGameState.friendlys! {
                    if unit.characterType == "hacker" {
                        let dist = distance(unit.location!, CGPoint(x: xIndex, y: yIndex))
                        appDelegate.gridHackGameState.distanceBetweenFriendlyHackers[xIndex][yIndex] = Float(dist)
                    }
                }
            }
        }
    }

    func calcDistanceToFriendlyBuilders(fromPoint: CGPoint) {
        for xIndex: Int in 1...appDelegate.gridHackGameState.points[0].count - 1 {
            for yIndex: Int in 1...appDelegate.gridHackGameState.points[xIndex].count - 1 {
                if appDelegate.gridHackGameState.friendlys?.count == 0 {
                    return
                }
                for friendly in appDelegate.gridHackGameState.friendlys! {
                    if friendly.characterType == "builder" {
                        let dist = distance(friendly.location!, CGPoint(x: xIndex, y: yIndex))
                        appDelegate.gridHackGameState.distanceBetweenFriendlyBuilders[xIndex][yIndex] = Float(dist)
                    }
                }
            }
        }
    }

    func calcDistance(currentBuilderLocation: CGPoint, gridState: GridState) {
        for xIndex: Int in 1...appDelegate.gridHackGameState.points[0].count - 1 {
            for yIndex: Int in 1...appDelegate.gridHackGameState.points[xIndex].count - 1 {
                let dist = distance(currentBuilderLocation, CGPoint(x: xIndex, y: yIndex))
                let thisPoint = appDelegate.gridHackGameState.points[xIndex][yIndex]
                if thisPoint == gridState {
                    // determine to use distanceBetween points for self or for enemy
                    if gridState == GridState.waitingForFriendlyConstruction {
                        appDelegate.gridHackGameState.distanceBetweenPoints[xIndex][yIndex] = Float(dist)
                    } else if gridState == GridState.underFriendlyConstruction {
                            // appDelegate.gridHackGameState.distanceBetweenPoints[xIndex][yIndex] = Float(d)
                    } else if gridState == GridState.waitingForEnemyConstruction {
                         appDelegate.gridHackGameState.distanceBetweenEnemyPoints[xIndex][yIndex] = Float(dist)
                     } else if gridState == GridState.underEnemyConstruction {
                             // appDelegate.gridHackGameState.distanceBetweenEnemyPoints[xIndex][yIndex] = Float(d)
                    } else if gridState == GridState.enemyOwned {
                        appDelegate.gridHackGameState.distanceBetweenEnemyOwnedPoints[xIndex][yIndex] = Float(dist)
                    } else if gridState == GridState.friendlyOwned {
                        appDelegate.gridHackGameState.distanceBetweenFriendlyOwnedPoints[xIndex][yIndex] = Float(dist)
                    }
                }
            }
        }
    }

    func getClosestEnemy(fromCoordinate: CGPoint) -> MyCharacter? {
        calcDistanceToEnemyBuilders(fromPoint: fromCoordinate)
        let coord = minEnemyBuilderLocationInArray()
        let exists = doesEnemyExistAtLocation(coord: coord)
        if exists {
            let myCharacter = MyCharacter()
            myCharacter.characterType = "builder"
            myCharacter.location = coord
            return myCharacter
        } else {
            calcDistanceToEnemyHackers(fromPoint: fromCoordinate)
            let coord = minEnemyHackerLocationInArray()
            let exists = doesEnemyExistAtLocation(coord: coord)
            if exists {
                let myCharacter = MyCharacter()
                myCharacter.characterType = "hacker"
                myCharacter.location = coord
                return myCharacter
            } else {
                calcDistanceToEnemyAttackers(fromPoint: fromCoordinate)
                let coord = minEnemyAttackerLocationInArray()
                let exists = doesEnemyExistAtLocation(coord: coord)
                if exists {
                    let myCharacter = MyCharacter()
                    myCharacter.characterType = "attacker"
                    myCharacter.location = coord
                    return myCharacter
                }

            }
        }
        return nil
    }
    func getClosestFriendly(fromCoordinate: CGPoint) -> MyCharacter? {
        calcDistanceToFriendlyBuilders(fromPoint: fromCoordinate)
        let coord = minFriendlyBuilderLocationInArray()
        let exists = doesFriendlyExistAtLocation(coord: coord)
        if exists {
            print("get closest friendly coordinates from point \(coord)")
            let myCharacter = MyCharacter()
            myCharacter.characterType = "builder"
            myCharacter.location = coord
            return myCharacter

        } else {
            calcDistanceToFriendlyHackers(fromPoint: fromCoordinate)
            let coord = minFriendlyHackerLocationInArray()
            let exists = doesFriendlyExistAtLocation(coord: coord)
            if exists {
                print("get closest friendly coordinates from point \(coord)")
                let myCharacter = MyCharacter()
                myCharacter.characterType = "hacker"
                myCharacter.location = coord
                return myCharacter

            } else {
                calcDistanceToFriendlyAttackers(fromPoint: fromCoordinate)
                let coord = minFriendlyAttackerLocationInArray()
                let exists = doesFriendlyExistAtLocation(coord: coord)
                if exists {
                    print("get closest friendly coordinates from point \(coord)")
                    let myCharacter = MyCharacter()
                    myCharacter.characterType = "attacker"
                    myCharacter.location = coord
                    return myCharacter

                }

            }
        }
        return nil
    }

    func setEnemyTapped(location: CGPoint) {
        let tappedNode = appDelegate.gridHackGameState.grid[Int(location.x)][Int(location.y)]
        // set to not open in point array
        appDelegate.gridHackGameState.points[Int(tappedNode.position.x)][Int((tappedNode.position.y))] = GridState.waitingForEnemyConstruction

        let node = tappedNode
        node.geometry = node.geometry!.copy() as? SCNGeometry
        node.geometry?.firstMaterial = node.geometry?.firstMaterial!.copy() as? SCNMaterial
        node.geometry?.firstMaterial?.diffuse.contents = Enemy().getLightColor()
    }
    func doesFriendlyExistAtLocation(coord: CGPoint) -> Bool {
        if appDelegate.gridHackGameState.friendlys == nil {
            return false
        }

        for friendly in appDelegate.gridHackGameState.friendlys! {
            print("hi")
            if friendly.location == coord {
                return true
            }
        }
        return false
    }
    func doesEnemyAttackerExistAtLocation(coord: CGPoint) -> Bool {
        if appDelegate.gridHackGameState.enemies == nil {
            return false
        }

        for enemy in appDelegate.gridHackGameState.enemies! {
            if enemy.location == coord && enemy.characterType == "attacker" {
                return true
            }
        }
        return false
    }
    func doesFriendlyAttackerExistAtLocation(coord: CGPoint) -> Bool {
        if appDelegate.gridHackGameState.friendlys == nil {
            return false
        }

        for unit in appDelegate.gridHackGameState.friendlys! {
            if unit.location == coord && unit.characterType == "attacker" {
                return true
            }
        }
        return false
    }
    func doesEnemyExistAtLocation(coord: CGPoint) -> Bool {
        if appDelegate.gridHackGameState.enemies == nil {
            return false
        }

        for enemy in appDelegate.gridHackGameState.enemies! {
            //            print("hi enemies")
            if enemy.location == coord {
                return true
            }
        }
        return false
    }

    func getClosestPendingConstruction(currentBuilderLocation: CGPoint) -> CGPoint {
        calcDistance(currentBuilderLocation: currentBuilderLocation, gridState: GridState.waitingForFriendlyConstruction)
        return minLocationInArray()
    }

    func getClosestPendingEnemyConstruction(currentBuilderLocation: CGPoint) -> CGPoint {
        calcDistance(currentBuilderLocation: currentBuilderLocation, gridState: GridState.waitingForEnemyConstruction)
        return minEnemyLocationInArray()
    }
    func getClosestEnemyOwned(currentBuilderLocation: CGPoint) -> CGPoint {
        calcDistance(currentBuilderLocation: currentBuilderLocation, gridState: GridState.enemyOwned)
        return minEnemyOwnedLocationInArray()
    }
    func getClosestFriendlyOwned(currentBuilderLocation: CGPoint) -> CGPoint {
        calcDistance(currentBuilderLocation: currentBuilderLocation, gridState: GridState.friendlyOwned)
        return minFriendlyOwnedLocationInArray()
    }

    func minLocationInArray() -> CGPoint {

        var lowestValue: Float = 100.0
        var lowestXLocation = 100
        var lowestYLocation = 100
        for xIndex: Int in 1...appDelegate.gridHackGameState.distanceBetweenPoints[0].count - 1 {
            for yIndex: Int in 1...appDelegate.gridHackGameState.distanceBetweenPoints[xIndex].count - 1 {
                if appDelegate.gridHackGameState.distanceBetweenPoints[xIndex][yIndex] < lowestValue {
                    lowestValue = appDelegate.gridHackGameState.distanceBetweenPoints[xIndex][yIndex]
                    lowestXLocation = xIndex
                    lowestYLocation = yIndex
                }
            }
        }
        return CGPoint(x: lowestXLocation, y: lowestYLocation)

    }

    func minEnemyBuilderLocationInArray() -> CGPoint {

        var lowestValue: Float = 100.0
        var lowestXLocation = 100
        var lowestYLocation = 100
        for xIndex: Int in 1...appDelegate.gridHackGameState.distanceBetweenEnemyBuilders[0].count - 1 {
            for yIndex: Int in 1...appDelegate.gridHackGameState.distanceBetweenEnemyBuilders[xIndex].count - 1 {
                if appDelegate.gridHackGameState.distanceBetweenEnemyBuilders[xIndex][yIndex] < lowestValue {
                    lowestValue = appDelegate.gridHackGameState.distanceBetweenEnemyBuilders[xIndex][yIndex]
                    lowestXLocation = xIndex
                    lowestYLocation = yIndex
                }
            }
        }
        return CGPoint(x: lowestXLocation, y: lowestYLocation)

    }

    func minEnemyAttackerLocationInArray() -> CGPoint {

        var lowestValue: Float = 100.0
        var lowestXLocation = 100
        var lowestYLocation = 100
        for xIndex: Int in 1...appDelegate.gridHackGameState.distanceBetweenEnemyAttackers[0].count - 1 {
            for yIndex: Int in 1...appDelegate.gridHackGameState.distanceBetweenEnemyAttackers[xIndex].count - 1 {
                if appDelegate.gridHackGameState.distanceBetweenEnemyAttackers[xIndex][yIndex] < lowestValue {
                    lowestValue = appDelegate.gridHackGameState.distanceBetweenEnemyAttackers[xIndex][yIndex]
                    lowestXLocation = xIndex
                    lowestYLocation = yIndex
                }
            }
        }
        return CGPoint(x: lowestXLocation, y: lowestYLocation)

    }

    func minFriendlyAttackerLocationInArray() -> CGPoint {

        var lowestValue: Float = 100.0
        var lowestXLocation = 100
        var lowestYLocation = 100
        for xIndex: Int in 1...appDelegate.gridHackGameState.distanceBetweenFriendlyAttackers[0].count - 1 {
            for yIndex: Int in 1...appDelegate.gridHackGameState.distanceBetweenFriendlyAttackers[xIndex].count - 1 {
                if appDelegate.gridHackGameState.distanceBetweenFriendlyAttackers[xIndex][yIndex] < lowestValue {
                    lowestValue = appDelegate.gridHackGameState.distanceBetweenFriendlyAttackers[xIndex][yIndex]
                    lowestXLocation = xIndex
                    lowestYLocation = yIndex
                }
            }
        }
        return CGPoint(x: lowestXLocation, y: lowestYLocation)

    }

    func minEnemyHackerLocationInArray() -> CGPoint {

        var lowestValue: Float = 100.0
        var lowestXLocation = 100
        var lowestYLocation = 100
        for xIndex: Int in 1...appDelegate.gridHackGameState.distanceBetweenEnemyHackers[0].count - 1 {
            for yIndex: Int in 1...appDelegate.gridHackGameState.distanceBetweenEnemyHackers[xIndex].count - 1 {
                if appDelegate.gridHackGameState.distanceBetweenEnemyHackers[xIndex][yIndex] < lowestValue {
                    lowestValue = appDelegate.gridHackGameState.distanceBetweenEnemyHackers[xIndex][yIndex]
                    lowestXLocation = xIndex
                    lowestYLocation = yIndex
                }
            }
        }
        return CGPoint(x: lowestXLocation, y: lowestYLocation)

    }

    func minFriendlyHackerLocationInArray() -> CGPoint {

        var lowestValue: Float = 100.0
        var lowestXLocation = 100
        var lowestYLocation = 100
        for xIndex: Int in 1...appDelegate.gridHackGameState.distanceBetweenFriendlyHackers[0].count - 1 {
            for yIndex: Int in 1...appDelegate.gridHackGameState.distanceBetweenFriendlyHackers[xIndex].count - 1 {
                if appDelegate.gridHackGameState.distanceBetweenFriendlyHackers[xIndex][yIndex] < lowestValue {
                    lowestValue = appDelegate.gridHackGameState.distanceBetweenFriendlyHackers[xIndex][yIndex]
                    lowestXLocation = xIndex
                    lowestYLocation = yIndex
                }
            }
        }
        return CGPoint(x: lowestXLocation, y: lowestYLocation)

    }

    func minFriendlyBuilderLocationInArray() -> CGPoint {

        var lowestValue: Float = 100.0
        var lowestXLocation = 100
        var lowestYLocation = 100
        for xIndex: Int in 1...appDelegate.gridHackGameState.distanceBetweenFriendlyBuilders[0].count - 1 {
            for yIndex: Int in 1...appDelegate.gridHackGameState.distanceBetweenFriendlyBuilders[xIndex].count - 1 {
                if appDelegate.gridHackGameState.distanceBetweenFriendlyBuilders[xIndex][yIndex] < lowestValue {
                    lowestValue = appDelegate.gridHackGameState.distanceBetweenFriendlyBuilders[xIndex][yIndex]
                    lowestXLocation = xIndex
                    lowestYLocation = yIndex
                }
            }
        }
        return CGPoint(x: lowestXLocation, y: lowestYLocation)

    }

    func minEnemyLocationInArray() -> CGPoint {

        var lowestValue: Float = 100.0
        var lowestXLocation = 100
        var lowestYLocation = 100
        for xIndex: Int in 1...appDelegate.gridHackGameState.distanceBetweenEnemyPoints[0].count - 1 {
            for yIndex: Int in 1...appDelegate.gridHackGameState.distanceBetweenEnemyPoints[xIndex].count - 1 {
                if appDelegate.gridHackGameState.distanceBetweenEnemyPoints[xIndex][yIndex] < lowestValue {
                    lowestValue = appDelegate.gridHackGameState.distanceBetweenEnemyPoints[xIndex][yIndex]
                    lowestXLocation = xIndex
                    lowestYLocation = yIndex
                }
            }
        }
        return CGPoint(x: lowestXLocation, y: lowestYLocation)

    }
    func minEnemyOwnedLocationInArray() -> CGPoint {

        var lowestValue: Float = 100.0
        var lowestXLocation = 100
        var lowestYLocation = 100
        for xIndex: Int in 1...appDelegate.gridHackGameState.distanceBetweenEnemyOwnedPoints[0].count - 1 {
            for yIndex: Int in 1...appDelegate.gridHackGameState.distanceBetweenEnemyOwnedPoints[xIndex].count - 1 {
                if appDelegate.gridHackGameState.distanceBetweenEnemyOwnedPoints[xIndex][yIndex] < lowestValue {
                    lowestValue = appDelegate.gridHackGameState.distanceBetweenEnemyOwnedPoints[xIndex][yIndex]
                    lowestXLocation = xIndex
                    lowestYLocation = yIndex
                }
            }
        }
        return CGPoint(x: lowestXLocation, y: lowestYLocation)

    }
    func minFriendlyOwnedLocationInArray() -> CGPoint {

        var lowestValue: Float = 100.0
        var lowestXLocation = 100
        var lowestYLocation = 100
        for xIndex: Int in 1...appDelegate.gridHackGameState.distanceBetweenFriendlyOwnedPoints[0].count - 1 {
            for yIndex: Int in 1...appDelegate.gridHackGameState.distanceBetweenFriendlyOwnedPoints[xIndex].count - 1 {
                if appDelegate.gridHackGameState.distanceBetweenFriendlyOwnedPoints[xIndex][yIndex] < lowestValue {
                    lowestValue = appDelegate.gridHackGameState.distanceBetweenFriendlyOwnedPoints[xIndex][yIndex]
                    lowestXLocation = xIndex
                    lowestYLocation = yIndex
                }
            }
        }
        return CGPoint(x: lowestXLocation, y: lowestYLocation)

    }

    func distance(_ aaa: CGPoint, _ bbb: CGPoint) -> CGFloat {
        return aaa.distance(to: bbb)
    }

    func pickPartyNoNetwork(party: String, delegate: PartyDelegate) {
        if(party == "bernie") {
            Defaults[.team] = "bernie"
        }
        else if(party == "trump") {
            Defaults[.team] = "trump"
        }
        delegate.updatedParty()

    }
    func pickParty(party: String, delegate: PartyDelegate) {
        let url = Common.baseUrl + "pick_party.php"
        let parameters: Parameters = [
            "firebase_uid": Auth.auth().currentUser!.uid,
            "party": party
        ]

        _ = appDelegate.session.request(url, method: .post, parameters: parameters).responseJSON(completionHandler: { (data: DataResponse) in
            // print(data.response.debugDescription)
            let json = JSON(data.value as Any)

            print("update party")
            print(json)
            let result: String = json["result"].stringValue
            if result == "success" {
                print("success updating party")
                delegate.updatedParty()

            } else {
                print("error updating party")
                print(parameters.description)
            }
        })
    }

    func updateFriendlyLocation(closest: CGPoint, myCharacter: MyCharacter?) {

        let currentLocation = CGPoint(x: closest.x, y: closest.y)
        myCharacter!.location = currentLocation
        let firstIndex = appDelegate.gridHackGameState.friendlys?.firstIndex(of: myCharacter!)
        if firstIndex != nil {
            appDelegate.gridHackGameState.friendlys![firstIndex!].location = currentLocation
        } else {
            print("first index is null in update friendly location")
        }
    }
    func updateEnemyLocation(closest: CGPoint, myCharacter: MyCharacter?) {

        let currentLocation = CGPoint(x: closest.x, y: closest.y)
        myCharacter!.location = currentLocation
        let firstIndex = appDelegate.gridHackGameState.enemies?.firstIndex(of: myCharacter!)
        if firstIndex != nil {
            appDelegate.gridHackGameState.enemies![firstIndex!].location = currentLocation
        } else {
            print("first index is null in update enemy location")
        }
    }

    func setToFriendlyOwned(closest: CGPoint) {
        if self.doesEnemyAttackerExistAtLocation(coord: closest) {
            print("enemy attacker exists... not setting to friendly owned")
            return
        }

        let currentPoint = appDelegate.gridHackGameState.points[Int(closest.x)][Int((closest.y))]
        if currentPoint == GridState.waitingForFriendlyConstruction {

            appDelegate.gridHackGameState.points[Int(closest.x)][Int((closest.y))] = GridState.friendlyOwned
        } else if currentPoint == GridState.underFriendlyConstruction {
            appDelegate.gridHackGameState.points[Int(closest.x)][Int((closest.y))] = GridState.friendlyOwned
        }

        let node = appDelegate.gridHackGameState.grid[Int(closest.x)][Int((closest.y))]

        node.geometry = node.geometry!.copy() as? SCNGeometry
        node.geometry?.firstMaterial = node.geometry?.firstMaterial!.copy() as? SCNMaterial
        node.geometry?.firstMaterial?.diffuse.contents = Friendly().getColor()
     }

    func setToEnemyOwned(closest: CGPoint) {
        if self.doesFriendlyAttackerExistAtLocation(coord: closest) {
            print("friendly attacker exists... not setting to enemy owned")
            return
        }

        let currentPoint = appDelegate.gridHackGameState.points[Int(closest.x)][Int((closest.y))]
        if currentPoint == GridState.waitingForEnemyConstruction {
            appDelegate.gridHackGameState.points[Int(closest.x)][Int((closest.y))] = GridState.enemyOwned
        } else if currentPoint == GridState.underEnemyConstruction {
            appDelegate.gridHackGameState.points[Int(closest.x)][Int((closest.y))] = GridState.enemyOwned
        }
        let node = appDelegate.gridHackGameState.grid[Int(closest.x)][Int((closest.y))]

        node.geometry = node.geometry!.copy() as? SCNGeometry
        node.geometry?.firstMaterial = node.geometry?.firstMaterial!.copy() as? SCNMaterial
        node.geometry?.firstMaterial?.diffuse.contents = Enemy().getColor()
    }
    func modelIdentifier() -> String {
        if let simulatorModelIdentifier = ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] { return simulatorModelIdentifier }
        var sysinfo = utsname()
        uname(&sysinfo) // ignore return value
        return String(bytes: Data(bytes: &sysinfo.machine, count: Int(_SYS_NAMELEN)), encoding: .ascii)!.trimmingCharacters(in: .controlCharacters)
    }

}
