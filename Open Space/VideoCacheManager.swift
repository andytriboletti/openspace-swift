//
//  VideoCacheManager.swift
//  Open Space
//
//  Created by Andrew Triboletti on 3/9/24.
//  Copyright © 2024 GreenRobot LLC. All rights reserved.
//

import Foundation
class VideoCacheManager {
    static let shared = VideoCacheManager()
    private init() {}

    private let fileManager = FileManager.default
    private var cacheDirectory: URL {
        return fileManager.urls(for: .cachesDirectory, in: .userDomainMask)[0]
    }

    func cacheVideo(url: URL, completion: @escaping (URL?) -> Void) {
        let cacheURL = cacheDirectory.appendingPathComponent(url.lastPathComponent)

        // Check if the video is already cached
        if fileManager.fileExists(atPath: cacheURL.path) {
            completion(cacheURL)
            return
        }

        // Download and cache the video
        let task = URLSession.shared.downloadTask(with: url) { (tempURL, _, error) in
            guard let tempURL = tempURL, error == nil else {
                completion(nil)
                return
            }

            do {
                // Move the downloaded file to the cache directory
                try self.fileManager.moveItem(at: tempURL, to: cacheURL)
                completion(cacheURL)
            } catch {
                print("Error caching video: \(error.localizedDescription)")
                completion(nil)
            }
        }
        task.resume()
    }
}
