//
//  AlienTavern.swift
//  Open Space
//
//  Created by Andrew Triboletti on 9/21/24.
//  Copyright © 2024 GreenRobot LLC. All rights reserved.
//
import Foundation
import JWTDecode // You'll need to add this dependency to your project

class AlienTavern {
    static let baseURL = "https://alientavern.com/api/"
    static var jwtToken: String?


    enum APIError: Error {
        case invalidURL
        case networkError(Error)
        case decodingError(Error)
        case encodingError(Error)
        case invalidResponse
        case authenticationError
        case serverError(String)
        case emptyResponse
    }






    static func authenticate(appID: String, appSecret: String, completion: @escaping (Result<Void, APIError>) -> Void) {
        print("AlienTavern: Starting authentication process")
        guard let url = URL(string: baseURL + "authenticate") else {
            print("AlienTavern: Invalid URL")
            completion(.failure(.invalidURL))
            return
        }

        print("AlienTavern: Creating URL request")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body = ["app_id": appID, "app_secret": appSecret]
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        } catch {
            print("AlienTavern: Failed to serialize request body: \(error)")
            completion(.failure(.encodingError(error)))
            return
        }

        print("AlienTavern: Sending authentication request to \(url)")
        print("AlienTavern: Request headers: \(request.allHTTPHeaderFields ?? [:])")
        print("AlienTavern: Request body: \(String(data: request.httpBody ?? Data(), encoding: .utf8) ?? "")")

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            print("AlienTavern: Received response from server")
            if let error = error {
                print("AlienTavern: Network error occurred: \(error.localizedDescription)")
                completion(.failure(.networkError(error)))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                print("AlienTavern: Invalid response type")
                completion(.failure(.invalidResponse))
                return
            }

            print("AlienTavern: Received response with status code: \(httpResponse.statusCode)")
            print("AlienTavern: Response headers: \(httpResponse.allHeaderFields)")

            guard (200...299).contains(httpResponse.statusCode) else {
                print("AlienTavern: Server responded with error status code: \(httpResponse.statusCode)")
                completion(.failure(.serverError("Server responded with status code \(httpResponse.statusCode)")))
                return
            }

            guard let data = data else {
                print("AlienTavern: Received empty response data")
                completion(.failure(.emptyResponse))
                return
            }

            print("AlienTavern: Received response data: \(String(data: data, encoding: .utf8) ?? "Unable to decode response")")

            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                    print("AlienTavern: Parsed JSON response: \(json)")
                    if let token = json["token"] as? String {
                        self.jwtToken = token
                        print("AlienTavern: Successfully extracted token")
                        completion(.success(()))
                    } else {
                        print("AlienTavern: Token not found in response")
                        completion(.failure(.authenticationError))
                    }
                } else {
                    print("AlienTavern: Unable to parse response as JSON")
                    completion(.failure(.decodingError(NSError(domain: "AlienTavern", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid JSON structure"]))))
                }
            } catch {
                print("AlienTavern: JSON parsing error: \(error.localizedDescription)")
                completion(.failure(.decodingError(error)))
            }
        }

        print("AlienTavern: Starting network request")
        task.resume()
    }

    static func loadComments(boardID: String, completion: @escaping (Result<[Comment], APIError>) -> Void) {
        guard let token = jwtToken else {
            completion(.failure(.authenticationError))
            return
        }

        let url = URL(string: baseURL + "get_comment_board")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let body = ["board_id": boardID]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(.networkError(error)))
                return
            }

            guard let data = data else {
                completion(.failure(.invalidResponse))
                return
            }

            do {
                let comments = try JSONDecoder().decode([Comment].self, from: data)
                completion(.success(comments))
            } catch {
                completion(.failure(.decodingError(error)))
            }
        }.resume()
    }

    static func postComment(boardID: String, commentText: String, username: String, completion: @escaping (Result<Void, APIError>) -> Void) {
        guard let token = jwtToken else {
            completion(.failure(.authenticationError))
            return
        }

        let url = URL(string: baseURL + "post_comment")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let body: [String: Any] = [
            "board_id": boardID,
            "comment_text": commentText,
            "username": username
        ]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(.networkError(error)))
                return
            }

            guard let data = data else {
                completion(.failure(.invalidResponse))
                return
            }

            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let success = json["success"] as? Bool, success {
                    completion(.success(()))
                } else {
                    let errorMessage = (try? JSONDecoder().decode(ErrorResponse.self, from: data))?.error ?? "Unknown error"
                    completion(.failure(.serverError(errorMessage)))
                }
            } catch {
                completion(.failure(.decodingError(error)))
            }
        }.resume()
    }
}

struct Comment: Codable {
    let boardID: String
    let createdAt: String
    let commentText: String
    let username: String

    enum CodingKeys: String, CodingKey {
        case boardID = "board_id"
        case createdAt = "created_at"
        case commentText = "comment_text"
        case username
    }
}

struct ErrorResponse: Codable {
    let error: String
}
