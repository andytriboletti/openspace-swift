//
//  VIdeoCollectionViewCell.swift
//  Open Space
//
//  Created by Andrew Triboletti on 3/9/24.
//  Copyright © 2024 GreenRobot LLC. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation
import AVKit

class VideoCollectionViewCell: UICollectionViewCell {
    var playerLayer: AVPlayerLayer?
    let videoLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLabel()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupLabel()
    }
    
    func setupLabel() {
        // Configure the label's appearance
        videoLabel.textAlignment = .center
        videoLabel.textColor = .white
        videoLabel.backgroundColor = UIColor.black.withAlphaComponent(0.5) // Semi-transparent background
        videoLabel.text = "Video Title" // Example static text, you can make this dynamic
        contentView.addSubview(videoLabel)
        videoLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            videoLabel.heightAnchor.constraint(equalToConstant: 30),
            videoLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            videoLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            videoLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor) // Adjust this to position the label differently
        ])
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        playerLayer?.removeFromSuperlayer()
        playerLayer = nil
        videoLabel.isHidden = false // Ensure the label is visible for reuse
    }
    
    func configureForTextOnly(labelText: String) {
        // Hide the playerLayer if it exists
        playerLayer?.removeFromSuperlayer()
        playerLayer = nil
        // Configure the label for text-only display
        videoLabel.isHidden = false
        videoLabel.text = labelText
    }

    func configure(withURL url: URL, labelText: String) {
        // Ensure any existing playerLayer is removed to prepare for a new video
        playerLayer?.removeFromSuperlayer()
        playerLayer = nil
        
        // Set label text
        videoLabel.text = labelText
        
        VideoCacheManager.shared.cacheVideo(url: url) { [weak self] cachedURL in
            guard let strongSelf = self, let cachedURL = cachedURL else { return }
            DispatchQueue.main.async {
                let player = AVPlayer(url: cachedURL)
                strongSelf.playerLayer = AVPlayerLayer(player: player)
                strongSelf.playerLayer?.frame = strongSelf.bounds
                strongSelf.playerLayer?.videoGravity = .resizeAspectFill
                if let layer = strongSelf.playerLayer {
                    strongSelf.contentView.layer.insertSublayer(layer, at: 0) // Ensure label is visible on top
                }
                player.play()
            }
        }
    }
}
