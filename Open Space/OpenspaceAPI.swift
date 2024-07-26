import Foundation
import FirebaseAuth
import Defaults
import Alamofire

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
        let meshId: Int

        enum CodingKeys: String, CodingKey {
            case textPrompt = "text_prompt"
            case completed
            case videoLocation = "video_location"
            case meshLocation = "mesh_location"
            case meshId = "mesh_id"
        }
    }

    struct ResponseData: Codable {
        let pending: [PromptData]
        let completed: [PromptData]
    }

    struct Neighbor: Codable {
        let userId: Int
        let username: String
        let itemCount: Int
        let sphereId: Int

        enum CodingKeys: String, CodingKey {
            case userId = "user_id"
            case username
            case itemCount = "item_count"
            case sphereId = "sphere_id"
        }
    }

    struct NeighborsResponse: Codable {
        let status: String
        let results: [Neighbor]
    }

    enum FetchDataError: Error {
        case networkError(Error)
        case missingUserId
        case invalidResponse
        case jsonParsingError(Error)
    }

    struct UserMineral: Codable {
        let userId: String
        let mineralId: String
        let mineralName: String
        let kilograms: String

        enum CodingKeys: String, CodingKey {
            case userId = "user_id"
            case mineralId = "mineral_id"
            case mineralName = "mineral_name"
            case kilograms
        }
    }


    struct UserMineralsResponse: Codable {
           let userMinerals: [UserMineral]

           enum CodingKeys: String, CodingKey {
               case userMinerals = "user_minerals"
           }
       }
    
    // MARK: - API Requests

    struct SphereDetailsResponse: Codable {
        struct Result: Codable {
            let id: String
            let mesh_location: String
        }

        let status: String
        let results: [Result]
    }


    func fetchSphereDetails(email: String, authToken: String, sphereId: Int, completion: @escaping (Result<[URL], FetchDataError>) -> Void) {
        let parameters: [String: Any] = ["email": email, "authToken": authToken, "sphereId": sphereId, "appToken": Defaults[.appToken]]
        let urlString = "\(serverURL)get-sphere-details"

        AF.request(urlString, method: .post, parameters: parameters, encoding: JSONEncoding.default)
            .validate()
            .responseDecodable(of: SphereDetailsResponse.self) { response in
                switch response.result {
                case .success(let responseData):
                    let zipFileURLs = responseData.results.compactMap { URL(string: $0.mesh_location) }
                    completion(.success(zipFileURLs))
                case .failure(let error):
                    completion(.failure(.networkError(error)))
                }
            }
    }


    
    func sendReceiptToServer(receipt: String, productIdentifier: String, completion: @escaping (Result<Void, FetchDataError>) -> Void) {
        #if DEBUG
        let urlString = "\(serverURL)verifyReceiptSandbox"
        #else
        let urlString = "\(serverURL)verifyReceipt"
        #endif

        // Retrieve the user ID from Defaults, ensuring it is optional
        guard let userId = Defaults[.userId] as Int? else {
            completion(.failure(.missingUserId))
            return
        }

        // Include the user ID in the parameters
        let parameters: [String: Any] = [
            "receipt-data": receipt,
            "productIdentifier": productIdentifier,
            "userId": userId,
            "appToken": Defaults[.appToken]
        ]

        AF.request(urlString, method: .post, parameters: parameters, encoding: JSONEncoding.default)
            .validate()
            .responseJSON { response in
                switch response.result {
                case .success:
                    completion(.success(()))
                case .failure(let error):
                    completion(.failure(.networkError(error)))
                }
            }
    }
    func addSubscription(userId: Int, originalTransactionId: String, productIdentifier: String, completion: @escaping (Result<Void, FetchDataError>) -> Void) {
           let urlString = "\(serverURL)addSubscription"
           let parameters: [String: Any] = [
               "user_id": userId,
               "original_transaction_id": originalTransactionId,
               "product_identifier": productIdentifier,
               "appToken": Defaults[.appToken]
           ]

           AF.request(urlString, method: .post, parameters: parameters, encoding: JSONEncoding.default)
               .validate()
               .responseJSON { response in
                   switch response.result {
                   case .success:
                       completion(.success(()))
                   case .failure(let error):
                       completion(.failure(.networkError(error)))
                   }
               }
       }

    func fetchUserMinerals(email: String, completion: @escaping (Result<[UserMineral], FetchDataError>) -> Void) {
        let parameters: [String: Any] = ["email": email, "appToken": Defaults[.appToken]]
        guard let request = createPostRequest(urlString: "\(serverURL)get-user-minerals", parameters: parameters) else {
            completion(.failure(.invalidResponse))
            return
        }
        performRequest(request: request) { (result: Result<UserMineralsResponse, FetchDataError>) in
            switch result {
            case .success(let response):
                completion(.success(response.userMinerals))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }




    private func createPostRequest(urlString: String, parameters: [String: Any]) -> URLRequest? {
        guard let url = URL(string: urlString) else { return nil }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: parameters)
        return request
    }

    func fetchData(email: String, authToken: String, sphereId: String, completion: @escaping (Result<ResponseData, FetchDataError>) -> Void) {
        let parameters: [String: Any] = ["email": email, "authToken": authToken, "sphereId": sphereId, "appToken": Defaults[.appToken]]
        guard let request = createPostRequest(urlString: "\(serverURL)get-prompts-and-models", parameters: parameters) else {
            completion(.failure(.invalidResponse))
            return
        }
        performRequest(request: request, completion: completion)
    }

    func fetchNeighbors(email: String, authToken: String, completion: @escaping (Result<[Neighbor], FetchDataError>) -> Void) {
        let parameters: [String: Any] = ["email": email, "authToken": authToken, "appToken": Defaults[.appToken]]
        guard let request = createPostRequest(urlString: "\(serverURL)get-neighbor-spheres", parameters: parameters) else {
            completion(.failure(.invalidResponse))
            return
        }
        performRequest(request: request) { (result: Result<NeighborsResponse, FetchDataError>) in
            switch result {
            case .success(let response):
                completion(.success(response.results))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    func checkDailyTreasureAvailability(planet: String, completion: @escaping (Result<String, Error>) -> Void) {
        let parameters: [String: Any] = ["email": Defaults[.email], "authToken": Defaults[.authToken], "appToken": Defaults[.appToken], "planet": planet]
        guard let request = createPostRequest(urlString: "\(serverURL)check-daily-treasure", parameters: parameters) else {
            completion(.failure(NSError(domain: "com.openspace.error", code: -1, userInfo: nil)))
            return
        }
        performSimpleRequest(request: request, completion: completion)
    }

    func claimDailyTreasure(planet: String, completion: @escaping (Result<(String, String, Int), Error>) -> Void) {
           let parameters: [String: Any] = ["email": Defaults[.email], "authToken": Defaults[.authToken], "planet": planet, "appToken": Defaults[.appToken]]
           AF.request("\(serverURL)claim-daily-treasure", method: .post, parameters: parameters, encoding: JSONEncoding.default)
               .validate()
               .responseJSON { response in
                   switch response.result {
                   case .success(let value):
                       if let json = value as? [String: Any],
                          let status = json["status"] as? String {
                           if status == "claimed",
                              let mineral = json["mineral"] as? String,
                              let amount = json["amount"] as? Int {
                               completion(.success((status, mineral, amount)))
                           } else if status == "over_limit" {
                               completion(.success((status, "", 0)))
                           } else {
                               completion(.failure(NSError(domain: "com.openspace.error", code: -1, userInfo: [NSLocalizedDescriptionKey: json["error"] as? String ?? "Unknown error"])))
                           }
                       } else {
                           completion(.failure(NSError(domain: "com.openspace.error", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid response format"])))
                       }
                   case .failure(let error):
                       completion(.failure(error))
                   }
               }
       }


    func loginWithEmail(email: String, authToken: String, completion: @escaping (Result<String, Error>) -> Void) {
          let url = "\(serverURL)login"
          let parameters: [String: Any] = ["email": email, "authToken": authToken]
          //this request gets the app token, dont include apptoken on this request

          AF.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default).responseJSON { response in
              switch response.result {
              case .success(let value):
                  if let jsonResponse = value as? [String: Any],
                     let lastLocation = jsonResponse["last_location"] as? String,
                     let appToken = jsonResponse["appToken"] as? String {
                      // Store the appToken in UserDefaults or any secure storage
                      //UserDefaults.standard.set(appToken, forKey: "appToken")
                      Defaults[.appToken] = appToken
                      completion(.success(lastLocation))
                  } else if let jsonResponse = value as? [String: Any],
                            let errorMessage = jsonResponse["error"] as? String {
                      completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: errorMessage])))
                  } else {
                      completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid response received"])))
                  }
              case .failure(let error):
                  completion(.failure(error))
              }
          }
      }

    func saveLocation(email: String, authToken: String, location: String, usesEnergy: String, completion: @escaping (Result<String, Error>) -> Void) {
        let parameters: [String: Any] = ["email": email, "authToken": authToken, "location": location, "usesEnergy": usesEnergy, "appToken": Defaults[.appToken]]
        guard let request = createPostRequest(urlString: "\(serverURL)save-location", parameters: parameters) else {
            completion(.failure(NSError(domain: "com.openspace.error", code: -1, userInfo: nil)))
            return
        }
        performSimpleRequest(request: request, completion: completion)
    }

    func deleteUser(email: String, authToken: String, completion: @escaping (Result<String, Error>) -> Void) {
        let parameters: [String: Any] = ["email": email, "authToken": authToken, "appToken": Defaults[.appToken]]
        guard let request = createPostRequest(urlString: "\(serverURL)delete-user", parameters: parameters) else {
            completion(.failure(NSError(domain: "com.openspace.error", code: -1, userInfo: nil)))
            return
        }
        performSimpleRequest(request: request, completion: completion)
    }

    func sendTextToServer(email: String, authToken: String, text: String, sphereId: String, completion: @escaping (Result<Bool, Error>) -> Void) {
        let parameters: [String: Any] = ["email": email, "authToken": authToken, "text": text, "sphereId": sphereId, "appToken": Defaults[.appToken]]
        guard let request = createPostRequest(urlString: "\(serverURL)send-text", parameters: parameters) else {
            completion(.failure(NSError(domain: "com.openspace.error", code: -1, userInfo: nil)))
            return
        }

        // Logging the request parameters
        print("Request parameters: \(parameters)")

        performSimpleRequest(request: request) { (result: Result<[String: Any], Error>) in
            switch result {
            case .success(let response):
                print("Server response: \(response)")
                if let message = response["message"] as? String, message == "Inserted text prompt successfully." {
                    completion(.success(true))
                } else {
                    let errorMessage = response["error"] as? String ?? "Unknown error"
                    completion(.failure(NSError(domain: "com.openspace.error", code: -1, userInfo: [NSLocalizedDescriptionKey: errorMessage])))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }


    func submitToServer(username: String, email: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let parameters: [String: Any] = ["username": username, "email": email, "authToken": Defaults[.authToken], "appToken": Defaults[.appToken]]

        let urlString = "\(serverURL)save-username"

        AF.request(urlString, method: .post, parameters: parameters, encoding: JSONEncoding.default)
            .validate()
            .response { response in
                switch response.result {
                case .success:
                    completion(.success(()))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
    }
    
    func resetUsername(email: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let parameters: [String: Any] = ["email": email, "authToken": Defaults[.authToken], "appToken": Defaults[.appToken]]

        let urlString = "\(serverURL)reset-username"

        AF.request(urlString, method: .post, parameters: parameters, encoding: JSONEncoding.default)
            .validate()
            .response { response in
                switch response.result {
                case .success:
                    completion(.success(()))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
    }

    func deleteItemFromSphere(email: String, meshId: Int, completion: @escaping (Result<Void, Error>) -> Void) {
        let parameters: [String: Any] = ["email": email, "authToken": Defaults[.authToken], "mesh_id": meshId, "appToken": Defaults[.appToken]]
        let urlString = "\(serverURL)delete-item-from-sphere"

        AF.request(urlString, method: .post, parameters: parameters, encoding: JSONEncoding.default)
            .validate()
            .response { response in
                switch response.result {
                case .success:
                    completion(.success(()))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
    }

    

    func createSphere(email: String, authToken: String, sphereName: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let parameters: [String: Any] = ["email": email, "authToken": authToken, "sphereName": sphereName, "appToken": Defaults[.appToken]]

        AF.request("\(serverURL)create-sphere", method: .post, parameters: parameters, encoding: JSONEncoding.default)
            .validate(statusCode: 200..<300)
            .responseJSON { response in
                switch response.result {
                case .success:
                    completion(.success(()))
                case .failure:
                    if let data = response.data,
                       let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                       let message = json["message"] as? String {
                        let error = NSError(domain: "", code: 400, userInfo: [NSLocalizedDescriptionKey: message])
                        completion(.failure(error))
                    } else {
                        completion(.failure(response.error!))
                    }
                }
            }
    }

    func createSpaceStation(email: String, authToken: String, configJson: String, spaceStationName: String, spaceStationLocation: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let parameters: [String: Any] = [
            "email": email,
            "authToken": authToken,
            "configJson": configJson,
            "spaceStationName": spaceStationName,
            "spaceStationLocation": spaceStationLocation,
            "appToken": Defaults[.appToken]
        ]

        let url = "\(serverURL)create-space-station"

        AF.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default)
            .validate(statusCode: 200..<300)
            .responseJSON { response in
                switch response.result {
                case .success:
                    completion(.success(()))
                case .failure(let error):
                    if let data = response.data, let errorMessage = String(data: data, encoding: .utf8), errorMessage.contains("Duplicate entry") {
                        completion(.failure(DuplicateEntryError()))
                    } else {
                        completion(.failure(error))
                    }
                }
            }
    }

    struct DuplicateEntryError: Error {}
    
    func submitScore() {
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            appDelegate.submitScore()
        }
    }

    func getLocation(email: String, authToken: String, completion: @escaping (Result<LocationData, Error>) -> Void) {
        if Defaults[.appToken] == "" {
            print("App Token Null")
            // TODO: go to sign in to get appToken
            return
        }

        let parameters: [String: Any] = ["email": email, "authToken": authToken, "appToken": Defaults[.appToken]]
        let url = "\(serverURL)get-data"

        print("Requesting location with parameters: \(parameters)")

        AF.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default).validate().responseJSON { response in
            print("Received response: \(response)")

            switch response.result {
            case .success(let value):
                guard let json = value as? [String: Any] else {
                    print("Invalid JSON format")
                    completion(.failure(NSError(domain: "com.openspace.error", code: -1, userInfo: nil)))
                    return
                }

                print("Parsed JSON: \(json)")

                if let location = json["last_location"] as? String,
                   let currency = json["currency"] as? Int,
                   let currentEnergy = json["current_energy"] as? Int,
                   let totalEnergy = json["total_energy"] as? Int,
                   let regolithCargoAmount = json["regolith_cargo_amount"] as? Int,
                   let waterIceCargoAmount = json["water_ice_cargo_amount"] as? Int,
                   let helium3CargoAmount = json["helium3_cargo_amount"] as? Int,
                   let silicateCargoAmount = json["silicate_cargo_amount"] as? Int,
                   let jarositeCargoAmount = json["jarosite_cargo_amount"] as? Int,
                   let hematiteCargoAmount = json["hematite_cargo_amount"] as? Int,
                   let goethiteCargoAmount = json["goethite_cargo_amount"] as? Int,
                   let opalCargoAmount = json["opal_cargo_amount"] as? Int,
                   let earningFromSpheresDaily = json["earning_from_spheres_daily"] as? Int,
                   let numberOfSpheres = json["number_of_spheres"] as? Int ,
                   let earningFromObjectsDaily = json["earning_from_objects_daily"] as? Int ,
                   let theNumberOfObjects = json["number_of_objects"] as? Int {

                    Defaults[.currency] = currency
                    self.submitScore()

                    Defaults[.regolithCargoAmount] = regolithCargoAmount
                    Defaults[.waterIceCargoAmount] = waterIceCargoAmount
                    Defaults[.helium3CargoAmount] = helium3CargoAmount
                    Defaults[.silicateCargoAmount] = silicateCargoAmount
                    Defaults[.jarositeCargoAmount] = jarositeCargoAmount
                    Defaults[.hematiteCargoAmount] = hematiteCargoAmount
                    Defaults[.goethiteCargoAmount] = goethiteCargoAmount
                    Defaults[.opalCargoAmount] = opalCargoAmount
                    Defaults[.earningFromSpheresDaily] = earningFromSpheresDaily
                    Defaults[.numberOfSpheres] = numberOfSpheres
                    Defaults[.earningFromObjectsDaily] = earningFromObjectsDaily
                    Defaults[.theNumberOfObjects] = theNumberOfObjects


                    let locationData = LocationData(
                        location: location,
                        username: json["username"] as? String,
                        yourSpheres: json["your_spheres"] as? [[String: Any]],
                        neighborSpheres: json["neighbor_spheres"] as? [[String: Any]],
                        spaceStation: json["your_space_station"] as? [String: Any],
                        currency: currency,
                        currentEnergy: currentEnergy,
                        totalEnergy: totalEnergy,
                        passengerLimit: json["passenger_limit"] as? Int,
                        cargoLimit: json["cargo_limit"] as? Int,
                        userId: json["user_id"] as? Int,
                        premium: json["premium"] as? Int,
                        spheresAllowed: json["spheres_allowed"] as? Int,
                        regolithCargoAmount: regolithCargoAmount,
                        waterIceCargoAmount: waterIceCargoAmount,
                        helium3CargoAmount: helium3CargoAmount,
                        silicateCargoAmount: silicateCargoAmount,
                        jarositeCargoAmount: jarositeCargoAmount,
                        hematiteCargoAmount: hematiteCargoAmount,
                        goethiteCargoAmount: goethiteCargoAmount,
                        opalCargoAmount: opalCargoAmount,
                        earningFromSpheresDaily: earningFromSpheresDaily,
                        numberOfSpheres: numberOfSpheres,
                        earningFromObjectsDaily: earningFromObjectsDaily,
                        theNumberOfObjects: theNumberOfObjects
                    )

                    print("Successfully parsed location data")
                    completion(.success(locationData))

                } else if let errorString = json["error"] as? String, errorString == "Invalid authToken." {
                    print("Invalid authToken, refreshing token")
                    self.refreshAuthToken { newToken, tokenError in
                        if let newToken = newToken {
                            Defaults[.authToken] = newToken
                            self.getLocation(email: email, authToken: newToken, completion: completion)
                        } else {
                            print("Failed to refresh authToken")
                            completion(.failure(tokenError ?? NSError(domain: "com.openspace.error", code: -1, userInfo: nil)))
                        }
                    }
                } else {
                    print("Required fields missing in JSON response")
                    completion(.failure(NSError(domain: "com.openspace.error", code: -1, userInfo: nil)))
                }
            case .failure(let error):
                print("Request failed with error: \(error)")
                completion(.failure(error))
            }
        }
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

            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(NSError(domain: "com.openspace.error", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid response type"])))
                return
            }

            if httpResponse.statusCode != 200 {
                let errorMessage = "HTTP status code: \(httpResponse.statusCode)"
                completion(.failure(NSError(domain: "com.openspace.error", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: errorMessage])))
                return
            }

            guard let data = data else {
                completion(.failure(NSError(domain: "com.openspace.error", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                return
            }

            do {
                if T.self == [String: Any].self {
                    let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                    completion(.success(json as! T))
                } else if T.self == String.self {
                    let responseString = String(data: data, encoding: .utf8)
                    completion(.success(responseString as! T))
                } else if T.self == (String, String, Int).self {
                    let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                    if let status = json?["status"] as? String,
                       let mineral = json?["mineral"] as? String,
                       let amount = json?["amount"] as? Int {
                        completion(.success((status, mineral, amount) as! T))
                    } else {
                        completion(.failure(NSError(domain: "com.openspace.error", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to parse response"])))
                    }
                } else {
                    completion(.failure(NSError(domain: "com.openspace.error", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unsupported response type"])))
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
