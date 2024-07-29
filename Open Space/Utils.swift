import Foundation
import SwiftUI
import UIKit
import Defaults
struct LocationData {
    let location: String
    let username: String?
    let yourSpheres: [[String: Any]]?
    let neighborSpheres: [[String: Any]]?
    let spaceStation: [String: Any]?
    let currency: Int
    let currentEnergy: Int
    let totalEnergy: Int
    let passengerLimit: Int?
    let cargoLimit: Int?
    let userId: Int?
    let premium: Int?
    let spheresAllowed: Int?
    let regolithCargoAmount: Int
    let waterIceCargoAmount: Int
    let helium3CargoAmount: Int
    let silicateCargoAmount: Int
    let jarositeCargoAmount: Int
    let hematiteCargoAmount: Int
    let goethiteCargoAmount: Int
    let opalCargoAmount: Int
    let earningFromSpheresDaily: Int
    let numberOfSpheres: Int
    let earningFromObjectsDaily: Int
    let theNumberOfObjects: Int
}

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
            //print("Email or authToken is missing")
            completion?()
            return
        }
        //print("in Utils.getLocation() with email: \(email) and authToken: \(authToken)")
        OpenspaceAPI.shared.getLocation(email: email, authToken: authToken) { [weak self] (result: Result<LocationData, Error>) in
            //print("API call completed")
            guard let self = self else {
                //print("Self is nil, returning early")
                return
            }
            //print("inside getLocation 123")
            //print(result)
            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    //print("calling handleLocationSuccess with data: \(data)")
                    self.handleLocationSuccess(data: data)
                    completion?()
                case .failure(let error):
                    //print("Error in getLocation: \(error.localizedDescription)")
                    completion?()
                }
            }
        }
    }

    private func handleLocationSuccess(data: LocationData) {
        //print("handleLocationSuccess called with data: \(data)")

        if let username = data.username, !username.isEmpty {
            Defaults[.username] = username
        } else {
            //print("no username?")
        }

        do {
            let yourSpheresData = try JSONSerialization.data(withJSONObject: data.yourSpheres ?? [])
            let neighborSpheresData = try JSONSerialization.data(withJSONObject: data.neighborSpheres ?? [])
            Defaults[.yourSpheres] = yourSpheresData
            Defaults[.neighborSpheres] = neighborSpheresData
        } catch {
            //print("Error converting spheres data: \(error)")
        }

        if let spaceStation = data.spaceStation,
           let meshLocation = spaceStation["mesh_location"] as? String,
           let previewLocation = spaceStation["preview_location"] as? String,
           let stationName = spaceStation["spacestation_name"] as? String,
           let stationId = spaceStation["station_id"] as? String {

            Defaults[.stationMeshLocation] = meshLocation
            Defaults[.stationPreviewLocation] = previewLocation
            Defaults[.stationName] = stationName
            Defaults[.stationId] = stationId
        }

        Defaults[.currency] = data.currency
        Defaults[.currentEnergy] = data.currentEnergy
        Defaults[.totalEnergy] = data.totalEnergy

        if let passengerLimit = data.passengerLimit {
            Defaults[.passengerLimit] = passengerLimit
        }

        if let cargoLimit = data.cargoLimit {
            Defaults[.cargoLimit] = cargoLimit
        }

        if let userId = data.userId {
            Defaults[.userId] = userId
        }

        if let premium = data.premium {
            Defaults[.premium] = premium
        }

        if let spheresAllowed = data.spheresAllowed {
            Defaults[.spheresAllowed] = spheresAllowed
        }

        //print("handleLocationSuccess completed")
    }


    public func saveLocation(location: String, usesEnergy: String) {
        let email = Defaults[.email]
        let authToken = Defaults[.authToken]

        guard !email.isEmpty, !authToken.isEmpty else {
            //print("Error: Email or Auth token is empty")
            return
        }

        OpenspaceAPI.shared.saveLocation(email: email, authToken: authToken, location: location, usesEnergy: usesEnergy) { result in
            switch result {
            case .success(_):
                //print("openspace: success savign location")
                break
            case .failure(let error):
                //print("Error: \(error.localizedDescription)")
                if let nsError = error as NSError? {
                    //print("Error Domain: \(nsError.domain)")
                    //print("Error Code: \(nsError.code)")
                    //print("Error UserInfo: \(nsError.userInfo)")
                }
            }
        }
    }
}


extension UIImage {
    func applyDarkFilter() -> UIImage? {
        guard let ciImage = CIImage(image: self) else { return nil }
        let filter = CIFilter(name: "CIColorControls")!
        filter.setValue(ciImage, forKey: kCIInputImageKey)
        filter.setValue(-0.5, forKey: kCIInputBrightnessKey)
        filter.setValue(1.0, forKey: kCIInputContrastKey)

        let context = CIContext(options: nil)
        guard let outputImage = filter.outputImage else { return nil }
        guard let cgImage = context.createCGImage(outputImage, from: outputImage.extent) else { return nil }

        return UIImage(cgImage: cgImage)
    }

    func applyLightFilter() -> UIImage? {
        guard let ciImage = CIImage(image: self) else { return nil }
        let filter = CIFilter(name: "CIColorControls")!
        filter.setValue(ciImage, forKey: kCIInputImageKey)
        filter.setValue(0.5, forKey: kCIInputBrightnessKey)
        filter.setValue(1.0, forKey: kCIInputContrastKey)

        let context = CIContext(options: nil)
        guard let outputImage = filter.outputImage else { return nil }
        guard let cgImage = context.createCGImage(outputImage, from: outputImage.extent) else { return nil }

        return UIImage(cgImage: cgImage)
    }
}
//
//
//class StyledButton: UIButton {
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        setupStyle()
//    }
//
//    required init?(coder aDecoder: NSCoder) {
//        super.init(coder: aDecoder)
//        setupStyle()
//    }
//
//    private func setupStyle() {
//        backgroundColor = .systemBlue.withAlphaComponent(0.7)
//        setTitleColor(.white, for: .normal)
//        layer.cornerRadius = 10
//        contentEdgeInsets = UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20)
//        titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
//
//        // Add a subtle shadow for depth
//        layer.shadowColor = UIColor.black.cgColor
//        layer.shadowOffset = CGSize(width: 0, height: 2)
//        layer.shadowRadius = 4
//        layer.shadowOpacity = 0.2
//    }
//
//    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
//        super.traitCollectionDidChange(previousTraitCollection)
//        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
//            // Adjust colors for dark mode if needed
//            backgroundColor = .systemBlue.withAlphaComponent(0.7)
//            setTitleColor(.white, for: .normal)
//        }
//    }
//}
