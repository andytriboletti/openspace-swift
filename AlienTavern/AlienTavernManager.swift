import Foundation

class AlienTavernManager {
    static let shared = AlienTavernManager()

    private var appConfig: ATAppConfig?
    private var currentUsername: String?

    private init() {}

    func configure(with appConfig: ATAppConfig) {
        self.appConfig = appConfig
    }

    func setUsername(_ username: String) {
        self.currentUsername = username
    }

    func setup(completion: @escaping (Bool, String?) -> Void) {
        guard let appConfig = appConfig else {
            completion(false, "AlienTavernManager not configured. Call configure(with:) first.")
            return
        }

        print("AlienTavernManager: Starting authentication")
        print("AlienTavernManager: Using app_id: \(appConfig.app_id)")
        print("AlienTavernManager: app_secret length: \(appConfig.app_secret.count)")

        AlienTavern.authenticate(appID: appConfig.app_id, appSecret: appConfig.app_secret) { result in
            switch result {
            case .success:
                print("AlienTavernManager: Authentication successful")
                completion(true, nil)
            case .failure(let error):
                print("AlienTavernManager: Authentication failed with error: \(error)")
                let errorMessage = self.getErrorMessage(from: error)
                completion(false, errorMessage)
            }
        }
    }

    func getComments(for boardID: String, completion: @escaping (Result<[Comment], Error>) -> Void) {
        print("AlienTavernManager: Fetching comments for board \(boardID)")
        AlienTavern.loadComments(boardID: boardID) { result in
            switch result {
            case .success(let comments):
                print("AlienTavernManager: Successfully fetched \(comments.count) comments")
                completion(.success(comments))
            case .failure(let error):
                print("AlienTavernManager: Failed to fetch comments: \(error)")
                completion(.failure(error))
            }
        }
    }

    func postComment(boardID: String, text: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let username = currentUsername else {
            completion(.failure(NSError(domain: "AlienTavernManager", code: 0, userInfo: [NSLocalizedDescriptionKey: "Username not set"])))
            return
        }

        print("AlienTavernManager: Posting comment to board \(boardID)")
        AlienTavern.postComment(boardID: boardID, commentText: text, username: username) { result in
            switch result {
            case .success:
                print("AlienTavernManager: Successfully posted comment")
                completion(.success(()))
            case .failure(let error):
                print("AlienTavernManager: Failed to post comment: \(error)")
                completion(.failure(error))
            }
        }
    }

    private func getErrorMessage(from error: AlienTavern.APIError) -> String {
        switch error {
        case .networkError(let underlyingError):
            return "Network error: \(underlyingError.localizedDescription)"
        case .decodingError(let underlyingError):
            return "Decoding error: \(underlyingError.localizedDescription)"
        case .invalidResponse:
            return "Invalid response from server"
        case .authenticationError:
            return "Authentication failed. Check your app ID and secret."
        case .serverError(let message):
            return "Server error: \(message)"
        case .invalidURL:
            return "Invalid URL"
        case .encodingError:
            return "Encoding error"
        case .emptyResponse:
            return "Empty response"
        }
    }
}
