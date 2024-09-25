//
//  AlienTavernManager.swift
//  Open Space
//
//  Created by Andrew Triboletti on 9/25/24.
//  Copyright © 2024 GreenRobot LLC. All rights reserved.
//

class AlienTavernManager {
    static let shared = AlienTavernManager()

    private var config: ATConfig?

    private init() {}

    func configure(with config: ATConfig) {
        self.config = config
    }

    func setup(completion: @escaping (Bool, String?) -> Void) {
        guard let config = config else {
            completion(false, "AlienTavernManager not configured. Call configure(with:) first.")
            return
        }

        print("AlienTavernManager: Starting authentication")
        print("AlienTavernManager: Using app_id: \(config.app_id)")
        print("AlienTavernManager: app_secret length: \(config.app_secret.count)")

        AlienTavern.authenticate(appID: config.app_id, appSecret: config.app_secret) { result in
            switch result {
            case .success:
                print("AlienTavernManager: Authentication successful")
                completion(true, nil)
            case .failure(let error):
                print("AlienTavernManager: Authentication failed with error: \(error)")
                let errorMessage: String
                switch error {
                case .networkError(let underlyingError):
                    errorMessage = "Network error: \(underlyingError.localizedDescription)"
                case .decodingError(let underlyingError):
                    errorMessage = "Decoding error: \(underlyingError.localizedDescription)"
                case .invalidResponse:
                    errorMessage = "Invalid response from server"
                case .authenticationError:
                    errorMessage = "Authentication failed. Check your app ID and secret."
                case .serverError(let message):
                    errorMessage = "Server error: \(message)"
                case .invalidURL:
                    errorMessage = "invalid url:"
                case .encodingError(_):
                    errorMessage = "encoding error:"
                case .emptyResponse:
                    errorMessage = "empty response:"
                }
                completion(false, errorMessage)
            }
        }
    }


    
    func getComments(for boardID: String, completion: @escaping ([Comment]?) -> Void) {
        print("AlienTavernManager: Fetching comments for board \(boardID)")
        AlienTavern.loadComments(boardID: boardID) { result in
            switch result {
            case .success(let comments):
                print("AlienTavernManager: Successfully fetched \(comments.count) comments")
                completion(comments)
            case .failure(let error):
                print("AlienTavernManager: Failed to fetch comments: \(error)")
                completion(nil)
            }
        }
    }

    func postComment(boardID: String, text: String, username: String, completion: @escaping (Bool) -> Void) {
        print("AlienTavernManager: Posting comment to board \(boardID)")
        AlienTavern.postComment(boardID: boardID, commentText: text, username: username) { result in
            switch result {
            case .success:
                print("AlienTavernManager: Successfully posted comment")
                completion(true)
            case .failure(let error):
                print("AlienTavernManager: Failed to post comment: \(error)")
                completion(false)
            }
        }
    }
}
