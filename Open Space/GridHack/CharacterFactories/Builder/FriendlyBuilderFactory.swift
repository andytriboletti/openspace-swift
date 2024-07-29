//
//  FriendlyCharacterFactory.swift
//  GridHack
//
//  Created by Andy Triboletti on 2/1/20.
//  Copyright © 2020 GreenRobot LLC. All rights reserved.
//

import Foundation
import UIKit
import SceneKit
import SpriteKit
class FriendlyBuilderFactory: FactoryFactory {
    static func spawnBuilder(character: MyCharacter?) {
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        var myCharacter = character
        var myBuilderLocation: CGPoint
        let builderLocation = character?.location
        let boxNode = character?.scnNode
        if builderLocation == nil {
            myBuilderLocation = CGPoint(x: 1, y: 1)

        } else {
            myBuilderLocation = builderLocation!
        }

        var myBoxNode: SCNNode?
        var scnNode: SCNNode
        if appDelegate!.team == "bernie" {
            scnNode = (appDelegate?.donkeyNode!.clone())!
            scnNode.scale = SCNVector3(0.5, 0.5, 0.5)
        } else {
            scnNode = (appDelegate?.elephantNode!.clone())!
            scnNode.scale = SCNVector3(0.3, 0.3, 0.3)

        }

        scnNode.name = "builder"
        let boxCopy = scnNode.clone()
        boxCopy.position.x = Float(0)
        boxCopy.position.y = Float(0)

        boxCopy.position.z = Float(2.5)

        if boxNode == nil {
            appDelegate!.scene!.rootNode.addChildNode(boxCopy)
            myBoxNode = boxCopy
        } else {
            myBoxNode = boxNode
        }

        let path1 = UIBezierPath()

        if myCharacter == nil {
            let friendly = MyCharacter()
            friendly.location = myBuilderLocation
            friendly.scnNode = myBoxNode
            friendly.characterType="builder"
            appDelegate!.gridHackGameState.friendlys!.append(friendly)
            myCharacter = friendly
        } else {
            let firstIndex = appDelegate!.gridHackGameState.friendlys!.firstIndex(of: myCharacter!)
            if firstIndex != nil {
                appDelegate!.gridHackGameState.friendlys![firstIndex!].location = myBuilderLocation
            } else {
                //print("friendly character not found - returning")
                return
            }
            myCharacter = appDelegate!.gridHackGameState.friendlys![firstIndex!]
        }

        let closest = GridHackUtils().getClosestPendingConstruction(currentBuilderLocation: myBuilderLocation)
        //print("closest pending construction:")
        //print(closest)
        if Int(closest.x) == 100 {

            let builder = myCharacter!
            builder.characterType="builder"
            builder.location = myBuilderLocation
            builder.scnNode = myBoxNode

            appDelegate!.gridHackGameState.idleBuilders!.append(builder)

            GridHackUtils().updateFriendlyLocation(closest: myBuilderLocation, myCharacter: myCharacter)

            GridHackUtils().setToFriendlyOwned(closest: myBuilderLocation)
            _ = GridHackUtils().getClosestFriendly(fromCoordinate: myBuilderLocation)

            // //print("returning idle builder")
            return
        } else {
            var moveAction = SCNAction.move(to: SCNVector3(x: Float(myBuilderLocation.x), y: Float(myBuilderLocation.y), z: 0.0), duration: 0.0)

            //print("coord scnnode y: \(String(describing: myCharacter?.location?.y))")
            //print("coord closest y: \(closest.y)")
            let r: Float =    Float(getBearingBetweenTwoPoints1(point1: myCharacter!.location!, point2: closest))

            myBoxNode?.rotation = SCNVector4(0, 1, 0.25, r + 3.14/2)

            //print("rot: \(r)")
            if (myCharacter?.location!.x)! > closest.x {
                //print("rot turning left")
                // myBoxNode?.rotation = SCNVector4(0, -1, 0, 3.14/2)
                // myBoxNode?.rotation = SCNVector4(0, -1, 0, r - 3.14/2 )

            } else if (myCharacter?.location!.x)! < closest.x {
                //print("rot turning right")
                // myBoxNode?.rotation = SCNVector4(-1, -1, 0, r - 3.14/2)

            } else {
                //print("rot not turning left or right")
            }

            // todo make this dynamic based if it's going up or down
            // pretty good except up and down
            // myBoxNode?.rotation = SCNVector4(0, 1, 0, r + 3.14/2)

            // pretty good on up and down only
            // myBoxNode?.rotation = SCNVector4(0, 1, 0.5, r + 3.14/2)

            // compromise

            myBoxNode!.runAction(moveAction)

            path1.move(to: closest)
            moveAction = SCNAction.moveAlong(path: path1)
            SCNTransaction.begin()

            if appDelegate!.isMultiplayer {
                appDelegate!.multiplayer.enemyMoved(initialPosition: myBuilderLocation, finalPosition: closest, characterType: "builder")
            }

            SCNTransaction.animationDuration = Double(path1.elements.count) * 0
            myBoxNode!.runAction(moveAction, completionHandler: {
                // set points to under friendly construction
                appDelegate!.gridHackGameState.points[Int(closest.x)][Int((closest.y))] = GridState.underFriendlyConstruction
                appDelegate!.gridHackGameState.distanceBetweenPoints[Int(closest.x)][Int((closest.y))] = 100

                DispatchQueue.main.asyncAfter(deadline: .now() + GameScene.TIMETOCAPTURE) {
                    // reset the distance at this coordinate to be 100 cause there's no unit here anymore
                    appDelegate!.gridHackGameState.distanceBetweenFriendlyBuilders[Int(myCharacter!.location!.x)][Int((myCharacter!.location!.y))] = 100

                    //print("captured friendly square...onto the next one")
                    GridHackUtils().setToFriendlyOwned(closest: closest)

                    if appDelegate!.isMultiplayer {
                        appDelegate!.multiplayer.enemyOwned(position: closest)
                    }
                    GridHackUtils().updateFriendlyLocation(closest: closest, myCharacter: myCharacter)

                    self.spawnBuilder(character: myCharacter)
                }

            }
            )
            SCNTransaction.commit()
        }
    }

}
