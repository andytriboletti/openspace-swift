//
//  OpenspaceAPI.swift
//  Open Space
//
//  Created by Andrew Triboletti on 7/14/23.
//  Copyright © 2023 GreenRobot LLC. All rights reserved.
//

import Foundation

class OpenspaceAPI {
    static let shared = OpenspaceAPI()
    
    func
    loginWithEmail(email: String, authToken: String, completion: @escaping (String?, Error?) -> Void) {
        let url = URL(string: "https://server.openspace.greenrobot.com/wp-json/openspace/v1/login")!
        var request = URLRequest(url: url)
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
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
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
                        
                        if let lastLocation = jsonObject["last_location"] {
                            // Assuming "last_location" is a key in the JSON response.
                            print("last_location: \(lastLocation)")
                            
                            completion((lastLocation as! String), nil)
                            //return lastLocation
                            //todo set game state to lastLocation
                            
                            //todo if lastLocation == "" set lastLocation to nearEarth
                            
                            //todo load game view
                            
                            
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
    
    //save users location
    
    
    
    func saveLocation(email: String, authToken: String, location: String, completion: @escaping (String?, Error?) -> Void) {
            let url = URL(string: "https://server.openspace.greenrobot.com/wp-json/openspace/v1/save-location")!
            var request = URLRequest(url: url)
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
            
            let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
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
    
    
    
    
    
    //get location
    func getLocation(email: String, authToken: String, completion: @escaping (String?, Error?) -> Void) {
            let url = URL(string: "https://server.openspace.greenrobot.com/wp-json/openspace/v1/get-location")!
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            
            let parameters: [String: Any] = [
                "email": email,
                "authToken": authToken,
            ]
            print(authToken)
            do {
                request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: [])
            } catch {
                // Handle the error
                completion(nil, error)
                return
            }
            
            let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
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
                        if let location = json["last_location"] as? String {
                            // User deleted successfully
                            completion(location, nil)
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
    
    
    
    
    
    
    
    
    
    //delete user
    
    func deleteUser(email: String, authToken: String, completion: @escaping (String?, Error?) -> Void) {
            let url = URL(string: "https://server.openspace.greenrobot.com/wp-json/openspace/v1/delete-user")!
            var request = URLRequest(url: url)
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
            
            let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
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
