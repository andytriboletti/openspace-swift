//
//  StationViewController.swift
//  Open Space
//
//  Created by Andrew Triboletti on 6/30/24.
//  Copyright © 2024 GreenRobot LLC. All rights reserved.
//

import UIKit

class StationViewController: UIViewController {

    @IBOutlet weak var stationNameLabel: UILabel!
    @IBOutlet weak var previewImageView: UIImageView!

    var stationName: String?
    var previewLocation: String?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Set the station name
        if let name = stationName {
            stationNameLabel.text = name
        } else {
            stationNameLabel.text = "Unknown"
        }

        // Load the preview image
        if let location = previewLocation, let url = URL(string: location) {
            loadPreviewImage(from: url)
        }
    }

    func loadPreviewImage(from url: URL) {
        // Use URLSession to load the image data
        URLSession.shared.dataTask(with: url) { data, _, error in
            if let data = data, error == nil {
                DispatchQueue.main.async {
                    self.previewImageView.image = UIImage(data: data)
                }
            }
        }.resume()
    }
}
