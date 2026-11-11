import UIKit
import FirebaseAuthUI
import FirebaseCore
import FirebaseOAuthUI
import Defaults
import GoogleSignIn
import FirebaseGoogleAuthUI

class SignInViewController: UIViewController, FUIAuthDelegate {
    public var authUI: FUIAuth = FUIAuth.defaultAuthUI()!
      var rootViewController: SignInViewController?
      let imageView = UIImageView()
      var imageTimer: Timer?
      var onboardingShown = false // Add this flag

      override func viewDidAppear(_ animated: Bool) {
          super.viewDidAppear(animated)

          if Auth.auth().currentUser != nil {
              // Guests have no email, so don't require one here.
              dismiss(animated: false)
              return
          }

          let hasOnboard = Defaults[.hasWatchedOnboarding]
          if hasOnboard == 1 {
              presentAuthUI()
          } else if !onboardingShown { // Check if onboarding has already been shown
              onboardingShown = true // Set the flag to true
              performSegue(withIdentifier: "goToOnboarding", sender: self)
          }
      }

    private func presentAuthUI() {
        let authUI = FUIAuth.defaultAuthUI()!
        authUI.delegate = self
        authUI.shouldAutoUpgradeAnonymousUsers = false
        authUI.providers = [FUIGoogleAuth(authUI: authUI), FUIOAuth.appleAuthProvider(), GuestAuthProvider()]

        let authController = authUI.authViewController()
        authController.view.frame = self.view.frame
        authController.preferredContentSize = self.view.frame.size
        authController.modalPresentationStyle = .fullScreen

        // Customizing authController view
        customizeAuthControllerView(authController.view)
        present(authController, animated: true, completion: nil)
    }

    func authPickerViewController(forAuthUI authUI: FUIAuth) -> FUIAuthPickerViewController {
        return OpenSpaceAuthPickerViewController(nibName: "FUIAuthPickerViewController",
                                                 bundle: FUIAuthUtils.authUIBundle(),
                                                 authUI: authUI)
    }

    func authUI(_ authUI: FUIAuth, didSignInWith user: User?, error: Error?) {
        if error != nil {
            return
        }
        guard let user = user else { return }
        // For Google/Apple FirebaseUI calls this once the picker has closed; for a guest it
        // calls it while the picker is still closing, so wait for that to finish.
        if let closing = presentedViewController?.transitionCoordinator {
            closing.animate(alongsideTransition: nil) { _ in self.completeSignIn(user: user) }
        } else {
            completeSignIn(user: user)
        }
    }

    /// Exchanges the Firebase sign-in (Google, Apple or guest) for the game server's appToken.
    private func completeSignIn(user: User) {
        user.getIDTokenForcingRefresh(true) { [weak self] idToken, _ in
            guard let self = self else { return }
            guard let idToken = idToken else {
                self.signInFailed("Couldn't sign in. Please try again.")
                return
            }
            let email = user.email ?? ""   // guests have no email
            Defaults[.email] = email
            AppSecrets.authToken = idToken

            OpenspaceAPI.shared.loginWithEmail(email: email, authToken: idToken) { result in
                switch result {
                case .success:
                    DispatchQueue.main.async {
                        self.performSegue(withIdentifier: "goToSignedIn", sender: self)
                    }
                case .failure(let error):
                    self.signInFailed(error.localizedDescription)
                }
            }
        }
    }

    private func signInFailed(_ message: String) {
        DispatchQueue.main.async {
            try? Auth.auth().signOut()
            self.showError(message, over: self.presentedViewController ?? self) { [weak self] in
                if self?.presentedViewController == nil {
                    self?.presentAuthUI()
                }
            }
        }
    }

    private func showError(_ message: String, over controller: UIViewController, then: (() -> Void)? = nil) {
        let alert = UIAlertController(title: "Sign-in problem", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in then?() })
        controller.present(alert, animated: true)
    }

    private func customizeAuthControllerView(_ authView: UIView) {
        // Set up the image view
        imageView.frame = CGRect(x: 0, y: 0, width: 300, height: 300)
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        authView.addSubview(imageView)

        // Center the imageView
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: authView.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: authView.centerYAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 300),
            imageView.heightAnchor.constraint(equalToConstant: 300)
        ])


        // Set up the label
        let titleLabel = UILabel()
        titleLabel.text = "Open Space"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 24)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        // Use dynamic color that adapts to light/dark mode
        titleLabel.textColor = UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark ? .white : .black
        }

        authView.addSubview(titleLabel)

        // Center the label horizontally and place it a bit lower
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: authView.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: authView.topAnchor, constant: 100)
        ])

        // Start the timer to change the image every 10 seconds
        //imageTimer = Timer.scheduledTimer(timeInterval: 10.0, target: self, selector: #selector(loadRandomImage), userInfo: nil, repeats: true)

        // Load a random image initially
        loadRandomImage()
    }

    @objc private func loadRandomImage() {
        let randomIndex = Int.random(in: 1...10)
        let imageName = "login\(randomIndex).jpg"
       // let imageName = "login1.jpg"
        imageView.image = UIImage(named: imageName)
    }
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            updateLabelColor()
        }
    }

    private func updateLabelColor() {
        if let titleLabel = view.subviews.first(where: { $0 is UILabel }) as? UILabel {
            titleLabel.textColor = traitCollection.userInterfaceStyle == .dark ? .white : .black
        }
    }
}

/// "Play as Guest" as a FirebaseUI sign-in provider, so it is drawn as a real button in the same
/// column, size and style as Sign in with Google / Apple. It creates a Firebase anonymous account;
/// the player can save it later from the Account tab (Google or Apple) and keep their progress.
final class GuestAuthProvider: NSObject, FUIAuthProvider {
    var providerID: String? { nil }
    var shortName: String { "Guest" }
    var signInLabel: String { "Play as Guest" }
    var buttonBackgroundColor: UIColor { UIColor(red: 0.29, green: 0.31, blue: 0.35, alpha: 1) }
    var buttonTextColor: UIColor { .white }
    var buttonAlignment: FUIButtonAlignment = .center
    var accessToken: String? { nil }

    /// A person symbol on the same 24 x 24 canvas as FirebaseUI's Google and Apple icons.
    var icon: UIImage {
        let canvas = CGSize(width: 24, height: 24)
        let config = UIImage.SymbolConfiguration(pointSize: 15, weight: .semibold)
        guard let symbol = UIImage(systemName: "person.fill", withConfiguration: config)?
            .withTintColor(.white, renderingMode: .alwaysOriginal) else { return UIImage() }
        return UIGraphicsImageRenderer(size: canvas).image { _ in
            symbol.draw(in: CGRect(x: (canvas.width - symbol.size.width) / 2,
                                   y: (canvas.height - symbol.size.height) / 2,
                                   width: symbol.size.width,
                                   height: symbol.size.height))
        }
    }

    func signIn(withDefaultValue defaultValue: String?,
                presenting presentingViewController: UIViewController?,
                completion: FUIAuthProviderSignInCompletionBlock? = nil) {
        Auth.auth().signInAnonymously { result, error in
            guard let result = result else {
                // Explain the problem here and report a cancel, so FirebaseUI leaves the
                // picker open for another try.
                let alert = UIAlertController(title: "Sign-in problem",
                                              message: "Couldn't start a guest game. Please check your connection and try again.",
                                              preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                presentingViewController?.present(alert, animated: true)
                completion?(nil, NSError(domain: FUIAuthErrorDomain,
                                         code: Int(FUIAuthErrorCode.userCancelledSignIn.rawValue)), nil, nil)
                return
            }
            // FirebaseUI treats an anonymous user with no credential as a finished guest
            // sign-in: it closes the picker and calls authUI(_:didSignInWith:error:).
            completion?(nil, nil, nil, ["FUIAuthProviderSignInUserInfoKeyAuthDataResult": result])
        }
    }

    func signIn(withEmail email: String?,
                presenting presentingViewController: UIViewController?,
                completion: FUIAuthProviderSignInCompletionBlock? = nil) {
        signIn(withDefaultValue: email, presenting: presentingViewController, completion: completion)
    }

    func signOut() {}
}

/// FirebaseUI's sign-in picker, minus the scrolling. Its buttons sit in a scroll view sized so the
/// screen could always be dragged up and down a little, even though they fit. Scrolling only stays
/// on when they really don't fit (for example with very large text).
final class OpenSpaceAuthPickerViewController: FUIAuthPickerViewController {
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // The terms text is a UITextView, which is also a scroll view; skip it.
        guard let scrollView = view.subviews.first(where: { $0 is UIScrollView && !($0 is UITextView) }) as? UIScrollView else {
            return
        }
        let visibleHeight = scrollView.bounds.height - scrollView.safeAreaInsets.top
        scrollView.isScrollEnabled = scrollView.contentSize.height > visibleHeight + 1
        scrollView.alwaysBounceVertical = false
    }
}
