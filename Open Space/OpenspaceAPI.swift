//
//  OpenspaceAPI.swift
//  Open Space
//
//  Created by Andrew Triboletti on 7/14/23.
//  Copyright © 2023 GreenRobot LLC. All rights reserved.

import Foundation
import FirebaseAuth
import Defaults

class OpenspaceAPI {
    static let shared = OpenspaceAPI()
    let serverURL = "https://server2.openspace.greenrobot.com/wp-json/openspace/v1/"

    // static let shared = OpenspaceAPI()
    var webSocketTask: URLSessionWebSocketTask?

    // Common server URL
    // let serverURL = "https://server2.openspace.greenrobot.com/wp-json/openspace/v1/"
    var pendingModels: [Int: [String: String]] = [:]
    var completedModels: [Int: [String: String]] = [:]

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

    func fetchData(email: String, authToken: String, completion: @escaping (Result<(ResponseData), FetchDataError>) -> Void) {
        // Prepare JSON data
        let jsonData: [String: Any] = [
            "email": email,
            "authToken": authToken
        ]

        // Convert JSON data to Data
        guard let postData = try? JSONSerialization.data(withJSONObject: jsonData) else {
            completion(.failure(.invalidResponse))
            return
        }

        // Create URL request
        let url = URL(string: "https://server2.openspace.greenrobot.com/wp-json/openspace/v1/get-prompts-and-models")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = postData

        // Perform the request
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard error == nil else {
                completion(.failure(.networkError(error!)))
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
                let responseData = try JSONDecoder().decode(ResponseData.self, from: data)
                completion(.success(responseData))
            } catch {
                completion(.failure(.jsonParsingError(error)))
            }
        }

        task.resume()
    }

    func fetchNeighbors(email: String, authToken: String, completion: @escaping (Result<[Neighbor], FetchDataError>) -> Void) {
        // Prepare JSON data
        let jsonData: [String: Any] = [
            "email": email,
            "authToken": authToken
        ]

        // Convert JSON data to Data
        guard let postData = try? JSONSerialization.data(withJSONObject: jsonData) else {
            completion(.failure(.invalidResponse))
            return
        }

        // Create URL request
        let url = URL(string: "https://server2.openspace.greenrobot.com/wp-json/openspace/v1/get-neighbor-spheres")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = postData

        // Perform the request
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard error == nil else {
                completion(.failure(.networkError(error!)))
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
                let responseData = try JSONDecoder().decode(Response.self, from: data)
                completion(.success(responseData.results))
            } catch {
                completion(.failure(.jsonParsingError(error)))
            }
        }

        task.resume()
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

    func checkDailyTreasureAvailability(planet: String, completion: @escaping (String?, Error?) -> Void) {
        let email = Defaults[.email]
        let authToken = Defaults[.authToken]
        let apiUrl = "\(serverURL)check-daily-treasure"

        guard let url = URL(string: apiUrl) else {
            completion(nil, NSError(domain: "com.openspace.error", code: -1, userInfo: nil))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let parameters: [String: Any] = ["email": email, "authToken": authToken, "planet": planet]

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: [])
        } catch {
            completion(nil, error)
            return
        }

        let task = URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error {
                completion(nil, error)
                return
            }

            if let data = data {
                //     if let data = data {
                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any], let status = json["status"] as? String {
                        completion(status, nil)

                    }
                } catch {
                    // Handle JSON parsing error on the main thread
                    return
                }
            }
            // Parse JSON response and handle accordingly
            // ...

            // Call completion handler with appropriate data
            // completion(data, nil)
        }
        // }

        task.resume()
    }

    func claimDailyTreasure(planet: String, completion: @escaping (String?, String?, Int?, Error?) -> Void) {
        let email = Defaults[.email]
        let authToken = Defaults[.authToken]
        let apiUrl = "\(serverURL)claim-daily-treasure"

        guard let url = URL(string: apiUrl) else {
            completion(nil, nil, nil, NSError(domain: "com.openspace.error", code: -1, userInfo: nil))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let parameters: [String: Any] = ["email": email, "authToken": authToken, "planet": planet]

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: [])
        } catch {
            completion(nil, nil, nil, error)
            return
        }

        let task = URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error {
                completion(nil, nil, nil, error)
                return
            }
            if let data = data {
                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                       let status = json["status"] as? String,
                       let mineral = json["mineral"] as? String,
                       let amount = json["amount"] as? Int {
                        completion(status, mineral, amount, nil)
                    }
                } catch {
                    completion(nil, nil, nil, error)
                }
            }
        }

        task.resume()
    }

    func initWebsocket() {

        // Replace with your WebSocket server URL
        let serverURL = URL(string: "wss://server2.openspace.greenrobot.com:8080")!

        let session = URLSession(configuration: .default)
        webSocketTask = session.webSocketTask(with: serverURL)

        webSocketTask!.resume()

        // Start receiving messages
        receiveMessages()
    }

    func receiveMessages() {
        webSocketTask!.receive { result in
            switch result {
            case .success(let message):
                switch message {
                case .string(let text):
                    print("Received message: \(text)")
                case .data(let data):
                    if let text = String(data: data, encoding: .utf8) {
                        print("Received message: \(text)")
                    }
                }
                self.receiveMessages() // Continue listening for messages
            case .failure(let error):
                print("Error receiving message: \(error)")
            }
        }
    }

    // if user not found, insert user into database
    func
    loginWithEmail(email: String, authToken: String, completion: @escaping (String?, Error?) -> Void) {
        let loginURL = URL(string: "\(serverURL)login")!
        var request = URLRequest(url: loginURL)
        request.httpMethod = "POST"

        let parameters: [String: Any] = [
            "email": email,
            "authToken": authToken
        ]
        print("email:")
        print(email)
        print("authToken")
        print(authToken)
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: [])
        } catch {
            completion(nil, error)
            return
        }

        let task = URLSession.shared.dataTask(with: request) { (data, _, error) in
            if let error = error {
                completion(nil, error)
                return
            }

            guard let data = data else {
                let error = NSError(domain: "com.openspace.error", code: -1, userInfo: nil)
                completion(nil, error)
                return
            }

            if let responseString = String(data: data, encoding: .utf8) {
                print("Server response: \(responseString)")

                do {
                    if let jsonObject = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                        // Assuming "data" is a dictionary at the top level of the JSON response.

                        if let lastLocation = jsonObject["last_location"] as? String {
                            // Assuming "last_location" is a key in the JSON response.
                            print("last_location: \(lastLocation)")

                            if let userId = jsonObject["id"] as? String {
                                Defaults[.userId] = userId
                                print("setting userid")
                                print(userId)
                            } else {
                                print("Error: Unable to retrieve userId from JSON.")
                                // Handle the case where userId is not present or not of type String.
                                // Optionally, you can set a default value for userId or handle the error appropriately.
                            }

                            completion(lastLocation, nil)
                            // todo set game state to lastLocation

                            // todo if lastLocation == "" set lastLocation to nearEarth

                            // todo load game view

                        } else {
                            print("last_location not found in the JSON response.")
                        }
                    } else {
                        print("Failed to parse JSON.")
                    }
                } catch {
                    print("Error parsing JSON: \(error)")
                    completion(nil, error)

                }

            }

        }

        task.resume()
    }

    // save users location

    func saveLocation(email: String, authToken: String, location: String, completion: @escaping (String?, Error?) -> Void) {
        let saveLocationURL = URL(string: "\(serverURL)save-location")!
        var request = URLRequest(url: saveLocationURL)
        request.httpMethod = "POST"

        let parameters: [String: Any] = [
            "email": email,
            "authToken": authToken,
            "location": location
        ]
        print(authToken)
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: [])
        } catch {
            // Handle the error
            completion(nil, error)
            return
        }

        let task = URLSession.shared.dataTask(with: request) { (data, _, error) in
            // Handle the server response
            if let error = error {
                // Handle the error
                completion(nil, error)
                return
            }

            guard let data = data else {
                completion(nil, NSError(domain: "com.openspace.error", code: -1, userInfo: nil))
                return
            }

            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    if let message = json["message"] as? String {
                        // User deleted successfully
                        completion(message, nil)
                    } else if let error = json["error"] as? String {
                        // Error saving location
                        completion(nil, NSError(domain: "com.openspace.error", code: -1, userInfo: [NSLocalizedDescriptionKey: error]))
                    }
                }
            } catch {
                // Handle the error
                completion(nil, error)
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

    // Get location
    func getLocation(email: String, authToken: String, completion: @escaping (String?, String?, Error?) -> Void) {
        let getLocationURL = URL(string: "\(serverURL)get-data")!
        var request = URLRequest(url: getLocationURL)
        request.httpMethod = "POST"

        let parameters: [String: Any] = [
            "email": email,
            "authToken": authToken
        ]

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: [])
        } catch {
            // Handle the error
            completion(nil, nil, error)
            return
        }

        let task = URLSession.shared.dataTask(with: request) { [self] (data, _, error) in
            // Handle the server response
            if let error = error {
                // Handle the error
                DispatchQueue.main.async {
                    completion(nil, nil, error)
                }
                return
            }

            guard let data = data else {
                DispatchQueue.main.async {
                    completion(nil, nil, NSError(domain: "com.openspace.error", code: -1, userInfo: nil))
                }
                return
            }

            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    if let location = json["last_location"] as? String {
                        // Location retrieved successfully
                        let username = json["username"] as? String
                        print(location)
                        print(username)
                        DispatchQueue.main.async {
                            completion(location, username, nil)
                        }
                    } else if let error = json["error"] as? String {
                        if error == "Invalid authToken." {
                            // Retry with a refreshed token
                            refreshAuthToken { (newToken, tokenError) in
                                if let newToken = newToken {
                                    Defaults[.authToken] = newToken
                                    print(newToken)
                                    // Retry the request with the new token
                                    DispatchQueue.main.async {
                                        self.getLocation(email: email, authToken: authToken, completion: completion)
                                    }
                                } else {
                                    // Failed to refresh token or get a new token
                                    DispatchQueue.main.async {
                                        completion(nil, nil, tokenError ?? NSError(domain: "com.openspace.error", code: -1, userInfo: nil))
                                    }
                                }
                            }
                        } else {
                            // Other errors from the server
                            DispatchQueue.main.async {
                                completion(nil, nil, NSError(domain: "com.openspace.error", code: -1, userInfo: [NSLocalizedDescriptionKey: error]))
                            }
                        }
                    }
                }
            } catch {
                // Handle the error
                DispatchQueue.main.async {
                    completion(nil, nil, error)
                }
            }
        }

        task.resume()
    }

    // delete user
    func deleteUser(email: String, authToken: String, completion: @escaping (String?, Error?) -> Void) {
        let deleteUserURL = URL(string: "\(serverURL)delete-user")!
        var request = URLRequest(url: deleteUserURL)
        request.httpMethod = "POST"
        let parameters: [String: Any] = [
            "email": email,
            "authToken": authToken
        ]
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: [])
        } catch {
            // Handle the error
            completion(nil, error)
            return
        }
        let task = URLSession.shared.dataTask(with: request) { (data, _, error) in
            // Handle the server response
            if let error = error {
                // Handle the error
                completion(nil, error)
                return
            }
            guard let data = data else {
                completion(nil, NSError(domain: "com.openspace.error", code: -1, userInfo: nil))
                return
            }
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    if let message = json["message"] as? String {
                        // User deleted successfully
                        completion(message, nil)
                    } else if let error = json["error"] as? String {
                        // Error deleting user
                        completion(nil, NSError(domain: "com.openspace.error", code: -1, userInfo: [NSLocalizedDescriptionKey: error]))
                    }
                }
            } catch {
                // Handle the error
                completion(nil, error)
            }
        }
        task.resume()
    }

    // Function to send text to the server
    func sendTextToServer(email: String, authToken: String, text: String, completion: @escaping (Bool, Error?) -> Void) {
        // let sendTextURL = URL(string: "\(serverURL)send-prompt-text")!

        let sendTextURL = URL(string: "\(serverURL)send-text")! // Constructing the URL

        // let parameters: [String: Any] = ["text": text]
        let parameters: [String: Any] = [
            "email": email,
            "authToken": authToken,
            "text": text
        ]

        guard let jsonData = try? JSONSerialization.data(withJSONObject: parameters) else {
            completion(false, NSError(domain: "com.openspace.error", code: -1, userInfo: nil))
            return
        }

        var request = URLRequest(url: sendTextURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData

        let task = URLSession.shared.dataTask(with: request) { _, response, error in
            if let error = error {
                completion(false, error)
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                completion(false, NSError(domain: "com.openspace.error", code: -1, userInfo: nil))
                return
            }

            if (200...299).contains(httpResponse.statusCode) {
                completion(true, nil)
            } else {
                completion(false, NSError(domain: "com.openspace.error", code: httpResponse.statusCode, userInfo: nil))
            }
        }

        task.resume()
    }

    func submitToServer(username: String, email: String, completion: @escaping (Error?) -> Void) {
        // Validate username
        guard !username.isEmpty else {
            let error = NSError(domain: "Validation", code: 0, userInfo: [NSLocalizedDescriptionKey: "Username cannot be empty"])
            completion(error)
            return
        }

        // Call OpenspaceAPI.shared to submit to server
        // let urlString = "https://example.com/api/submit"
        let urlString =  "\(serverURL)save-username" // Constructing the URL

        guard let url = URL(string: urlString) else {
            let error = NSError(domain: "Networking", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])
            completion(error)
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        // Prepare data to send
        let parameters: [String: Any] = [
            "username": username,
            "email": email,
            "authToken": Defaults[.authToken]
        ]
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: [])
        } catch {
            completion(error)
            return
        }

        // Send the request
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(error)
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                let error = NSError(domain: "Networking", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid response"])
                completion(error)
                return
            }

            if (200..<300).contains(httpResponse.statusCode) {
                // Success
                if let data = data {
                    do {
                        if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                            if let success = jsonResponse["success"] as? Int {
                                if success == 1 {
                                    // Username saved successfully
                                    completion(nil)
                                } else {
                                    // Username not saved
                                    let errorMessage = jsonResponse["message"] as? String ?? "Unknown error"
                                    let error = NSError(domain: "Server", code: 0, userInfo: [NSLocalizedDescriptionKey: errorMessage])
                                    completion(error)
                                }
                            } else {
                                let error = NSError(domain: "Server", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid response format"])
                                completion(error)
                            }
                        } else {
                            let error = NSError(domain: "Server", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid JSON response"])
                            completion(error)
                        }
                    } catch {
                        completion(error)
                    }
                } else {
                    let error = NSError(domain: "Server", code: 0, userInfo: [NSLocalizedDescriptionKey: "No data received"])
                    completion(error)
                }
            } else {
                // Server error
                let error = NSError(domain: "Server", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Server error"])
                completion(error)
            }
        }

        task.resume()
    }

    func resetUsername(email: String, completion: @escaping (Error?) -> Void) {
        // Validate username
//        guard !username.isEmpty else {
//            let error = NSError(domain: "Validation", code: 0, userInfo: [NSLocalizedDescriptionKey: "Username cannot be empty"])
//            completion(error)
//            return
//        }

        // Call OpenspaceAPI.shared to submit to server
        // let urlString = "https://example.com/api/submit"
        let urlString =  "\(serverURL)reset-username" // Constructing the URL

        guard let url = URL(string: urlString) else {
            let error = NSError(domain: "Networking", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])
            completion(error)
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        // Prepare data to send
        let parameters: [String: Any] = [
            "email": email,
            "authToken": Defaults[.authToken]
        ]
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: [])
        } catch {
            completion(error)
            return
        }

        // Send the request
        let task = URLSession.shared.dataTask(with: request) { _, response, error in
            if let error = error {
                completion(error)
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                let error = NSError(domain: "Networking", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid response"])
                completion(error)
                return
            }

            if (200..<300).contains(httpResponse.statusCode) {
                // Success
                completion(nil)
            } else {
                // Server error
                let error = NSError(domain: "Server", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Server error"])
                completion(error)
            }
        }

        task.resume()
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
