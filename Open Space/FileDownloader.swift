//
//  FileDownloader.swift
//  Open Space
//
//  Created by Andrew Triboletti on 7/7/24.
//  Copyright © 2024 GreenRobot LLC. All rights reserved.
//

import Foundation

class FileDownloader {
    static let shared = FileDownloader()
    let fileManager = FileManager.default

    // Directory to store cached files
    lazy var cacheDirectory: URL = {
        let urls = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)
        return urls[0].appendingPathComponent("DownloadedFiles")
    }()

    private init() {
        // Create cache directory if it doesn't exist
        if !fileManager.fileExists(atPath: cacheDirectory.path) {
            try? fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true, attributes: nil)
        }
    }

    func downloadFile(from url: URL, completion: @escaping (URL?) -> Void) {
        let destinationURL = cacheDirectory.appendingPathComponent(url.lastPathComponent)

        // Check if file already exists
        if fileManager.fileExists(atPath: destinationURL.path) {
            completion(destinationURL)
            return
        }

        // Download the file
        let task = URLSession.shared.downloadTask(with: url) { (location, response, error) in
            guard let location = location, error == nil else {
                completion(nil)
                return
            }

            do {
                // Move downloaded file to cache directory
                try self.fileManager.moveItem(at: location, to: destinationURL)
                completion(destinationURL)
            } catch {
                completion(nil)
            }
        }
        task.resume()
    }
}