import Foundation
import SwiftUI
import UIKit
import Defaults

class Utils {
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
    // Save location of user
    
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
               // print("Success: \(response.message)")
                //print("Current Energy: \(response.currentEnergy)")
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
