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
          // Never leave the player stuck on the travel screen because an ad couldn't show.
          continueOntoGame()
          if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
              appDelegate.preloadInterstitialAd()
          }
      }

      /// Tells the delegate that the ad will present full screen content.
      func adWillPresentFullScreenContent(_ ad: GADFullScreenPresentingAd) {
          AdPolicy.recordDailyAdShown(.lastTravelAdShown)
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

       // viewDidAppear runs again when the travel ad closes, and the ad's dismiss callback also
       // continues the trip; these make sure the trip is started and finished only once.
       private var hasStartedTrip = false
       private var hasContinued = false

       override func viewDidLoad() {
           super.viewDidLoad()

       }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard !hasStartedTrip else { return }
        hasStartedTrip = true

        #if !targetEnvironment(macCatalyst)
        // Show the preloaded travel ad if there is one; the trip continues when it's dismissed.
        // With no ad ready (no fill, offline, still loading) go straight on, or the player would
        // be stuck on this screen: continueOntoGame() only ran from the ad's dismiss callback.
        if AdPolicy.showAutomaticAds,
           AdPolicy.canShowDailyAd(.lastTravelAdShown),
           let appDelegate = UIApplication.shared.delegate as? AppDelegate,
           let ad = appDelegate.interstitial {
            interstitial = ad
            appDelegate.interstitial = nil   // an interstitial can only be shown once
            ad.fullScreenContentDelegate = self
            ad.present(fromRootViewController: self)
        } else {
            if AdPolicy.showAutomaticAds, let appDelegate = UIApplication.shared.delegate as? AppDelegate,
               appDelegate.interstitial == nil {
                appDelegate.preloadInterstitialAd()   // none loaded yet: try again for a later trip
            }
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
         guard !hasContinued else { return }
         hasContinued = true

         if let destination = appDelegate.gameState.goingToLocationState {
             appDelegate.gameState.locationState = destination
         }
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

}
