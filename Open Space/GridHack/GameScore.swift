//
//  GameScore.swift
//  GridHack
//
//  Created by Andy Triboletti on 2/9/20.
//  Copyright © 2020 GreenRobot LLC. All rights reserved.
//

import Foundation
class GameScore {
   func getOpponentScore() -> Int {
       var score = 0
       for xIndex: Int in 1...appDelegate.gridHackGameState.points[0].count - 1 {
           for yIndex: Int in 1...appDelegate.gridHackGameState.points[xIndex].count - 1 {
               if appDelegate.gridHackGameState.points[xIndex][yIndex] == GridState.enemyOwned {
                   score += 1
               }
           }
       }
       return score
   }
   func getYourScore() -> Int {
       var score = 0
       for xIndex: Int in 1...appDelegate.gridHackGameState.points[0].count - 1 {
           for yIndex: Int in 1...appDelegate.gridHackGameState.points[xIndex].count - 1 {
               if appDelegate.gridHackGameState.points[xIndex][yIndex] == GridState.friendlyOwned {
                   score += 1
               }
           }
       }
       return score
   }

}
