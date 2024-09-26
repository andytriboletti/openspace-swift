//
//  AlienTavern.swift
//  Open Space
//
//  Created by Andrew Triboletti on 9/21/24.
//  Copyright © 2024 GreenRobot LLC. All rights reserved.
//
import Foundation

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
        guard let url = URL(string: baseURL + "authenticate") else {
            completion(.failure(.invalidURL))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body = ["app_id": appID, "app_secret": appSecret]
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        } catch {
            completion(.failure(.encodingError(error)))
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(.networkError(error)))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                completion(.failure(.invalidResponse))
                return
            }

            guard let data = data else {
                completion(.failure(.emptyResponse))
                return
            }

            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let token = json["token"] as? String {
                    self.jwtToken = token
                    completion(.success(()))
                } else {
                    completion(.failure(.authenticationError))
                }
            } catch {
                completion(.failure(.decodingError(error)))
            }
        }.resume()
    }

    static func loadComments(boardID: String, completion: @escaping (Result<[Comment], APIError>) -> Void) {
        guard let token = jwtToken else {
            completion(.failure(.authenticationError))
            return
        }

        guard let url = URL(string: baseURL + "get_comment_board") else {
            completion(.failure(.invalidURL))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let body = ["board_id": boardID]
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        } catch {
            completion(.failure(.encodingError(error)))
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(.networkError(error)))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                completion(.failure(.invalidResponse))
                return
            }

            guard let data = data else {
                completion(.failure(.emptyResponse))
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

        guard let url = URL(string: baseURL + "post_comment") else {
            completion(.failure(.invalidURL))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let body: [String: Any] = [
            "board_id": boardID,
            "comment_text": commentText,
            "username": username
        ]

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        } catch {
            completion(.failure(.encodingError(error)))
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(.networkError(error)))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                completion(.failure(.invalidResponse))
                return
            }

            guard let data = data else {
                completion(.failure(.emptyResponse))
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

struct ErrorResponse: Codable {
    let error: String
}
