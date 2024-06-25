//
//  GameState.swift
//  GridHack
//
//  Created by Andy Triboletti on 2/4/20.
//  Copyright © 2020 GreenRobot LLC. All rights reserved.
//

import Foundation
import SceneKit
class GridHackGameState {
    var distanceBetweenEnemyBuilders: [[Float]] = Array(repeating: Array(repeating: Float(100), count: GameScene.GRIDSIZE + 1), count: GameScene.GRIDSIZE + 1)

    var distanceBetweenEnemyAttackers: [[Float]] = Array(repeating: Array(repeating: Float(100), count: GameScene.GRIDSIZE + 1), count: GameScene.GRIDSIZE + 1)

    var distanceBetweenEnemyHackers: [[Float]] = Array(repeating: Array(repeating: Float(100), count: GameScene.GRIDSIZE + 1), count: GameScene.GRIDSIZE + 1)

    var distanceBetweenFriendlyBuilders: [[Float]] = Array(repeating: Array(repeating: Float(100), count: GameScene.GRIDSIZE + 1), count: GameScene.GRIDSIZE + 1)

    var distanceBetweenFriendlyAttackers: [[Float]] = Array(repeating: Array(repeating: Float(100), count: GameScene.GRIDSIZE + 1), count: GameScene.GRIDSIZE + 1)

    var distanceBetweenFriendlyHackers: [[Float]] = Array(repeating: Array(repeating: Float(100), count: GameScene.GRIDSIZE + 1), count: GameScene.GRIDSIZE + 1)

    var distanceBetweenPoints: [[Float]] = Array(repeating: Array(repeating: Float(100), count: GameScene.GRIDSIZE + 1), count: GameScene.GRIDSIZE + 1)

    var distanceBetweenEnemyPoints: [[Float]] = Array(repeating: Array(repeating: Float(100), count: GameScene.GRIDSIZE + 1), count: GameScene.GRIDSIZE + 1)

    var distanceBetweenEnemyOwnedPoints: [[Float]] = Array(repeating: Array(repeating: Float(100), count: GameScene.GRIDSIZE + 1), count: GameScene.GRIDSIZE + 1)

    var distanceBetweenFriendlyOwnedPoints: [[Float]] = Array(repeating: Array(repeating: Float(100), count: GameScene.GRIDSIZE + 1), count: GameScene.GRIDSIZE + 1)

    var grid: [[SCNNode]] = Array(repeating: Array(repeating: SCNNode(), count: GameScene.GRIDSIZE + 1), count: GameScene.GRIDSIZE + 1)

    var points: [[GridState]] = Array(repeating: Array(repeating: GridState.open, count: GameScene.GRIDSIZE + 1), count: GameScene.GRIDSIZE + 1)

    var idleBuilders: [MyCharacter]? = []
    var idleAttackers: [MyCharacter]? = []
    var idleHackers: [MyCharacter]? = []

    var enemies: [MyCharacter]? = []
    var friendlys: [MyCharacter]? = []

    var idleEnemyBuilders: [MyCharacter]? = []
    var idleEnemyAttackers: [MyCharacter]? = []
    var idleEnemyHackers: [MyCharacter]? = []

}
