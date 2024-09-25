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

       static func loadComments(board_id: String, app_id: String, app_secret: String, completion: @escaping ([Comment]?, Error?) -> Void) {
           let url = URL(string: baseURL + "get_comment_board")!

           var request = URLRequest(url: url)
           request.httpMethod = "POST"

           // Set the request body
           let requestBody: [String: Any] = [
               "board_id": board_id,
               "app_id": app_id,
               "app_secret": app_secret
           ]

           request.httpBody = try? JSONSerialization.data(withJSONObject: requestBody, options: [])
           request.setValue("application/json", forHTTPHeaderField: "Content-Type")

           // Create URL session
           let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
               guard let data = data, error == nil else {
                   completion(nil, error)
                   return
               }

               do {
                   // Print raw JSON for debugging purposes
                   if let jsonString = String(data: data, encoding: .utf8) {
                       print("Raw JSON: \(jsonString)")
                   }

                   // Decode the JSON into an array of Comment objects
                   let comments = try JSONDecoder().decode([Comment].self, from: data)
                   completion(comments, nil)
               } catch let decodingError {
                   print("Error decoding JSON: \(decodingError.localizedDescription)")
                   completion(nil, decodingError)
               }
           }
           task.resume()
       }
    
    static func postComment(board_id: String, app_id: String, app_secret: String, comment_text: String, username: String, completion: @escaping (Bool, Error?) -> Void) {
        let url = URL(string: baseURL + "post_comment")! // Adjust the endpoint for posting comments
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        // Set the request body for posting the comment
        let requestBody: [String: Any] = [
            "board_id": board_id,
            "app_id": app_id,
            "app_secret": app_secret,
            "comment_text": comment_text,
            "username": username
        ]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: requestBody, options: [])
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Create URL session
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let _ = data, error == nil else {
                completion(false, error)
                return
            }
            
            // Assuming the post was successful
            completion(true, nil)
        }
        task.resume()
    }
}

// Comment model
struct Comment: Codable {
    let board_id: String
    let created_at: String
    let comment_text: String
    let username: String
}
// Example usage
//AlienTavern.loadComments(board_id: "testboard123", app_id: "1499913239", app_secret: "c934b3a03d97f5cfccb1482bf219c7bf") { comments, error in
//    if let error = error {
//        print("Error loading comments: \(error)")
//    } else if let comments = comments {
//        print("Comments loaded successfully:")
//        for comment in comments {
//            print("\(comment.username): \(comment.comment_text) at \(comment.created_at)")
//        }
//    }
//}
//
//AlienTavern.postComment(board_id: "testboard123", app_id: "1499913239", app_secret: "c934b3a03d97f5cfccb1482bf219c7bf", comment_text: "New comment", username: "User1") { success, error in
//    if success {
//        print("Comment posted successfully.")
//    } else if let error = error {
//        print("Error posting comment: \(error)")
//    }
//}
