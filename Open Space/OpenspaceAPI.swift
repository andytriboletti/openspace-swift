//
//  OpenspaceAPI.swift
//  Open Space
//
//  Created by Andrew Triboletti on 7/14/23.
//  Copyright © 2023 GreenRobot LLC. All rights reserved.
//

import Foundation
import FirebaseAuth
import Defaults

class OpenspaceAPI {
    static let shared = OpenspaceAPI()
    let serverURL = "https://server3.openspace.greenrobot.com/wp-json/openspace/v1/"
    var webSocketTask: URLSessionWebSocketTask?

    var pendingModels: [Int: [String: String]] = [:]
    var completedModels: [Int: [String: String]] = [:]

    // MARK: - Models

    struct PromptData: Codable {
        let textPrompt: String
        let completed: String
        let videoLocation: String?
        let meshLocation: String?

        enum CodingKeys: String, CodingKey {
            case textPrompt = "text_prompt"
            case completed
            case videoLocation = "video_location"
            case meshLocation = "mesh_location"
        }
    }

    struct ResponseData: Codable {
        let pending: [PromptData]
        let completed: [PromptData]
    }

    struct Neighbor: Codable {
        let userId: String
        let username: String
        let itemCount: String

        enum CodingKeys: String, CodingKey {
            case userId = "user_id"
            case username
            case itemCount = "item_count"
        }
    }

    struct Response: Codable {
        let status: String
        let results: [Neighbor]
    }

    enum FetchDataError: Error {
        case invalidResponse
        case networkError(Error)
        case jsonParsingError(Error)
    }

    // MARK: - API Requests

    private func createPostRequest(urlString: String, parameters: [String: Any]) -> URLRequest? {
        guard let url = URL(string: urlString) else { return nil }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: parameters)
        return request
    }

    func fetchData(email: String, authToken: String, sphereId: String, completion: @escaping (Result<ResponseData, FetchDataError>) -> Void) {
        let parameters: [String: Any] = ["email": email, "authToken": authToken, "sphereId": sphereId]
        guard let request = createPostRequest(urlString: "\(serverURL)get-prompts-and-models", parameters: parameters) else {
            completion(.failure(.invalidResponse))
            return
        }
        performRequest(request: request, completion: completion)
    }

    func fetchNeighbors(email: String, authToken: String, completion: @escaping (Result<[Neighbor], FetchDataError>) -> Void) {
        let parameters: [String: Any] = ["email": email, "authToken": authToken]
        guard let request = createPostRequest(urlString: "\(serverURL)get-neighbor-spheres", parameters: parameters) else {
            completion(.failure(.invalidResponse))
            return
        }
        performRequest(request: request, completion: completion)
    }

    func checkDailyTreasureAvailability(planet: String, completion: @escaping (Result<String, Error>) -> Void) {
        let parameters: [String: Any] = ["email": Defaults[.email], "authToken": Defaults[.authToken], "planet": planet]
        guard let request = createPostRequest(urlString: "\(serverURL)check-daily-treasure", parameters: parameters) else {
            completion(.failure(NSError(domain: "com.openspace.error", code: -1, userInfo: nil)))
            return
        }
        performSimpleRequest(request: request, completion: completion)
    }

    func claimDailyTreasure(planet: String, completion: @escaping (Result<(String, String, Int), Error>) -> Void) {
        let parameters: [String: Any] = ["email": Defaults[.email], "authToken": Defaults[.authToken], "planet": planet]
        guard let request = createPostRequest(urlString: "\(serverURL)claim-daily-treasure", parameters: parameters) else {
            completion(.failure(NSError(domain: "com.openspace.error", code: -1, userInfo: nil)))
            return
        }
        performSimpleRequest(request: request, completion: completion)
    }

    func loginWithEmail(email: String, authToken: String, completion: @escaping (Result<String, Error>) -> Void) {
        let parameters: [String: Any] = ["email": email, "authToken": authToken]
        guard let request = createPostRequest(urlString: "\(serverURL)login", parameters: parameters) else {
            completion(.failure(NSError(domain: "com.openspace.error", code: -1, userInfo: nil)))
            return
        }
        performSimpleRequest(request: request, completion: completion)
    }

    func saveLocation(email: String, authToken: String, location: String, completion: @escaping (Result<String, Error>) -> Void) {
        let parameters: [String: Any] = ["email": email, "authToken": authToken, "location": location]
        guard let request = createPostRequest(urlString: "\(serverURL)save-location", parameters: parameters) else {
            completion(.failure(NSError(domain: "com.openspace.error", code: -1, userInfo: nil)))
            return
        }
        performSimpleRequest(request: request, completion: completion)
    }

    func deleteUser(email: String, authToken: String, completion: @escaping (Result<String, Error>) -> Void) {
        let parameters: [String: Any] = ["email": email, "authToken": authToken]
        guard let request = createPostRequest(urlString: "\(serverURL)delete-user", parameters: parameters) else {
            completion(.failure(NSError(domain: "com.openspace.error", code: -1, userInfo: nil)))
            return
        }
        performSimpleRequest(request: request, completion: completion)
    }

    func sendTextToServer(email: String, authToken: String, text: String, sphereId: String, completion: @escaping (Result<Bool, Error>) -> Void) {
        let parameters: [String: Any] = ["email": email, "authToken": authToken, "text": text, "sphereId": sphereId]
        guard let request = createPostRequest(urlString: "\(serverURL)send-text", parameters: parameters) else {
            completion(.failure(NSError(domain: "com.openspace.error", code: -1, userInfo: nil)))
            return
        }
        performSimpleRequest(request: request, completion: completion)
    }

    func submitToServer(username: String, email: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let parameters: [String: Any] = ["username": username, "email": email, "authToken": Defaults[.authToken]]
        guard let request = createPostRequest(urlString: "\(serverURL)save-username", parameters: parameters) else {
            completion(.failure(NSError(domain: "com.openspace.error", code: -1, userInfo: nil)))
            return
        }
        performSimpleRequest(request: request, completion: completion)
    }

    func resetUsername(email: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let parameters: [String: Any] = ["email": email, "authToken": Defaults[.authToken]]
        guard let request = createPostRequest(urlString: "\(serverURL)reset-username", parameters: parameters) else {
            completion(.failure(NSError(domain: "com.openspace.error", code: -1, userInfo: nil)))
            return
        }
        performSimpleRequest(request: request, completion: completion)
    }

    func createSphere(email: String, authToken: String, sphereName: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let parameters: [String: Any] = ["email": email, "authToken": authToken, "sphereName": sphereName]
        guard let request = createPostRequest(urlString: "\(serverURL)create-sphere", parameters: parameters) else {
            completion(.failure(NSError(domain: "com.openspace.error", code: -1, userInfo: nil)))
            return
        }
        performSimpleRequest(request: request, completion: completion)
    }

    func createSpaceStation(email: String, authToken: String, configJson: String, spaceStationName: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let parameters: [String: Any] = ["email": email, "authToken": authToken, "configJson": configJson, "spaceStationName": spaceStationName]
        guard let request = createPostRequest(urlString: "\(serverURL)create-space-station", parameters: parameters) else {
            completion(.failure(NSError(domain: "com.openspace.error", code: -1, userInfo: nil)))
            return
        }
        performSimpleRequest(request: request, completion: completion)
    }

    func getLocation(email: String, authToken: String, completion: @escaping (Result<(String, String?, [[String: Any]]?, [[String: Any]]?, [String: Any]?), Error>) -> Void) {
        let parameters: [String: Any] = ["email": email, "authToken": authToken]
        guard let request = createPostRequest(urlString: "\(serverURL)get-data", parameters: parameters) else {
            completion(.failure(NSError(domain: "com.openspace.error", code: -1, userInfo: nil)))
            return
        }

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                completion(.failure(NSError(domain: "com.openspace.error", code: -1, userInfo: nil)))
                return
            }
            guard let data = data else {
                completion(.failure(NSError(domain: "com.openspace.error", code: -1, userInfo: nil)))
                return
            }

            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    if let location = json["last_location"] as? String {
                        let username = json["username"] as? String
                        let yourSpheres = json["your_spheres"] as? [[String: Any]]
                        let neighborSpheres = json["neighbor_spheres"] as? [[String: Any]]
                        let spaceStation = json["your_space_station"] as? [String: Any]
                        completion(.success((location, username, yourSpheres, neighborSpheres, spaceStation)))
                    } else if let errorString = json["error"] as? String, errorString == "Invalid authToken." {
                        self.refreshAuthToken { newToken, tokenError in
                            if let newToken = newToken {
                                Defaults[.authToken] = newToken
                                self.getLocation(email: email, authToken: newToken, completion: completion)
                            } else {
                                completion(.failure(tokenError ?? NSError(domain: "com.openspace.error", code: -1, userInfo: nil)))
                            }
                        }
                    } else {
                        completion(.failure(NSError(domain: "com.openspace.error", code: -1, userInfo: nil)))
                    }
                } else {
                    completion(.failure(NSError(domain: "com.openspace.error", code: -1, userInfo: nil)))
                }
            } catch {
                completion(.failure(error))
            }
        }

        task.resume()
    }

    // MARK: - WebSocket

    func initWebsocket() {
        let serverURL = URL(string: "wss://server3.openspace.greenrobot.com:8080")!
        let session = URLSession(configuration: .default)
        webSocketTask = session.webSocketTask(with: serverURL)
        webSocketTask?.resume()
        receiveMessages()
    }

    func receiveMessages() {
        webSocketTask?.receive { result in
            switch result {
            case .success(let message):
                switch message {
                case .string(let text):
                    print("Received message: \(text)")
                case .data(let data):
                    if let text = String(data: data, encoding: .utf8) {
                        print("Received message: \(text)")
                    }
                @unknown default:
                    fatalError()
                }
                self.receiveMessages() // Continue listening for messages
            case .failure(let error):
                print("Error receiving message: \(error)")
            }
        }
    }

    // MARK: - Helper Methods

    private func performRequest<T: Codable>(request: URLRequest, completion: @escaping (Result<T, FetchDataError>) -> Void) {
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(.networkError(error)))
                return
            }
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                completion(.failure(.invalidResponse))
                return
            }
            guard let data = data else {
                completion(.failure(.invalidResponse))
                return
            }
            do {
                let responseData = try JSONDecoder().decode(T.self, from: data)
                completion(.success(responseData))
            } catch {
                completion(.failure(.jsonParsingError(error)))
            }
        }
        task.resume()
    }

    private func performSimpleRequest<T>(request: URLRequest, completion: @escaping (Result<T, Error>) -> Void) {
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                completion(.failure(NSError(domain: "com.openspace.error", code: -1, userInfo: nil)))
                return
            }
            guard let data = data else {
                completion(.failure(NSError(domain: "com.openspace.error", code: -1, userInfo: nil)))
                return
            }

            do {
                if T.self == Void.self {
                    completion(.success(() as! T))
                } else if T.self == Bool.self {
                    completion(.success(true as! T))
                } else if let responseData = try JSONSerialization.jsonObject(with: data, options: []) as? T {
                    completion(.success(responseData))
                } else {
                    completion(.failure(NSError(domain: "com.openspace.error", code: -1, userInfo: nil)))
                }
            } catch {
                completion(.failure(error))
            }
        }
        task.resume()
    }

    // Function to refresh the Firebase auth token
    func refreshAuthToken(completion: @escaping (String?, Error?) -> Void) {
        Auth.auth().currentUser?.getIDTokenForcingRefresh(true) { (token, error) in
            if let error = error {
                completion(nil, error)
            } else if let token = token {
                completion(token, nil)
            } else {
                completion(nil, NSError(domain: "com.openspace.error", code: -1, userInfo: nil))
            }
        }
    }
}

// Helper extension to encode parameters
extension Dictionary {
    func percentEncoded() -> Data? {
        return map { key, value in
            let escapedKey = "\(key)".addingPercentEncoding(withAllowedCharacters: .urlQueryValueAllowed) ?? ""
            let escapedValue = "\(value)".addingPercentEncoding(withAllowedCharacters: .urlQueryValueAllowed) ?? ""
            return escapedKey + "=" + escapedValue
        }
        .joined(separator: "&")
        .data(using: .utf8)
    }
}

extension CharacterSet {
    static let urlQueryValueAllowed: CharacterSet = {
        var allowed = CharacterSet.urlQueryAllowed
        allowed.remove(charactersIn: "&")
        return allowed
    }()
}
