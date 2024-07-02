//
//  GameViewController+Scene.swift
//  Open Space
//
//  Created by Andrew Triboletti on 7/1/24.
//  Copyright © 2024 GreenRobot LLC. All rights reserved.
//
import SceneKit

extension GameViewController {
    func moveToPlanet() {
        for node in spaceShip {
            if node.name == "Spaceship" {
                let toPlace = SCNVector3(x: -500, y: 0, z: -200)
                let moveAction = SCNAction.move(to: toPlace, duration: TimeInterval(Float(5.0)))
                node.runAction(moveAction)
            }
        }
    }

    func moveAwayFromPlanet() {
        for node in spaceShip {
            if node.name == "Spaceship" {
                let toPlace = SCNVector3(x: 500, y: 0, z: 200)
                let moveAction = SCNAction.move(to: toPlace, duration: TimeInterval(Float(5.0)))
                node.runAction(moveAction)
            }
        }
    }

    func animateAsteroid(baseNode: SCNNode) {
        let shipScenec = SCNScene(named: "a.scn")!
        let shipSceneChildNodesc = shipScenec.rootNode.childNodes
        for childNode in shipSceneChildNodesc {
            let initialPositionX = 0
            let initialPositionY = 200
            childNode.position = SCNVector3(initialPositionX, initialPositionY, 200)
            childNode.scale = SCNVector3(100, 50, 50)

            baseNode.addChildNode(childNode)

            let howLongToTravel = 5000
            let toPlace = SCNVector3(x: Float(initialPositionX + howLongToTravel), y: Float(initialPositionY + howLongToTravel), z: Float(howLongToTravel))
            var moveAction = SCNAction.move(to: toPlace, duration: TimeInterval(Float(200.0)))
            childNode.runAction(moveAction)

            let path1 = UIBezierPath()
            path1.move(to: CGPoint(x: 1000, y: 1000))
            moveAction = SCNAction.moveAlong(path: path1)

            SCNTransaction.begin()
            SCNTransaction.animationDuration = 0
            moveAction = SCNAction.moveAlong(path: path1)
            SCNTransaction.commit()
        }
    }

    func addAsteroid(position: SCNVector3? = nil, scale: SCNVector3? = nil) {
        var myScale = scale
        if scale == nil {
            let minValue = 20
            let maxValue = 100
            let xScale = Int.random(in: minValue ..< maxValue)
            let yScale = Int.random(in: minValue ..< maxValue)
            let zScale = Int.random(in: minValue ..< maxValue)
            myScale = SCNVector3(xScale, yScale, zScale)
        }

        var myPosition = position
        if position == nil {
            let minValue = 300
            let maxValue = 5000
            var xVal = Int.random(in: minValue ..< maxValue)
            var yVal = Int.random(in: minValue ..< maxValue)
            var zVal = Int.random(in: minValue ..< maxValue)
            if arc4random_uniform(2) == 0 {
                xVal *= -1
            }
            if arc4random_uniform(2) == 0 {
                yVal *= -1
            }
            if arc4random_uniform(2) == 0 {
                zVal *= -1
            }
            myPosition = SCNVector3(xVal, yVal, zVal)
        }
        _ = addObject(name: "a.scn", position: myPosition, scale: myScale)
    }

    func addObject(name: String, position: SCNVector3?, scale: Float) -> [SCNNode] {
        return addObject(name: name, position: position, scale: SCNVector3(x: scale, y: scale, z: scale))
    }

    func addTempObject(name: String, position: SCNVector3?, scale: Float) {
        addTempObject(name: name, position: position, scale: SCNVector3(x: scale, y: scale, z: scale))
    }

    func addObject(name: String, position: SCNVector3?, scale: SCNVector3?) -> [SCNNode] {
        let shipScene = SCNScene(named: name)!
        let shipSceneChildNodes = shipScene.rootNode.childNodes
        for childNode in shipSceneChildNodes {
            baseNode.addChildNode(childNode)
            if position != nil {
                childNode.position = position!
            }
            if scale != nil {
                childNode.scale = scale!
            }
        }
        return shipSceneChildNodes
    }

    func addTempObject(name: String, position: SCNVector3?, scale: SCNVector3?) {
        let shipScene = SCNScene(named: name)!
        let shipSceneChildNodes = shipScene.rootNode.childNodes
        for childNode in shipSceneChildNodes {
            tempNode.addChildNode(childNode)
            if position != nil {
                childNode.position = position!
            }
            if scale != nil {
                childNode.scale = scale!
            }
        }
    }
}
