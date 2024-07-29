//
//  FriendlyHackerFactory.swift
//  GridHack
//
//  Created by Andy Triboletti on 2/5/20.
//  Copyright © 2020 GreenRobot LLC. All rights reserved.
//

import Foundation
import UIKit
import SceneKit
import SpriteKit

class FriendlyHackerFactory: FactoryFactory {
    static func spawnHacker(character: MyCharacter?) {
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        let gs = appDelegate!.gridHackGameState
        var myCharacter = character
        let builderLocation = character?.location
        let boxNode = character?.scnNode

        var myBuilderLocation: CGPoint
        if builderLocation == nil {
            let maxCoord = gs!.points.count

            myBuilderLocation = CGPoint(x: 1, y: 1)
        } else {
            myBuilderLocation = builderLocation!
        }

         var myBoxNode: SCNNode?
         var scnNode: SCNNode

        if appDelegate!.team == "bernie" {
            scnNode = (appDelegate?.fistNodeBlue!.clone())!
            scnNode.scale = SCNVector3(0.05, 0.05, 0.05)
        } else {
            scnNode = (appDelegate?.fistNodeRed!.clone())!
            scnNode.scale = SCNVector3(0.05, 0.05, 0.05)

        }

        scnNode.name = "hacker"
        let boxCopy = scnNode.clone() as? SCNNode
        boxCopy!.position.x = Float(0)
        boxCopy!.position.y = Float(0)
        boxCopy!.position.y = Float(2.5)
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
            friendly.characterType="hacker"
            gs!.friendlys!.append(friendly)
            myCharacter = friendly

        } else {
            let firstIndex = gs!.friendlys!.firstIndex(of: myCharacter!)
            if firstIndex != nil {
                gs!.friendlys![firstIndex!].location = myBuilderLocation
            } else {
                //print("first index is nil, can't edit location")
                // assert(false)
                return
            }
            myCharacter = gs!.friendlys![firstIndex!]

        }
        path1.move(to: myBuilderLocation)
        let moveAction = SCNAction.move(to: SCNVector3(x: Float(myBuilderLocation.x), y: Float(myBuilderLocation.y), z: 0.0), duration: 1.0)

        myBoxNode!.runAction(moveAction)

        let closest = GridHackUtils().getClosestEnemyOwned(currentBuilderLocation: myBuilderLocation)
        //print("closest enemy owned:")
        //print(closest)
        if Int(closest.x) == 100 {

            let builder = myCharacter!
            builder.characterType="hacker"
            builder.location = myBuilderLocation
            builder.scnNode = myBoxNode

            gs!.idleHackers!.append(builder)

            GridHackUtils().updateFriendlyLocation(closest: myBuilderLocation, myCharacter: myCharacter)

            setToNoneOwned(closest: myBuilderLocation)
            _ = GridHackUtils().getClosestFriendly(fromCoordinate: myBuilderLocation)

            // //print("returning idle hacker")
            return
        } else {
            var moveAction = SCNAction.move(to: SCNVector3(x: Float(myBuilderLocation.x), y: Float(myBuilderLocation.y), z: 0.0), duration: 0.0)

            let r: Float =    Float(getBearingBetweenTwoPoints1(point1: myCharacter!.location!, point2: closest))

            myBoxNode?.rotation = SCNVector4(0, 1, 0.25, r + 3.14/2)

            myBoxNode!.runAction(moveAction)

            path1.move(to: closest)
            moveAction = SCNAction.moveAlong(path: path1)
            // let repeatAction = SCNAction.repeatForever(moveAction)
            SCNTransaction.begin()

            if appDelegate!.isMultiplayer {
                appDelegate!.multiplayer.enemyMoved(initialPosition: myBuilderLocation, finalPosition: closest, characterType: "hacker")
              }

            SCNTransaction.animationDuration = Double(path1.elements.count) * 0
            myBoxNode!.runAction(moveAction, completionHandler: {

                // set points to under friendly construction
                gs!.points[Int(closest.x)][Int((closest.y))] = GridState.underFriendlyConstruction
                gs!.distanceBetweenEnemyOwnedPoints[Int(closest.x)][Int((closest.y))] = 100

                DispatchQueue.main.asyncAfter(deadline: .now() + GameScene.TIMETOCAPTURE) {

                    // reset the distance at this coordinate to be 100 cause there's no unit here anymore
                    gs!.distanceBetweenFriendlyHackers[Int(myCharacter!.location!.x)][Int((myCharacter!.location!.y))] = 100

                    //print("freed enemy square...onto the next one")

                    setToNoneOwned(closest: closest)

                    GridHackUtils().updateFriendlyLocation(closest: closest, myCharacter: myCharacter)

                    self.spawnHacker(character: myCharacter)
                }

            }
            )
            SCNTransaction.commit()
        }
    }

    static func setToNoneOwned(closest: CGPoint) {
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        let gs = appDelegate!.gridHackGameState

        gs!.points[Int(closest.x)][Int((closest.y))] = GridState.open

        let node = gs!.grid[Int(closest.x)][Int((closest.y))]

        node.geometry = node.geometry!.copy() as? SCNGeometry
        node.geometry?.firstMaterial = node.geometry?.firstMaterial!.copy() as? SCNMaterial
        node.geometry?.firstMaterial?.diffuse.contents = UIColor.lightGray
    }
}
