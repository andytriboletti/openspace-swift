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
        present(authController, animated: true, completion: nil)
    }

    func authPickerViewController(forAuthUI authUI: FUIAuth) -> FUIAuthPickerViewController {
        let picker = OpenSpaceAuthPickerViewController(nibName: "FUIAuthPickerViewController",
                                                       bundle: FUIAuthUtils.authUIBundle(),
                                                       authUI: authUI)
        picker.brandingImage = UIImage(named: "login\(Int.random(in: 1...10)).jpg")
        return picker
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

/// FirebaseUI's sign-in picker, minus the scrolling, with the Open Space title and picture.
///
/// Its buttons sit in a scroll view sized so the screen could always be dragged up and down a
/// little, even though they fit. Scrolling only stays on when they really don't fit (for example
/// with very large text).
///
/// The title and picture are laid out in the space above the sign-in buttons, and the picture
/// shrinks to fit. It used to be a fixed 300-point square centered on the screen, which covered
/// Sign in with Google in a short Mac window.
final class OpenSpaceAuthPickerViewController: FUIAuthPickerViewController {
    /// Set to show the "Open Space" title and this picture. The Save Your Account picker leaves it nil.
    /// (FirebaseUI loads the view inside its initializer, so viewDidLoad has already run by the
    /// time this can be set; the views are added here instead.)
    var brandingImage: UIImage? {
        didSet {
            guard let image = brandingImage else { return }
            titleLabel.text = "Open Space"
            titleLabel.font = UIFont.boldSystemFont(ofSize: 24)
            titleLabel.textColor = .label
            imageView.image = image
            imageView.contentMode = .scaleAspectFit
            view.addSubview(imageView)
            view.addSubview(titleLabel)
            view.setNeedsLayout()
        }
    }

    private let titleLabel = UILabel()
    private let imageView = UIImageView()

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // The terms text is a UITextView, which is also a scroll view; skip it.
        if let scrollView = view.subviews.first(where: { $0 is UIScrollView && !($0 is UITextView) }) as? UIScrollView {
            let visibleHeight = scrollView.bounds.height - scrollView.safeAreaInsets.top
            scrollView.isScrollEnabled = scrollView.contentSize.height > visibleHeight + 1
            scrollView.alwaysBounceVertical = false
        }
        layoutBranding()
    }

    private func layoutBranding() {
        guard brandingImage != nil else { return }
        let bounds = view.bounds
        titleLabel.sizeToFit()
        let titleTop = max(100, view.safeAreaInsets.top + 16)
        titleLabel.frame.origin = CGPoint(x: (bounds.width - titleLabel.bounds.width) / 2, y: titleTop)

        // The picture fills the gap between the title and the first sign-in button, up to 300 points.
        let buttonsTop = signInButtons(in: view).map { $0.convert($0.bounds, to: view).minY }.min() ?? bounds.maxY
        let top = titleLabel.frame.maxY + 24
        let bottom = buttonsTop - 24
        let side = min(300, bottom - top, bounds.width - 40)
        imageView.isHidden = side < 80
        imageView.frame = CGRect(x: (bounds.width - side) / 2,
                                 y: top + (bottom - top - side) / 2,
                                 width: max(side, 0), height: max(side, 0))
    }

    /// FirebaseUI's provider buttons (FUIAuthSignInButton isn't public, so match it by name).
    private func signInButtons(in root: UIView) -> [UIView] {
        root.subviews.flatMap { sub -> [UIView] in
            (NSStringFromClass(type(of: sub)).contains("FUIAuthSignInButton") ? [sub] : []) + signInButtons(in: sub)
        }
    }
}
