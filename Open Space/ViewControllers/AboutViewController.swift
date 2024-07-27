//
//  AboutViewController.swift
//  Open Space
//
//  Created by Andrew Triboletti on 3/29/24.
//  Copyright © 2024 GreenRobot LLC. All rights reserved.
//

import UIKit
import WebKit

class AboutViewController: BackgroundImageViewController {
    @IBOutlet var webView: WKWebView!

    @IBAction func openSpaceHomepage() {
        if let url = URL(string: "https://openspace.greenrobot.com") {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    @IBAction func openSpaceForum() {
        if let url = URL(string: "https://community.greenrobot.com/openspacegame-ios-mac-forum/open-space-new-feature-suggestions") {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }

    @IBAction func openHelp() {
        if let url = URL(string: "https://openspace.greenrobot.com/openspace-faq-and-help/") {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Load the URL
               if let url = URL(string: "https://blog.openspace.greenrobot.com") {
                   let request = URLRequest(url: url)
                   webView.load(request)
               }

        // Do any additional setup after loading the view.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
