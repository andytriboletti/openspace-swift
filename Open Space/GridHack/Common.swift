//
//  Common.swift
//  GridHack
//
//  Created by Andy Triboletti on 2/1/20.
//  Copyright © 2020 GreenRobot LLC. All rights reserved.
//

import Foundation
import UIKit
import Alamofire

class Common {
    static var baseUrl = "https://bernie-vs-trump.greenrobot.com/appdata/"
    static var timeLeft: Float = 30.0
    static var connectionTimeout: Float = 5.0
    static var maxUnitAmount: Int = 3
    static var admobAppId: String = "ca-app-pub-8840903285420889~2755443439"

    // 1 for always, 2 for 1/2, 3 for 1/3 etc
    static var adFrequency: Int = 3

    // live
    static var interstitialAdmobId: String = "ca-app-pub-8840903285420889/5021486452"

    // test
    // static var interstitialAdmobId: String = "ca-app-pub-3940256099942544/4411468910"

}
