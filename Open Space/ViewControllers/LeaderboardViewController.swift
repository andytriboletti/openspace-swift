//
//  LeaderboardViewController.swift
//  Open Space
//
//  Created by Andrew Triboletti on 3/30/24.
//  Copyright © 2024 GreenRobot LLC. All rights reserved.
//

import UIKit
import GameKit

class LeaderboardViewController: BackgroundImageViewController, GKGameCenterControllerDelegate {
    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
           gameCenterViewController.dismiss(animated: true, completion: nil)
       }

    // Function to display leaderboard
    @IBAction func showLeaderboard() {
          let gameCenterVC = GKGameCenterViewController()
          gameCenterVC.gameCenterDelegate = self
          gameCenterVC.viewState = .leaderboards
          gameCenterVC.leaderboardIdentifier = "com.greenrobot.openspace.top_cash"
          present(gameCenterVC, animated: true, completion: nil)
      }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    private var hasShownLeaderboard = false

    // Open Game Center the first time the tab appears. Presenting from viewDidLoad (before the
    // view is in a window) is unsupported and could leave the app ignoring taps.
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard !hasShownLeaderboard else { return }
        hasShownLeaderboard = true
        showLeaderboard()
    }

}
