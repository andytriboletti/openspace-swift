//
//  TravelViewController.swift
//  Open Space
//
//  Created by Andy Triboletti on 3/20/21.
//  Copyright © 2021 GreenRobot LLC. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation

class TravelViewController: UIViewController {
    
       @IBOutlet weak var videoView: UIView!
       
       var player: AVPlayer?
       
       override func viewDidLoad() {
           super.viewDidLoad()
            appDelegate.gameState.locationState = appDelegate.gameState.goingToLocationState!
            appDelegate.gameState.goingToLocationState = nil
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                self.performSegue(withIdentifier: "goToGame", sender: self)
            }
        
           // Load video resource
           if let videoUrl = Bundle.main.url(forResource: "lightspeed_PexelsVideos2757709", withExtension: "mp4") {
               
               // Init video
               self.player = AVPlayer(url: videoUrl)
               self.player?.isMuted = true
               self.player?.actionAtItemEnd = .none
               
               // Add player layer
               let playerLayer = AVPlayerLayer(player: player)
               playerLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
               playerLayer.frame = view.frame
               
               // Add video layer
               self.videoView.layer.addSublayer(playerLayer)
               
               // Play video
               self.player?.play()
               
               // Observe end
               NotificationCenter.default.addObserver(self, selector: #selector(playerItemDidReachEnd), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: self.player?.currentItem)
           }
           else {
               
               print("NoFile")
           }
       }
       
       // MARK: - Loop video when ended.
       @objc func playerItemDidReachEnd(notification: NSNotification) {
           self.player?.seek(to: CMTime.zero)
           self.player?.play()
       }
}
