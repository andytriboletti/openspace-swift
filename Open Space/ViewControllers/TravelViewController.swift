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
import Defaults
#if !targetEnvironment(macCatalyst)
import GoogleMobileAds
#endif

#if !targetEnvironment(macCatalyst)
extension TravelViewController: GADFullScreenContentDelegate {
    // Implement GADFullScreenContentDelegate methods here



    /// Tells the delegate that the ad failed to present full screen content.
      func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        //print("Ad did fail to present full screen content.")
      }

      /// Tells the delegate that the ad will present full screen content.
      func adWillPresentFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        //print("Ad will present full screen content.")
      }

      /// Tells the delegate that the ad dismissed full screen content.
      func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        //print("Ad did dismiss full screen content.")

          continueOntoGame()
          if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
              appDelegate.preloadInterstitialAd()
          }
      }

}
#endif

class TravelViewController: UIViewController {
        #if !targetEnvironment(macCatalyst)
            private var interstitial: GADInterstitialAd?
        #endif

       @IBOutlet weak var videoView: UIView!

       var player: AVPlayer?

       override func viewDidLoad() {
           super.viewDidLoad()

       }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        #if !targetEnvironment(macCatalyst)


        let premium = Defaults[.premium]
        if(premium == 0) {

            // Access the preloaded interstitial ad from the AppDelegate
            if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                interstitial = appDelegate.interstitial
                interstitial?.fullScreenContentDelegate = self
                presentInterstitialAd()
            }
        }
        else {
            continueOntoGame()
        }




        #else
            continueOntoGame()
        #endif

    }
    // MARK: - Loop video when ended.
    @objc func playerItemDidReachEnd(notification: NSNotification) {
        self.player?.seek(to: CMTime.zero)
        self.player?.play()
    }

    func continueOntoGame() {

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
        } else {

            //print("NoFile")
        }

    }
#if !targetEnvironment(macCatalyst)

    private func presentInterstitialAd() {
        DispatchQueue.main.async {
            guard let interstitial = self.interstitial else {
                //print("Interstitial ad not ready")
                return
            }

            interstitial.present(fromRootViewController: self)
        }
    }


#endif

}
