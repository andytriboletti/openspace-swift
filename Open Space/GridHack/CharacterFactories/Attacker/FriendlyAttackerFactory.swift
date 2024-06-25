//
//  FriendlyAttackerFactory.swift
//  GridHack
//
//  Created by Andy Triboletti on 2/3/20.
//  Copyright © 2020 GreenRobot LLC. All rights reserved.
//

import Foundation
import UIKit
import SceneKit
import SpriteKit
class FriendlyAttackerFactory: FactoryFactory {
    // todo fix this
    // swiftlint:disable:next function_body_length
    static func spawnAttacker(character: MyCharacter?) {

        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        let gs = appDelegate!.gridHackGameState
        var myCharacter = character
        let builderLocation = character?.location
        let boxNode = character?.scnNode

        var myBuilderLocation: CGPoint
        if builderLocation == nil {
            guard let gs = gs else {
                // Handle the case where gs is nil
                print("GridHackGameState is nil")
                return // or continue, or handle the error appropriately
            }

            let maxCoord = gs.points.count

            myBuilderLocation = CGPoint(x: 1, y: 1)
        } else {
            myBuilderLocation = builderLocation!
        }

//        var myBoxNode: SCNNode?
//        let geometry = SCNBox(width: 0.5, height: 0.5,
//                              length: 0.1, chamferRadius: 0.000)
//        let texture = SKTexture(imageNamed: Friendly().getAttackerTexture())
//        geometry.firstMaterial?.diffuse.contents = texture
//        var scnNode = SCNNode(geometry: geometry)
//
        var myBoxNode: SCNNode?
        var scnNode: SCNNode

        if appDelegate!.team == "bernie" {
            scnNode = (appDelegate?.bernieProtesterNode!.clone())!
            scnNode.scale = SCNVector3(0.5, 0.5, 0.5)
        } else {
            scnNode = (appDelegate?.trumpProtesterNode!.clone())!
            scnNode.scale = SCNVector3(0.5, 0.5, 0.5)

        }

        scnNode.name = "attacker"
        let boxCopy = scnNode.clone() as? SCNNode
        boxCopy!.position.x = Float(0)
        boxCopy!.position.y = Float(0)
        boxCopy!.position.z = Float(2.5)

        if boxNode == nil {
            appDelegate!.scene!.rootNode.addChildNode(boxCopy!)
            myBoxNode = boxCopy
        } else {
            myBoxNode = boxNode
        }

        let path1 = UIBezierPath()
        if myCharacter == nil {
            let friendly = MyCharacter()
            friendly.location = myBuilderLocation
            friendly.scnNode = myBoxNode
            friendly.characterType="attacker"
            appDelegate!.gridHackGameState.friendlys!.append(friendly)
            myCharacter = friendly

        } else {
            let firstIndex = appDelegate!.gridHackGameState.friendlys!.firstIndex(of: myCharacter!)
            if firstIndex != nil {
                gs!.friendlys![firstIndex!].location = myBuilderLocation
            } else {
                print("first index is nil in friendly attacker factory, can't edit location... returning")
                return
            }
            myCharacter = gs!.friendlys![firstIndex!]

        }
        path1.move(to: myBuilderLocation)
        var moveAction = SCNAction.move(to: SCNVector3(x: Float(myBuilderLocation.x), y: Float(myBuilderLocation.y), z: 0.0), duration: 1.0)

        myBoxNode!.runAction(moveAction)
        let closest: MyCharacter? = GridHackUtils().getClosestEnemy(fromCoordinate: myBuilderLocation)

        if closest == nil {

            let builder = myCharacter!
            builder.characterType="attacker"
            builder.location = myBuilderLocation
            builder.scnNode = myBoxNode
            gs!.idleAttackers!.append(builder)

            return
        } else {
            print("closest enemy to attack with protester:")
            print(closest!.characterType as Any)
            print(closest!.location as Any)

        }
        let r: Float =    Float(getBearingBetweenTwoPoints1(point1: myCharacter!.location!, point2: closest!.location!))

        myBoxNode?.rotation = SCNVector4(0, 1, 0.25, r + 3.14/2)

        path1.move(to: closest!.location!)
        moveAction = SCNAction.moveAlong(path: path1)
        // let repeatAction = SCNAction.repeatForever(moveAction)
        SCNTransaction.begin()

        if appDelegate!.isMultiplayer {
            appDelegate!.multiplayer.enemyMoved(initialPosition: myBuilderLocation, finalPosition: closest!.location!, characterType: "attacker")
        }

        SCNTransaction.animationDuration = Double(path1.elements.count) * 0
        myBoxNode!.runAction(moveAction, completionHandler: {
            print("complete")
            if closest != nil {
                gs!.distanceBetweenEnemyPoints[Int(closest!.location!.x)][Int((closest!.location!.y))] = 100

                DispatchQueue.main.asyncAfter(deadline: .now() + GameScene.TIMETOCAPTUREENEMYUNIT) {
                    let enemyToRemove = GridHackUtils().findEnemyUnitFromCoordinates(coordinates: closest!.location!, enemyType: closest?.characterType)
                    if enemyToRemove == nil {
                        print("no enemy to remove-- returning")
                        self.spawnAttacker(character: myCharacter)

                        return
                    }
                    GridHackUtils().removeEnemy(enemyToRemove: enemyToRemove!)
                    if appDelegate!.isMultiplayer {
                        appDelegate!.multiplayer.enemyRemoved(position: enemyToRemove!.location!, characterType: enemyToRemove!.characterType!)
                    }

                    if enemyToRemove?.characterType == "attacker" {
                        // it's a tie - both characters disappear
                        print("it's a tie removing friendly attacker")
                        myBoxNode?.removeFromParentNode()
                        let xInt = Int(myCharacter!.location!.x) - 1
                        let yInt = Int(myCharacter!.location!.y) - 1
                        if gs!.distanceBetweenFriendlyBuilders.count >= xInt
                            && gs!.distanceBetweenFriendlyBuilders[xInt].count >= yInt {
                            print("setting distance between units to 100")
                            gs!.distanceBetweenFriendlyBuilders[xInt][yInt] = 100.0

                        } else {
                            assert(false)
                            print("not setting distance... array out of range")

                        }

                        let firstIndex = gs!.friendlys!.firstIndex(of: myCharacter!)
                        if firstIndex == nil {
                            print("can't remove already removed")
                        } else {
                            appDelegate!.gridHackGameState.friendlys!.remove(at: firstIndex!)
                        }
                    } else { // it's a enemy builder or hacker that was removed

                        print("it's not a tie... moving friendly attacker")

                        let currentLocation = CGPoint(x: closest!.location!.x, y: closest!.location!.y)
                        myCharacter!.location = currentLocation
                        myCharacter!.scnNode = myBoxNode

                        var firstIndex = appDelegate!.gridHackGameState.friendlys?.firstIndex(of: myCharacter!)
                        if firstIndex == nil {
                            print("friendlys doesnt contain character in friendlyAttackerFactory.. returning")
                            return
                        }
                        gs!.friendlys![firstIndex!].location = currentLocation
                        gs!.distanceBetweenEnemyBuilders[Int(currentLocation.x)][Int(currentLocation.y)] = 100
                        gs!.distanceBetweenEnemyAttackers[Int(currentLocation.x)][Int(currentLocation.y)] = 100
                        gs!.distanceBetweenEnemyHackers[Int(currentLocation.x)][Int(currentLocation.y)] = 100

                        firstIndex = gs!.friendlys!.firstIndex(of: myCharacter!)

                        if firstIndex != nil {
                            appDelegate!.gridHackGameState.friendlys![firstIndex!].location = currentLocation
                            self.spawnAttacker(character: myCharacter)
                        } else {
                            print("first index is null friendly 2")
                        }

                    }

                }
            }

        }
        )
        SCNTransaction.commit()
    }

}
