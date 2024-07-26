//
//  AppOpenAdManager.swift
//  Open Space
//
//  Created by Andrew Triboletti on 7/26/24.
//  Copyright © 2024 GreenRobot LLC. All rights reserved.
//

import Foundation
#if !targetEnvironment(macCatalyst)
import GoogleMobileAds
#endif

class AppOpenAdManager: NSObject {
#if !targetEnvironment(macCatalyst)
  var appOpenAd: GADAppOpenAd?
#endif
  var isLoadingAd = false
  var isShowingAd = false

  static let shared = AppOpenAdManager()

#if !targetEnvironment(macCatalyst)
  private func loadAd() async {
    // Do not load ad if there is an unused ad or one is already loading.
    if isLoadingAd || isAdAvailable() {
      return
    }
    isLoadingAd = true

    do {
#if DEBUG
        appOpenAd = try await GADAppOpenAd.load(
          withAdUnitID: MyData.testAdOpen, request: GADRequest())
#else
        appOpenAd = try await GADAppOpenAd.load(
          withAdUnitID: MyData.adOpen, request: GADRequest())
#endif
        appOpenAd?.fullScreenContentDelegate = self

    } catch {
      print("App open ad failed to load with error: \(error.localizedDescription)")
    }
    isLoadingAd = false
  }
#endif

  func showAdIfAvailable() {
#if !targetEnvironment(macCatalyst)
    // If the app open ad is already showing, do not show the ad again.
    guard !isShowingAd else { return }

    // If the app open ad is not available yet but is supposed to show, load
    // a new ad.
    if !isAdAvailable() {
      Task {
        await loadAd()
      }
      return
    }

    if let ad = appOpenAd {
      isShowingAd = true
      ad.present(fromRootViewController: nil)
    }
#endif
  }

  private func isAdAvailable() -> Bool {
#if !targetEnvironment(macCatalyst)
    // Check if ad exists and can be shown.
    return appOpenAd != nil
#else
    return false
#endif
  }
}

#if !targetEnvironment(macCatalyst)
// MARK: - GADFullScreenContentDelegate methods
extension AppOpenAdManager: GADFullScreenContentDelegate {
  func adWillPresentFullScreenContent(_ ad: GADFullScreenPresentingAd) {
    print("App open ad will be presented.")
  }

  func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
    appOpenAd = nil
    isShowingAd = false
    // Reload an ad.
    Task {
      await loadAd()
    }
  }

  func ad(
    _ ad: GADFullScreenPresentingAd,
    didFailToPresentFullScreenContentWithError error: Error
  ) {
    appOpenAd = nil
    isShowingAd = false
    // Reload an ad.
    Task {
      await loadAd()
    }
  }
}
#endif
