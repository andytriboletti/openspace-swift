//
//  GameScene.swift
//  GridHackSceneKit
//
//  Created by Andy Triboletti on 1/30/20.
//  Copyright © 2020 GreenRobot LLC. All rights reserved.
//

import Foundation
import SceneKit
import SpriteKit

public class GameScene: SCNScene {
    static let TIMETOCAPTURE: Double = 0.1
    static let TIMETOCAPTUREENEMYUNIT: Double = 0.1
    static let GRIDSIZE: Int = 8

    override init() {
        super.init()
        drawGrid()
    }

    func drawGrid() {
        //print("drawing grid")

        let geometry = SCNBox(width: 0.90, height: 0.90,
                              length: 0.1, chamferRadius: 0.000)
        geometry.firstMaterial?.diffuse.contents = UIColor.lightGray
        let boxnode = SCNNode(geometry: geometry)
        let offset: Int = 0

        for xIndex: Int in 1...GameScene.GRIDSIZE {
            for yIndex: Int in 1...GameScene.GRIDSIZE {
                let boxCopy = (boxnode.copy() as? SCNNode)!
                boxCopy.position.x = Float(xIndex + offset)
                boxCopy.position.y = Float(yIndex + offset)
                boxCopy.position.z = -0.1
                boxCopy.geometry = boxCopy.geometry!.copy() as? SCNGeometry
                boxCopy.geometry?.firstMaterial = boxCopy.geometry?.firstMaterial!.copy() as? SCNMaterial

                let typeOfBox: GridState = appDelegate.gridHackGameState.points[Int(xIndex)][Int((yIndex))]
                if typeOfBox == GridState.open {
                    boxCopy.geometry?.firstMaterial?.diffuse.contents = UIColor.lightGray
                } else if typeOfBox == GridState.waitingForFriendlyConstruction {
                    boxCopy.geometry?.firstMaterial?.diffuse.contents = Friendly().getLightColor()
                } else if typeOfBox == GridState.friendlyOwned {
                    boxCopy.geometry?.firstMaterial?.diffuse.contents = Friendly().getColor()
                }

                appDelegate.gridNode.addChildNode(boxCopy)
                appDelegate.gridHackGameState.grid[Int(xIndex)][Int((yIndex))] = boxCopy
            }
        }
        self.rootNode.addChildNode(appDelegate.gridNode)

    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
extension CGPoint {
    func distance(to point: CGPoint) -> CGFloat {
        return sqrt(pow(x - point.x, 2) + pow(y - point.y, 2))
    }
}
