import Foundation
import SwiftUI
import UIKit
import Defaults

class Utils {
    static let shared = Utils()

    private init() {}

    class func colorizeImage(_ image: UIImage?, with color: UIColor?) -> UIImage? {
        // existing method
        UIGraphicsBeginImageContextWithOptions(image?.size ?? CGSize.zero, _: false, _: image?.scale ?? 0.0)

        let context = UIGraphicsGetCurrentContext()
        let area = CGRect(x: 0, y: 0, width: image?.size.width ?? 0.0, height: image?.size.height ?? 0.0)

        context?.scaleBy(x: 1, y: -1)
        context?.translateBy(x: 0, y: -area.size.height)

        context?.saveGState()
        context?.clip(to: area, mask: (image?.cgImage)!)

        color?.set()
        context?.fill(area)

        context?.restoreGState()

        if let context = context {
            context.setBlendMode(.multiply)
        }

        context!.draw((image?.cgImage)!, in: area)

        let colorizedImage = UIGraphicsGetImageFromCurrentImageContext()

        UIGraphicsEndImageContext()

        return colorizedImage
    }

    class func presentUsernameEntry(from viewController: UIViewController, completion: @escaping (String) -> Void) {
        DispatchQueue.main.async {
            let usernameBinding = Binding<String>(
                get: { Defaults[.username] },
                set: { Defaults[.username] = $0 }
            )

            let usernameEntryView = UsernameEntryView(completion: completion, username: usernameBinding)
            let hostingController = UIHostingController(rootView: usernameEntryView)

            viewController.present(hostingController, animated: true, completion: nil)
        }
    }
    public func getLocation(completion: (() -> Void)? = nil) {
        guard let email = Defaults[.email] as String?, let authToken = Defaults[.authToken] as String? else {
            print("Email or authToken is missing")
            completion?()
            return
        }
        print("in Utils.getLocation() with email: \(email) and authToken: \(authToken)")
        OpenspaceAPI.shared.getLocation(email: email, authToken: authToken) { [weak self] (result: Result<(location: String, username: String?, yourSpheres: [[String: Any]]?, neighborSpheres: [[String: Any]]?, spaceStation: [String: Any]?, currency: Int, currentEnergy: Int, totalEnergy: Int, passengerLimit: Int?, cargoLimit: Int?, userId: Int?, premium: Int?, spheresAllowed: Int?), Error>) in
            print("API call completed")
            guard let self = self else {
                print("Self is nil, returning early")
                return
            }
            print("inside getLocation 123")

            print(result)
            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    print("calling handleLocationSuccess with data: \(data)")
                    self.handleLocationSuccess(data: data)
                    completion?()
                case .failure(let error):
                    print("Error in getLocation: \(error.localizedDescription)")
                    completion?()
                }
            }
        }
    }

    private func handleLocationSuccess(data: (location: String, username: String?, yourSpheres: [[String: Any]]?, neighborSpheres: [[String: Any]]?, spaceStation: [String: Any]?, currency: Int, currentEnergy: Int, totalEnergy: Int, passengerLimit: Int?, cargoLimit: Int?, userId: Int?, premium: Int?, spheresAllowed: Int?)) {
        print("handleLocationSuccess called with data: \(data)")
        let (location, username, yourSpheres, neighborSpheres, spaceStation, currency, currentEnergy, totalEnergy, passengerLimit, cargoLimit, userId, premium, spheresAllowed) = data

        if let username = username, !username.isEmpty {
            Defaults[.username] = username
        } else {
            print("no username?")
        }

        do {
            let yourSpheresData = try JSONSerialization.data(withJSONObject: yourSpheres ?? [])
            let neighborSpheresData = try JSONSerialization.data(withJSONObject: neighborSpheres ?? [])
            Defaults[.yourSpheres] = yourSpheresData
            Defaults[.neighborSpheres] = neighborSpheresData
        } catch {
            print("Error converting spheres data: \(error)")
        }

        if let spaceStation = spaceStation,
           let meshLocation = spaceStation["mesh_location"] as? String,
           let previewLocation = spaceStation["preview_location"] as? String,
           let stationName = spaceStation["spacestation_name"] as? String,
           let stationId = spaceStation["station_id"] as? String {

            Defaults[.stationMeshLocation] = meshLocation
            Defaults[.stationPreviewLocation] = previewLocation
            Defaults[.stationName] = stationName
            Defaults[.stationId] = stationId
        }

        Defaults[.currency] = currency
        Defaults[.currentEnergy] = currentEnergy
        Defaults[.totalEnergy] = totalEnergy

        if let passengerLimit = passengerLimit {
            Defaults[.passengerLimit] = passengerLimit
        }

        if let cargoLimit = cargoLimit {
            Defaults[.cargoLimit] = cargoLimit
        }

        if let userId = userId {
            Defaults[.userId] = userId
        }

        if let premium = premium {
            Defaults[.premium] = premium
        }
        if let spheresAllowed = spheresAllowed {
            Defaults[.spheresAllowed] = spheresAllowed
        }

        print("handleLocationSuccess completed")
    }

    public func saveLocation(location: String, usesEnergy: String) {
        let email = Defaults[.email]
        let authToken = Defaults[.authToken]

        guard !email.isEmpty, !authToken.isEmpty else {
            print("Error: Email or Auth token is empty")
            return
        }

        OpenspaceAPI.shared.saveLocation(email: email, authToken: authToken, location: location, usesEnergy: usesEnergy) { result in
            switch result {
            case .success(_):
                print("openspace: success savign location")
            case .failure(let error):
                print("Error: \(error.localizedDescription)")
                if let nsError = error as NSError? {
                    print("Error Domain: \(nsError.domain)")
                    print("Error Code: \(nsError.code)")
                    print("Error UserInfo: \(nsError.userInfo)")
                }
            }
        }
    }
}
