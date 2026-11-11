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
        authUI.providers = [FUIGoogleAuth(authUI: authUI), FUIOAuth.appleAuthProvider()]

        let authController = authUI.authViewController()
        authController.view.frame = self.view.frame
        authController.preferredContentSize = self.view.frame.size
        authController.modalPresentationStyle = .fullScreen

        // Customizing authController view
        customizeAuthControllerView(authController.view)
        present(authController, animated: true, completion: nil)
    }

    func authUI(_ authUI: FUIAuth, didSignInWith user: User?, error: Error?) {
        if error != nil {
            return
        }
        if let user = user {
            completeSignIn(user: user)
        }
    }

    /// "Play as Guest": a Firebase anonymous account. The player can save it later from the
    /// Account tab (Google or Apple), keeping their progress.
    @objc private func playAsGuestTapped(_ sender: UIButton) {
        sender.isEnabled = false
        Auth.auth().signInAnonymously { [weak self] result, error in
            guard let self = self else { return }
            guard let user = result?.user else {
                sender.isEnabled = true
                self.showError("Couldn't start a guest game. Please check your connection and try again.", over: self.presentedViewController ?? self)
                return
            }
            // Close the sign-in picker first, the same way FirebaseUI does for Google/Apple.
            if let picker = self.presentedViewController {
                picker.dismiss(animated: true) { self.completeSignIn(user: user) }
            } else {
                self.completeSignIn(user: user)
            }
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

        // "Play as Guest" under the Google / Apple buttons.
        let guestButton = UIButton(type: .system)
        guestButton.setTitle("Play as Guest", for: .normal)
        guestButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        guestButton.accessibilityIdentifier = "playAsGuest"
        guestButton.translatesAutoresizingMaskIntoConstraints = false
        guestButton.addTarget(self, action: #selector(playAsGuestTapped(_:)), for: .touchUpInside)
        authView.addSubview(guestButton)
        NSLayoutConstraint.activate([
            guestButton.centerXAnchor.constraint(equalTo: authView.centerXAnchor),
            guestButton.bottomAnchor.constraint(equalTo: authView.safeAreaLayoutGuide.bottomAnchor, constant: -24)
        ])

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
