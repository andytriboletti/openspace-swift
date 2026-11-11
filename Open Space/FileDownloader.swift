//  FileDownloader.swift
//  Open Space
//
//  Created by Andrew Triboletti on 7/7/24.
//  Copyright © 2024 GreenRobot LLC. All rights reserved.
//

import Foundation
import Alamofire
import CryptoKit

/// Model, video and preview URLs come from the game server's database. Only load them over
/// HTTPS from our own storage, so a bad or tampered database value can't make the app
/// download from anywhere else.
enum TrustedURL {
    static let allowedHosts: Set<String> = ["wordcraft3d.s3.amazonaws.com"]

    static func from(_ string: String?) -> URL? {
        guard let string = string,
              let url = URL(string: string),
              url.scheme?.lowercased() == "https",
              let host = url.host?.lowercased(),
              allowedHosts.contains(host) else {
            return nil
        }
        return url
    }

    static func isTrusted(_ url: URL) -> Bool {
        return from(url.absoluteString) != nil
    }
}

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
        guard TrustedURL.isTrusted(url) else {
            completion(nil)
            return
        }

        // Cache by a hash of the whole URL: two files with the same name in different
        // folders used to overwrite each other.
        let digest = SHA256.hash(data: Data(url.absoluteString.utf8)).map { String(format: "%02x", $0) }.joined()
        let fileName = url.pathExtension.isEmpty ? digest : "\(digest).\(url.pathExtension)"
        let destinationURL = cacheDirectory.appendingPathComponent(fileName)

        // Check if file already exists
        if fileManager.fileExists(atPath: destinationURL.path) {
            completion(destinationURL)
            return
        }

        // Download the file using Alamofire
        AF.download(url).responseData { response in
            switch response.result {
            case .success(let data):
                do {
                    try data.write(to: destinationURL)
                    completion(destinationURL)
                } catch {
                    completion(nil)
                }
            case .failure:
                completion(nil)
            }
        }
    }
}
