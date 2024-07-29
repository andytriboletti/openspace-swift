//
//  EnemyAttackerFactory.swift
//  GridHack
//
//  Created by Andy Triboletti on 2/3/20.
//  Copyright © 2020 GreenRobot LLC. All rights reserved.
//

import Foundation
import SceneKit
import SpriteKit
import UIKit
class EnemyAttackerFactory: FactoryFactory {
// swiftlint:disable:next function_body_length
static func spawnEnemyAttacker(character: MyCharacter?) {
    // swiftlint:disable:function_body_length
    let appDelegate = UIApplication.shared.delegate as? AppDelegate
    let maxCoord = appDelegate!.gridHackGameState.points.count

    var myCharacter = character
    let builderLocation = character?.location
    let boxNode = character?.scnNode

    var myBuilderLocation: CGPoint
    if builderLocation == nil {
        myBuilderLocation = CGPoint(x: maxCoord - 1, y: maxCoord - 1)
        // myBuilderLocation = CGPoint(x: 1 , y: 1)
    } else {
        myBuilderLocation = builderLocation!
    }

    var myBoxNode: SCNNode?
    var scnNode: SCNNode

    if appDelegate!.team == "trump" {
        scnNode = (appDelegate?.bernieProtesterNode!.clone())!
        scnNode.scale = SCNVector3(0.5, 0.5, 0.5)
    } else {
        scnNode = (appDelegate?.trumpProtesterNode!.clone())!
        scnNode.scale = SCNVector3(0.5, 0.5, 0.5)

    }

    let boxCopy = scnNode.clone()
    boxCopy.position.x = Float(myBuilderLocation.x)
    boxCopy.position.y = Float(myBuilderLocation.y)
    boxCopy.position.z = Float(2.5)

    // boxCopy.position.x = Float(0)
    // boxCopy.position.y = Float(0)
    if boxNode == nil {
        appDelegate!.scene!.rootNode.addChildNode(boxCopy)
        myBoxNode = boxCopy
    } else {
        myBoxNode = boxNode
    }

    let path1 = UIBezierPath()
    if myCharacter == nil {

        let enemy = MyCharacter()
        enemy.location = myBuilderLocation
        enemy.scnNode = myBoxNode
        enemy.characterType="attacker"
        appDelegate!.gridHackGameState.enemies!.append(enemy)
        myCharacter = enemy
    } else {
        let firstIndex = appDelegate!.gridHackGameState.enemies!.firstIndex(of: myCharacter!)
        if firstIndex != nil {
            appDelegate!.gridHackGameState.enemies![firstIndex!].location = myBuilderLocation
            myCharacter = appDelegate!.gridHackGameState.enemies![firstIndex!]
        } else {
            return
        }
    }

    path1.move(to: myBuilderLocation)
    var moveAction = SCNAction.move(to: SCNVector3(x: Float(myBuilderLocation.x), y: Float(myBuilderLocation.y), z: 0.0), duration: 1.0)

    myBoxNode!.runAction(moveAction)
    let closest = GridHackUtils().getClosestFriendly(fromCoordinate: myBuilderLocation)

    if closest == nil {

        let builder = myCharacter!
        builder.characterType="attacker"
        builder.location = myBuilderLocation
        builder.scnNode = myBoxNode
        appDelegate!.gridHackGameState.idleEnemyAttackers!.append(builder)

        return
    } else {
        //print("closest friendly to attack with protester:")
        print(closest!.characterType as Any)
        print(closest!.location as Any)
    }

    let r: Float =    Float(getBearingBetweenTwoPoints1(point1: myCharacter!.location!, point2: closest!.location!))

    myBoxNode?.rotation = SCNVector4(0, 1, 0.25, r + 3.14/2)

    path1.move(to: closest!.location!)
    moveAction = SCNAction.moveAlong(path: path1)
    // let repeatAction = SCNAction.repeatForever(moveAction)
    SCNTransaction.begin()
    SCNTransaction.animationDuration = Double(path1.elements.count) * 0
    myBoxNode!.runAction(moveAction, completionHandler: {
        //print("complete")
        if closest != nil {
            appDelegate!.gridHackGameState.distanceBetweenPoints[Int(closest!.location!.x)][Int((closest!.location!.y))] = 100

            DispatchQueue.main.asyncAfter(deadline: .now() + GameScene.TIMETOCAPTUREENEMYUNIT) {
                let friendlyToRemove = GridHackUtils().findFriendlyUnitFromCoordinates(coordinates: closest!.location!, friendlyType: closest?.characterType)
                if friendlyToRemove == nil {
                    //print("no friendly to remove-- spawnEnemyAttacker then returning")
                    if appDelegate!.gridHackGameState.friendlys?.count != 0 {
                        self.spawnEnemyAttacker(character: myCharacter)
                    } else {
                        //print("friendlys is 0 - returning")
                    }
                    return

                }
                appDelegate!.gridHackGameState.distanceBetweenFriendlyBuilders[Int(friendlyToRemove!.location!.x)][Int(friendlyToRemove!.location!.y)] = 100.0

                friendlyToRemove?.scnNode?.removeFromParentNode()
                //print("eliminating friendly unit ...onto the next one")
                let firstIndex = appDelegate!.gridHackGameState.friendlys!.firstIndex(of: friendlyToRemove!)
                appDelegate!.gridHackGameState.friendlys!.remove(at: firstIndex!)

                if friendlyToRemove?.characterType == "attacker" {
                    // it's a tie - both characters disappear
                    //print("it's a tie removing enemy attacker")
                    myBoxNode?.removeFromParentNode()
                    let xInt = Int(myCharacter!.location!.x) - 1
                    let yInt = Int(myCharacter!.location!.y) - 1
                    if appDelegate!.gridHackGameState.distanceBetweenEnemyBuilders.count >= xInt
                        && appDelegate!.gridHackGameState.distanceBetweenEnemyBuilders[xInt].count >= yInt {
                        //print("setting distance between EnemyBuilders to 100")
                        appDelegate!.gridHackGameState.distanceBetweenEnemyBuilders[xInt][yInt] = 100.0

                    } else {
                        //print("not setting distance EnemyBuilders... array out of range")

                    }
                    if appDelegate!.gridHackGameState.distanceBetweenEnemyAttackers.count >= xInt
                        && appDelegate!.gridHackGameState.distanceBetweenEnemyAttackers[xInt].count >= yInt {
                        //print("setting distance between EnemyAttackers to 100")
                        appDelegate!.gridHackGameState.distanceBetweenEnemyAttackers[xInt][yInt] = 100.0

                    } else {
                        //print("not setting distance EnemyAttackers... array out of range")

                    }

                    if appDelegate!.gridHackGameState.distanceBetweenEnemyHackers.count >= xInt
                        && appDelegate!.gridHackGameState.distanceBetweenEnemyHackers[xInt].count >= yInt {
                        //print("setting distance between EnemyHackers to 100")
                        appDelegate!.gridHackGameState.distanceBetweenEnemyAttackers[xInt][yInt] = 100.0

                    } else {
                        //print("not setting distance EnemyHackers... array out of range")

                    }

                    let firstIndex = appDelegate!.gridHackGameState.enemies!.firstIndex(of: myCharacter!)
                    if firstIndex == nil {
                        //print("first index is nil in enemyattackerfactory. returning")
                        return
                    }
                    appDelegate!.gridHackGameState.enemies!.remove(at: firstIndex!)

                } else {
                    //print("it's not a tie... moving enemy attacker")

                    let currentLocation = CGPoint(x: closest!.location!.x, y: closest!.location!.y)
                    myCharacter!.location = currentLocation
                    myCharacter!.scnNode = myBoxNode

                    var firstIndex = appDelegate!.gridHackGameState.enemies?.firstIndex(of: myCharacter!)
                    if firstIndex == nil {
                        //print("enemies doesnt contain character in enemyAttackerFactory.. returning")
                        return
                    }
                    appDelegate!.gridHackGameState.enemies![firstIndex!].location = currentLocation
                    appDelegate!.gridHackGameState.distanceBetweenFriendlyBuilders[Int(currentLocation.x)][Int(currentLocation.y)] = 100
                    appDelegate!.gridHackGameState.distanceBetweenFriendlyAttackers[Int(currentLocation.x)][Int(currentLocation.y)] = 100
                    appDelegate!.gridHackGameState.distanceBetweenFriendlyHackers[Int(currentLocation.x)][Int(currentLocation.y)] = 100

                    firstIndex = appDelegate!.gridHackGameState.enemies!.firstIndex(of: myCharacter!)

                    if firstIndex != nil {
                        appDelegate!.gridHackGameState.enemies![firstIndex!].location = currentLocation
                        self.spawnEnemyAttacker(character: myCharacter)
                    } else {
                        //print("first index is null enemy")
                    }

                }
            }
        }

    }
    )
    SCNTransaction.commit()
}

}
