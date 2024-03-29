//
//  AboutViewController.swift
//  Open Space
//
//  Created by Andrew Triboletti on 3/29/24.
//  Copyright © 2024 GreenRobot LLC. All rights reserved.
//

import UIKit
import WebKit

class AboutViewController: UIViewController {
    @IBOutlet var webView: WKWebView!

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
