import UIKit
import SwiftUI
import Defaults
import OnboardingKit

class OnboardingViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        let contentView = OnboardingView(onFinish: {
            self.finishOnboarding()
        })

        let hostingController = UIHostingController(rootView: contentView)

        addChild(hostingController)
        hostingController.view.frame = view.bounds
        view.addSubview(hostingController.view)
        hostingController.didMove(toParent: self)
    }

    private func finishOnboarding() {
        Defaults[.hasWatchedOnboarding] = 1

        let newValue = UserDefaults.standard.string(forKey: "hasWatchedOnboarding")
        print("New hasWatchedOnboarding value: \(newValue ?? "nil")")

        performSegue(withIdentifier: "goToSignIn", sender: self)
    }
}
