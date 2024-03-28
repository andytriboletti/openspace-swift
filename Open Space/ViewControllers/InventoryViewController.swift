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

class InventoryViewController: UIViewController, UITableViewDataSource, UITableViewDelegate  {
    
    @IBOutlet weak var tableView: UITableView!
        
        var dataArray: [[String: Any]] = [] // Your mineral data array
  
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return dataArray.count
        }
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CargoCell", for: indexPath)
            
            let mineralDict = dataArray[indexPath.row]
            let mineralName = mineralDict["mineral_name"] as? String
            let kilograms = mineralDict["kilograms"] as? String
            
            cell.textLabel?.text = "Mineral: \(mineralName ?? "")" + "  Weight: \(kilograms ?? "")" + " kg"
            //cell.detailTextLabel?.text = "Weight: \(kilograms ?? "")"
            
            return cell
        }
    
    @IBOutlet weak var errorLabel: UILabel!

    override func viewWillAppear(_ animated: Bool) {
        getUserMinerals(email: Defaults[.email])

    }
    override func viewDidLoad() {
        super.viewDidLoad()
        //? cause it may be on another tab by now
        tableView?.dataSource = self
        tableView?.delegate = self
        tableView?.reloadData()
    }
        // Your other properties and methods
        func getUserMinerals(email: String) {
            let myUrl = "https://server2.openspace.greenrobot.com/wp-json/openspace/v1/get-user-minerals"
            guard let url = URL(string: myUrl) else {
                print("Invalid URL")
                return
            }
            print(email)
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
                        // Assuming you have the responseDict from your network request
                        if let userMineralsArray = responseDict?["user_minerals"] as? [[String: Any]] {
                            self.dataArray = userMineralsArray
                        }
                        DispatchQueue.main.async {
                                self.tableView?.reloadData()
                            }
                        if let responseDict = responseDict,
                           let userMineralsArray = responseDict["user_minerals"] as? [[String: Any]],
                           let firstMineral = userMineralsArray.first,
                           let mineralName = firstMineral["mineral_name"] as? String {
                            print("Mineral Name:", mineralName)
                        } else {
                            print("Invalid JSON format or missing data")
                        }

                    } catch {
                        print("Error decoding JSON: \(error)")
                    }
                }.resume()
            }
             catch {
                print("Error creating JSON data: \(error)")
            }
        }
}

struct UserMineral: Codable {
    let kilograms: String
    let mineralId: Int
    let mineralName: String
    let userId: Int

    enum CodingKeys: String, CodingKey {
        case kilograms
        case mineralId = "mineral_id"
        case mineralName = "mineral_name"
        case userId = "user_id"
    }
}
