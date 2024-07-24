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

    override func viewDidAppear(_ animated: Bool) {
          super.viewDidAppear(animated)

          if let user = Auth.auth().currentUser {
              if let email = user.email {
                  print("Logged-in user email: \(email)")
                  dismiss(animated: false)
              }
          } else {
              let authUI = FUIAuth.defaultAuthUI()
              authUI!.delegate = self
              let googleAuthProvider = FUIGoogleAuth(authUI: authUI!)
              let providers: [FUIAuthProvider] = [
                  googleAuthProvider,
                  FUIOAuth.appleAuthProvider()
              ]

              authUI!.providers = providers

              let authViewController = authUI!.authViewController()
              authViewController.modalPresentationStyle = .fullScreen
              authViewController.modalTransitionStyle = .crossDissolve

              let frame = self.view.frame
              let authController = authUI!.authViewController()
              authController.view.frame = frame
              authController.preferredContentSize = frame.size
              authController.modalPresentationStyle = .fullScreen

              // Customizing authController view
              customizeAuthControllerView(authController.view)

              present(authController, animated: true, completion: nil)
          }
      }



    func authUI(_ authUI: FUIAuth, didSignInWith user: User?, error: Error?) {
        if let error = error {
            print("Sign-in error: \(error.localizedDescription)")
            return
        }

        if let currentUser = user {
            currentUser.getIDTokenForcingRefresh(true) { (idToken, error) in
                if let idToken = idToken {
                    print("ID token: \(idToken)")

                    let email = currentUser.email
                    let uid = currentUser.uid
                    print("Email: ")
                    print(email!)
                    print("uid: ")
                    print(uid)
                    print("IdToken: ")
                    print(idToken)
                    Defaults[.email] = email!
                    Defaults[.authToken] = idToken

                    OpenspaceAPI.shared.loginWithEmail(email: email!, authToken: idToken) { result in
                        switch result {
                        case .success(let lastLocation):
                            print("Last Location: \(lastLocation)")
                            Defaults[.email] = email!
                            Defaults[.authToken] = idToken

                            print("Successfully signed in with user: \(user!)")

                            DispatchQueue.main.async {
                                self.performSegue(withIdentifier: "goToSignedIn", sender: self)
                            }
                        case .failure(let error):
                            print("Error: \(error.localizedDescription)")
                        }
                    }
                } else if let error = error {
                    print("Error occurred: \(error.localizedDescription)")
                } else {
                    print("Both idToken and error are nil.")
                }
            }
        } else {
            print("Successfully signed in with a user, but user data is nil.")
        }
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

        // Load a random image initially
        loadRandomImage()

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
        imageTimer = Timer.scheduledTimer(timeInterval: 10.0, target: self, selector: #selector(loadRandomImage), userInfo: nil, repeats: true)
    }

    @objc private func loadRandomImage() {
        let randomIndex = Int.random(in: 1...10)
        let imageName = "login\(randomIndex)"
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
