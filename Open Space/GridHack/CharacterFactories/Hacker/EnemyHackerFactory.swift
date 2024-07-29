//
//  EnemyHackerFactory.swift
//  GridHack
//
//  Created by Andy Triboletti on 2/5/20.
//  Copyright © 2020 GreenRobot LLC. All rights reserved.
//

import Foundation
import UIKit
import SceneKit
import SpriteKit

class EnemyHackerFactory: FactoryFactory {
    static func spawnHacker(character: MyCharacter?) {
        let appDelegate = UIApplication.shared.delegate as? AppDelegate

        var myCharacter = character
        let builderLocation = character?.location
        let boxNode = character?.scnNode
        let maxCoord = appDelegate!.gridHackGameState.points.count

        var myBuilderLocation: CGPoint
        if builderLocation == nil {

            myBuilderLocation = CGPoint(x: maxCoord - 1, y: maxCoord - 1)
        } else {
            myBuilderLocation = builderLocation!
        }

        let geometry = SCNBox(width: 0.5, height: 0.5,
                              length: 0.1, chamferRadius: 0.000)
        let texture = SKTexture(imageNamed: Enemy().getHackerTexture())
        geometry.firstMaterial?.diffuse.contents = texture

         var myBoxNode: SCNNode?
         var scnNode: SCNNode

        if appDelegate!.team == "bernie" {
            scnNode = (appDelegate?.fistNodeRed!.clone())!
            scnNode.scale = SCNVector3(0.05, 0.05, 0.05)
        } else {
            scnNode = (appDelegate?.fistNodeBlue!.clone())!
            scnNode.scale = SCNVector3(0.05, 0.05, 0.05)

        }

        scnNode.name = "hacker"
        let boxCopy = scnNode.clone() as? SCNNode
        boxCopy!.position.x = Float(maxCoord)
        boxCopy!.position.y = Float(maxCoord)
        boxCopy!.position.y = Float(2.5)

        if boxNode == nil {
            appDelegate!.scene!.rootNode.addChildNode(boxCopy!)
            myBoxNode = boxCopy
        } else {
            myBoxNode = boxNode
        }

        let path1 = UIBezierPath()
        if myCharacter == nil {
            let enemy = MyCharacter()
            enemy.location = myBuilderLocation
            enemy.scnNode = myBoxNode
            enemy.characterType="hacker"
            appDelegate!.gridHackGameState.enemies!.append(enemy)
            myCharacter = enemy

        } else {
            let firstIndex = appDelegate!.gridHackGameState.enemies!.firstIndex(of: myCharacter!)
            if firstIndex != nil {
                appDelegate!.gridHackGameState.enemies![firstIndex!].location = myBuilderLocation
            } else {
                //print("first index is nil in enemy hacker factory, can't edit location.. returning")
                return
            }
            myCharacter = appDelegate!.gridHackGameState.enemies![firstIndex!]

        }
        path1.move(to: myBuilderLocation)
        let moveAction = SCNAction.move(to: SCNVector3(x: Float(myBuilderLocation.x), y: Float(myBuilderLocation.y), z: 0.0), duration: 1.0)

        myBoxNode!.runAction(moveAction)

        let closest = GridHackUtils().getClosestFriendlyOwned(currentBuilderLocation: myBuilderLocation)
        //print("closest friendly owned:")
        //print(closest)
        if Int(closest.x) == 100 {

            let builder = myCharacter!
            builder.characterType="hacker"
            builder.location = myBuilderLocation
            builder.scnNode = myBoxNode

            appDelegate!.gridHackGameState.idleHackers!.append(builder)

            GridHackUtils().updateEnemyLocation(closest: myBuilderLocation, myCharacter: myCharacter)

            setToNoneOwned(closest: myBuilderLocation)
            _ = GridHackUtils().getClosestEnemy(fromCoordinate: myBuilderLocation)
            // //print("returning idle enemy hacker")
            // //print("closestEnemy \(String(describing: closestEnemy))")
            return
        } else {
            var moveAction = SCNAction.move(to: SCNVector3(x: Float(myBuilderLocation.x), y: Float(myBuilderLocation.y), z: 0.0), duration: 0.0)

            myBoxNode!.runAction(moveAction)

            let r: Float =    Float(getBearingBetweenTwoPoints1(point1: myCharacter!.location!, point2: closest))

            myBoxNode?.rotation = SCNVector4(0, 1, 0.25, r + 3.14/2)

            path1.move(to: closest)
            moveAction = SCNAction.moveAlong(path: path1)
            // let repeatAction = SCNAction.repeatForever(moveAction)
            SCNTransaction.begin()
            SCNTransaction.animationDuration = Double(path1.elements.count) * 0
            myBoxNode!.runAction(moveAction, completionHandler: {

                let gs = appDelegate!.gridHackGameState
                // set points to under enemy construction
                gs!.points[Int(closest.x)][Int((closest.y))] = GridState.underEnemyConstruction
                gs!.distanceBetweenFriendlyOwnedPoints[Int(closest.x)][Int((closest.y))] = 100

                DispatchQueue.main.asyncAfter(deadline: .now() + GameScene.TIMETOCAPTURE) {

                    // reset the distance at this coordinate to be 100 cause there's no unit here anymore
                    gs!.distanceBetweenEnemyHackers[Int(myCharacter!.location!.x)][Int((myCharacter!.location!.y))] = 100

                    //print("freed friendly square...onto the next one")

                    setToNoneOwned(closest: closest)

                    GridHackUtils().updateEnemyLocation(closest: closest, myCharacter: myCharacter)

                    self.spawnHacker(character: myCharacter)
                }

            }
            )
            SCNTransaction.commit()
        }
    }

    static func setToNoneOwned(closest: CGPoint) {
        let appDelegate = UIApplication.shared.delegate as? AppDelegate

        appDelegate!.gridHackGameState.points[Int(closest.x)][Int((closest.y))] = GridState.open

        let node = appDelegate!.gridHackGameState.grid[Int(closest.x)][Int((closest.y))]

        node.geometry = node.geometry!.copy() as? SCNGeometry
        node.geometry?.firstMaterial = node.geometry?.firstMaterial!.copy() as? SCNMaterial
        node.geometry?.firstMaterial?.diffuse.contents = UIColor.lightGray
    }
}
