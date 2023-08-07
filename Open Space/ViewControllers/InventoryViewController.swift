//
//  InventoryViewController.swift
//  Open Space
//
//
//  Created by Andy Triboletti on 2/19/20.
//  Copyright © 2023 GreenRobot LLC. All rights reserved.
//

import UIKit
import Defaults

class InventoryViewController: UIViewController {
    @IBOutlet weak var errorLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        getUserMinerals(email: Defaults[.email])
    }
        // Your other properties and methods
        func getUserMinerals(email: String) {
            let myUrl = "https://server.openspace.greenrobot.com/wp-json/openspace/v1/get-user-minerals"
            guard let url = URL(string: myUrl) else {
                print("Invalid URL")
                return
            }
            let requestData: [String: Any] = ["email": email]
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: requestData)
                var request = URLRequest(url: url)
                request.httpMethod = "POST"
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                request.httpBody = jsonData
                URLSession.shared.dataTask(with: request) { data, response, error in
                    print(response as Any)
                    if let error = error {
                        print("Error: \(error)")
                        return
                    }
                    guard let data = data else {
                        print("No data received")
                        return
                    }
                    do {
                        let responseDict = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                        
                        // Check if the response contains an error message
                        if let errorMessage = responseDict?["message"] as? String {
                            print("Error message: \(errorMessage)")
                            // Handle the error message here, such as displaying it to the user
                        } else if let userMineralsArray = responseDict?["userMinerals"] as? [[String: Any]] {
                            let userMinerals = try JSONDecoder().decode([UserMineral].self, from: JSONSerialization.data(withJSONObject: userMineralsArray))
                            print(userMinerals)
                            // Process the decoded user minerals array here
                        } else {
                            print("User minerals array not found in response.")
                        }
                    } catch {
                        print("Error decoding JSON: \(error)")
                    }
                    do {
                        let responseDict = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                        
                        // Check if the response contains an error message
                        if let errorMessage = responseDict?["error"] as? String {
                            DispatchQueue.main.async {
                                // Update the errorLabel text with the error message
                                self.errorLabel.text = errorMessage
                            }
                        } else if let userMineralsArray = responseDict?["userMinerals"] as? [[String: Any]] {
                            let userMinerals = try JSONDecoder().decode([UserMineral].self, from: JSONSerialization.data(withJSONObject: userMineralsArray))
                            // Process the decoded user minerals array here
                        } else {
                            DispatchQueue.main.async {
                                // Update the errorLabel text when user minerals array is not found
                                self.errorLabel.text = "User minerals array not found in response."
                            }
                        }
                    } catch {
                        DispatchQueue.main.async {
                            // Update the errorLabel text with the decoding error
                            self.errorLabel.text = "Error decoding JSON: \(error)"
                        }
                    }
                }.resume()
            } catch {
                print("Error creating JSON data: \(error)")
            }
        }
}

struct UserMineral: Codable {
    let userid: Int
    let mineralid: Int
    let mineralname: String
    let kilograms: Double
}
