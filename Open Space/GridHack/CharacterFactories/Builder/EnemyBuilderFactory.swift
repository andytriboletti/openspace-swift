import Foundation
import SceneKit
import SpriteKit
import UIKit

class EnemyBuilderFactory: FactoryFactory {

    static func spawnEnemyBuilder(character: MyCharacter?) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            print("Unable to get AppDelegate")
            return
        }
        guard let gridHackGameState = appDelegate.gridHackGameState else {
            print("GridHackGameState is nil")
            return
        }

        let maxCoord = gridHackGameState.points.count

        var myCharacter = character
        let builderLocation = character?.location

        let myBuilderLocation: CGPoint = builderLocation ?? CGPoint(x: maxCoord, y: maxCoord)

        var myBoxNode = setupBoxNode(appDelegate: appDelegate, builderLocation: builderLocation, maxCoord: maxCoord)

        myBoxNode.position = SCNVector3(x: Float(myBuilderLocation.x), y: Float(myBuilderLocation.y), z: 2.5)

        if let boxNode = character?.scnNode {
            myBoxNode = boxNode
        }

        let path1 = UIBezierPath()
        if myCharacter == nil {
            myCharacter = createEnemyCharacter(location: myBuilderLocation, boxNode: myBoxNode)
            gridHackGameState.enemies?.append(myCharacter!)
        } else {
            updateCharacterLocation(appDelegate: appDelegate, myCharacter: &myCharacter, location: myBuilderLocation)
        }

        runMoveAction(on: myBoxNode, to: myBuilderLocation)

        handleClosestEnemyConstruction(appDelegate: appDelegate, myCharacter: myCharacter!, builderLocation: myBuilderLocation, myBoxNode: myBoxNode)
    }

    private static func setupBoxNode(appDelegate: AppDelegate, builderLocation: CGPoint?, maxCoord: Int) -> SCNNode {
        let scnNode: SCNNode
        if appDelegate.team == "trump" {
            scnNode = appDelegate.donkeyNode!.clone()
            scnNode.scale = SCNVector3(0.5, 0.5, 0.5)
        } else {
            scnNode = appDelegate.elephantNode!.clone()
            scnNode.scale = SCNVector3(0.3, 0.3, 0.3)
        }
        scnNode.name = "enemybuilder"
        scnNode.position = SCNVector3(x: Float(maxCoord), y: Float(maxCoord), z: 2.5)
        return scnNode
    }

    private static func createEnemyCharacter(location: CGPoint, boxNode: SCNNode?) -> MyCharacter {
        let enemy = MyCharacter()
        enemy.location = location
        enemy.scnNode = boxNode
        enemy.characterType = "builder"
        return enemy
    }

    private static func updateCharacterLocation(appDelegate: AppDelegate, myCharacter: inout MyCharacter?, location: CGPoint) {
        guard let firstIndex = appDelegate.gridHackGameState.enemies?.firstIndex(of: myCharacter!) else {
            print("first index is nil - returning")
            return
        }
        appDelegate.gridHackGameState.enemies?[firstIndex].location = location
        myCharacter = appDelegate.gridHackGameState.enemies?[firstIndex]
    }

    private static func runMoveAction(on boxNode: SCNNode, to location: CGPoint) {
        let moveAction = SCNAction.move(to: SCNVector3(x: Float(location.x), y: Float(location.y), z: 0.0), duration: 1.0)
        boxNode.runAction(moveAction)
    }

    private static func handleClosestEnemyConstruction(appDelegate: AppDelegate, myCharacter: MyCharacter, builderLocation: CGPoint, myBoxNode: SCNNode) {
        let closest = GridHackUtils().getClosestPendingEnemyConstruction(currentBuilderLocation: builderLocation)
        print("closest enemy:", closest)
        if Int(closest.x) == 100 {
            handleIdleEnemyBuilder(appDelegate: appDelegate, myCharacter: myCharacter, location: builderLocation, boxNode: myBoxNode)
        } else {
            handleActiveEnemyBuilder(appDelegate: appDelegate, myCharacter: myCharacter, closest: closest, myBoxNode: myBoxNode)
        }
    }

    private static func handleIdleEnemyBuilder(appDelegate: AppDelegate, myCharacter: MyCharacter, location: CGPoint, boxNode: SCNNode) {
        myCharacter.characterType = "builder"
        myCharacter.location = location
        myCharacter.scnNode = boxNode
        appDelegate.gridHackGameState.idleEnemyBuilders?.append(myCharacter)

        GridHackUtils().updateEnemyLocation(closest: location, myCharacter: myCharacter)
        GridHackUtils().setToEnemyOwned(closest: location)
        _ = GridHackUtils().getClosestEnemy(fromCoordinate: location)
    }

    private static func handleActiveEnemyBuilder(appDelegate: AppDelegate, myCharacter: MyCharacter, closest: CGPoint, myBoxNode: SCNNode) {
        let path1 = UIBezierPath()
        path1.move(to: closest)

        let r: Float = Float(getBearingBetweenTwoPoints1(point1: myCharacter.location!, point2: closest))
        myBoxNode.rotation = SCNVector4(0, 1, 0.25, r + 3.14 / 2)

        let moveAction = SCNAction.moveAlong(path: path1)
        SCNTransaction.begin()
        SCNTransaction.animationDuration = Double(path1.elements.count) * 0
        myBoxNode.runAction(moveAction, completionHandler: {
            print("complete")
            guard let firstIndexEnemy = appDelegate.gridHackGameState.enemies?.firstIndex(of: myCharacter) else { return }
            appDelegate.gridHackGameState.enemies?[firstIndexEnemy].location = closest
            if Int(closest.x) != 100 {
                updateGridHackGameState(appDelegate: appDelegate, closest: closest, myCharacter: myCharacter, myBoxNode: myBoxNode)
            }
        })
        SCNTransaction.commit()
    }

    private static func updateGridHackGameState(appDelegate: AppDelegate, closest: CGPoint, myCharacter: MyCharacter, myBoxNode: SCNNode) {
        appDelegate.gridHackGameState.points[Int(closest.x)][Int((closest.y))] = GridState.underEnemyConstruction
        appDelegate.gridHackGameState.distanceBetweenEnemyPoints[Int(closest.x)][Int((closest.y))] = 100

        DispatchQueue.main.asyncAfter(deadline: .now() + GameScene.TIMETOCAPTURE) {
            print("captured enemy square...onto the next one")
            appDelegate.gridHackGameState.points[Int(closest.x)][Int((closest.y))] = GridState.enemyOwned
            let node = appDelegate.gridHackGameState.grid[Int(closest.x)][Int((closest.y))]

            node.geometry = node.geometry!.copy() as? SCNGeometry
            node.geometry?.firstMaterial = node.geometry?.firstMaterial!.copy() as? SCNMaterial
            node.geometry?.firstMaterial?.diffuse.contents = Enemy().getColor()

            let currentLocation = CGPoint(x: closest.x, y: closest.y)
            myCharacter.location = currentLocation
            myCharacter.scnNode = myBoxNode

            if let firstIndex = appDelegate.gridHackGameState.enemies?.firstIndex(of: myCharacter) {
                appDelegate.gridHackGameState.enemies?[firstIndex].location = currentLocation
            }

            spawnEnemyBuilder(character: myCharacter)
        }
    }
}
