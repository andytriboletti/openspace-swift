//
//  GameResultViewController.swift
//  GridHack
//
//  Created by Andy Triboletti on 2/8/20.
//  Copyright © 2020 GreenRobot LLC. All rights reserved.
//

import UIKit

class GameResultViewController: UIViewController {

    @IBOutlet var resultLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        let gameScore = GameScore()
        let opponentScore = gameScore.getOpponentScore()
        let yourScore = gameScore.getYourScore()
        var gameResult = "Tie"
        if yourScore > opponentScore {
            gameResult = "Win"
        } else if yourScore < opponentScore {
            gameResult = "Lose"
        }
        var resultString = "Game Result:\nYou "
        resultString += "\(gameResult)!\nThe Score Was:\n"
        resultString += "You: \(yourScore) v Opponent: \(opponentScore)"
        self.resultLabel.text = resultString
    }
}
