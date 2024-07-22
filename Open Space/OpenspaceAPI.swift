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
        let parameters: [String: Any] = ["email": email, "authToken": authToken, "sphereId": sphereId]
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
            "userId": userId
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
    func addSubscription(userId: Int, originalTransactionId: String, completion: @escaping (Result<Void, FetchDataError>) -> Void) {
           let urlString = "\(serverURL)addSubscription"
           let parameters: [String: Any] = [
               "user_id": userId,
               "original_transaction_id": originalTransactionId
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
        let parameters: [String: Any] = ["email": email]
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
        let parameters: [String: Any] = ["email": Defaults[.email], "authToken": Defaults[.authToken], "planet": planet]
        guard let request = createPostRequest(urlString: "\(serverURL)check-daily-treasure", parameters: parameters) else {
            completion(.failure(NSError(domain: "com.openspace.error", code: -1, userInfo: nil)))
            return
        }
        performSimpleRequest(request: request, completion: completion)
    }

    func claimDailyTreasure(planet: String, completion: @escaping (Result<(String, String, Int), Error>) -> Void) {
           let parameters: [String: Any] = ["email": Defaults[.email], "authToken": Defaults[.authToken], "planet": planet]
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
        let parameters: [String: Any] = ["email": email, "authToken": authToken]
        guard let request = createPostRequest(urlString: "\(serverURL)login", parameters: parameters) else {
            completion(.failure(NSError(domain: "com.openspace.error", code: -1, userInfo: nil)))
            return
        }
        performSimpleRequest(request: request, completion: completion)
    }

    func saveLocation(email: String, authToken: String, location: String, usesEnergy: String, completion: @escaping (Result<String, Error>) -> Void) {
        let parameters: [String: Any] = ["email": email, "authToken": authToken, "location": location, "usesEnergy": usesEnergy]
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
        let parameters: [String: Any] = ["username": username, "email": email, "authToken": Defaults[.authToken]]

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
        let parameters: [String: Any] = ["email": email, "authToken": Defaults[.authToken]]

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
        let parameters: [String: Any] = ["email": email, "authToken": Defaults[.authToken], "mesh_id": meshId]
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
        let parameters: [String: Any] = ["email": email, "authToken": authToken, "sphereName": sphereName]

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
            "spaceStationLocation": spaceStationLocation
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




    func getLocation(email: String, authToken: String, completion: @escaping (Result<(location: String, username: String?, yourSpheres: [[String: Any]]?, neighborSpheres: [[String: Any]]?, spaceStation: [String: Any]?, currency: Int, currentEnergy: Int, totalEnergy: Int, passengerLimit: Int?, cargoLimit: Int?, userId: Int?, premium: Int?, spheresAllowed: Int?), Error>) -> Void) {
            let parameters: [String: Any] = ["email": email, "authToken": authToken]
            let url = "\(serverURL)get-data"

            AF.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default).validate().responseJSON { response in
                switch response.result {
                case .success(let value):
                    guard let json = value as? [String: Any] else {
                        completion(.failure(NSError(domain: "com.openspace.error", code: -1, userInfo: nil)))
                        return
                    }

                    if let location = json["last_location"] as? String,
                       let currency = json["currency"] as? Int,
                       let currentEnergy = json["current_energy"] as? Int,
                       let totalEnergy = json["total_energy"] as? Int {
                        let username = json["username"] as? String
                        let yourSpheres = json["your_spheres"] as? [[String: Any]]
                        let neighborSpheres = json["neighbor_spheres"] as? [[String: Any]]
                        let spaceStation = json["your_space_station"] as? [String: Any]
                        let passengerLimit = json["passenger_limit"] as? Int
                        let cargoLimit = json["cargo_limit"] as? Int
                        let userId = json["user_id"] as? Int
                        let premium = json["premium"] as? Int
                        let spheresAllowed = json["spheres_allowed"] as? Int
                        completion(.success((location, username, yourSpheres, neighborSpheres, spaceStation, currency, currentEnergy, totalEnergy, passengerLimit, cargoLimit, userId, premium, spheresAllowed)))
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
                case .failure(let error):
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
