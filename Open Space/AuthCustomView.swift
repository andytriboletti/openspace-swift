//
//  AuthCustomView.swift
//  Open Space
//
//  Created by Andrew Triboletti on 7/24/24.
//  Copyright © 2024 GreenRobot LLC. All rights reserved.
//

import Foundation
import UIKit

class AuthCustomView: UIView {
    let imageView = UIImageView()
    let titleLabel = UILabel()
    var imageTimer: Timer?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }


    private func setupViews() {
        // Set up the image view
        imageView.frame = CGRect(x: 0, y: 0, width: 300, height: 300)
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(imageView)

        // Center the imageView
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 300),
            imageView.heightAnchor.constraint(equalToConstant: 300)
        ])

        // Set up the label
        titleLabel.text = "Open Space"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 24)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(titleLabel)

        // Center the label horizontally and place it a bit lower
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 100)
        ])

        updateLabelColor()
        loadRandomImage()

        // Start the timer to change the image every 10 seconds
        imageTimer = Timer.scheduledTimer(timeInterval: 10.0, target: self, selector: #selector(loadRandomImage), userInfo: nil, repeats: true)
    }

    @objc private func loadRandomImage() {
        let randomIndex = Int.random(in: 1...10)
        let imageName = "login\(randomIndex)"
        imageView.image = UIImage(named: imageName)
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            updateLabelColor()
        }
    }

    private func updateLabelColor() {
        titleLabel.textColor = traitCollection.userInterfaceStyle == .dark ? .white : .black
    }
}
