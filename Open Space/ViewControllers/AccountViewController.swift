import UIKit
import FirebaseAuth
import FirebaseAuthUI
import FirebaseGoogleAuthUI
import FirebaseOAuthUI
import Defaults
#if targetEnvironment(macCatalyst)
// Exclude GoogleMobileAds for Mac Catalyst
#else
import GoogleMobileAds
#endif

class AccountViewController: BackgroundImageViewController {
    var rootViewController: SignInViewController?

    @IBOutlet weak var loggedInAs: UILabel!
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var signOutButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var energyLabel: UILabel!
    @IBOutlet weak var accountTypeLabel: UILabel!
    @IBOutlet weak var upgradeToPremium: UIButton!
    @IBOutlet weak var yourAccountIsEarning: UILabel!
    @IBOutlet weak var yourAccountIsEarningObjects: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var refillEnergy: UIButton!
    @IBOutlet weak var priceLabel: UILabel!

    #if !targetEnvironment(macCatalyst)
    var rewardedAd: GADRewardedAd?
    #endif
    /// When the last rewarded ad finished (its reward reaches the server a few seconds later).
    private var lastRewardAt: Date?
    private var saveAccountButton: UIButton?

//    @IBAction func upgradeToPremium(_ sender: UIButton) {
//            upgrade()
//      }


    /// App Review requires a way to restore the subscription and one-time upgrades.
    /// Added under "Upgrade To Premium" in the same stack view, styled like it.
    private func addRestorePurchasesButton() {
        guard let stack = upgradeToPremium.superview as? UIStackView,
              let index = stack.arrangedSubviews.firstIndex(of: upgradeToPremium) else { return }

        let restore = makeButtonLikeUpgrade(title: "Restore Purchases")
        restore.accessibilityIdentifier = "restorePurchases"
        restore.addTarget(self, action: #selector(restorePurchasesTapped), for: .touchUpInside)
        stack.insertArrangedSubview(restore, at: index + 1)

        // Guests only: link Google or Apple so the game is kept (same Firebase user).
        let save = makeButtonLikeUpgrade(title: "Save Your Account")
        save.accessibilityIdentifier = "saveAccount"
        save.addTarget(self, action: #selector(saveAccountTapped), for: .touchUpInside)
        stack.insertArrangedSubview(save, at: index + 1)
        saveAccountButton = save
        updateGuestUI()
    }

    /// A button styled like "Upgrade To Premium". That button uses a UIButton.Configuration
    /// (filled style), so its look lives in the configuration, not in backgroundColor.
    private func makeButtonLikeUpgrade(title: String) -> UIButton {
        let button = UIButton(type: .system)
        if var configuration = upgradeToPremium.configuration {
            configuration.title = title
            button.configuration = configuration
        } else {
            var configuration = UIButton.Configuration.filled()
            configuration.title = title
            configuration.cornerStyle = .large
            button.configuration = configuration
        }
        return button
    }

    private var isGuest: Bool {
        return Auth.auth().currentUser?.isAnonymous ?? false
    }

    private func updateGuestUI() {
        saveAccountButton?.isHidden = !isGuest
    }

    @objc private func saveAccountTapped() {
        AccountSaver.shared.save(from: self) { [weak self] _ in
            self?.refreshLabels()
            self?.updateGuestUI()
        }
    }

    @objc private func restorePurchasesTapped() {
        IAPManager.shared.restorePurchases()
    }

    @IBAction func viewTerms(_ sender: UIButton) {
        if let url = URL(string: "https://greenrobot.com/terms") {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    @IBAction func viewPrivacy(_ sender: UIButton) {
        if let url = URL(string: "https://greenrobot.com/privacy") {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }

    @objc func upgrade() {
        //return
        //todo in-app purchase disabled for testflight. todo re-enable when released
        if(MyData.allowInAppPurchases == 1) {

            //print("upgrade to premium")
            if let price = IAPManager.shared.getPrice(for: ProductIdentifiers.premiumSubscription) {
                showPremiumPurchaseAlert(price: price)
            } else {
                showPremiumPurchaseAlert(price: "$4.99")
                //print("Product price not available")
            }
        }
        else {
            displayComingSoonAlert()
        }
    }
    func showPremiumPurchaseAlert(price: String) {
        // Create the alert controller with the price
        let msgText = "Do you want to purchase an upgrade to Premium without ads for \(price)?"
        let alertController = UIAlertController(title: "Confirm Purchase: Upgrade To Premium Subscription", message: msgText, preferredStyle: .alert)

        // Create OK action
        let okAction = UIAlertAction(title: "OK", style: .default) { _ in
            // Call your method to initiate the purchase here
            self.purchaseUpgradePremium()
            //print("purchase upgrade premium")
        }
        alertController.addAction(okAction)

        // Create Cancel action
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)

        // Present the alert controller
        present(alertController, animated: true, completion: nil)
    }

    func showEnergyRefillPurchaseAlert(price: String) {
        // Create the alert controller with the price
        let msgText = "Do you want to purchase an energy refill for \(price)?"
        let alertController = UIAlertController(title: "Confirm Purchase: Energy Refill", message: msgText, preferredStyle: .alert)

        // Create OK action
        let okAction = UIAlertAction(title: "OK", style: .default) { _ in
            // Call your method to initiate the purchase here
            self.purchaseEnergyRefill()
            //print("purchase refill energy")
        }
        alertController.addAction(okAction)

        // Create Cancel action
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)

        // Present the alert controller
        present(alertController, animated: true, completion: nil)
    }
    func showPurchaseAlert(price: String) {
        // Create the alert controller with the price
        let msgText = "Do you want to purchase an upgrade to max energy +1 for \(price)?"
        let alertController = UIAlertController(title: "Confirm Purchase: Upgrade Max Energy", message: msgText, preferredStyle: .alert)

        // Create OK action
        let okAction = UIAlertAction(title: "OK", style: .default) { _ in
            // Call your method to initiate the purchase here
            self.purchaseUpgradeMaxEnergy()
            //print("purchase upgrade max energy")
        }
        alertController.addAction(okAction)

        // Create Cancel action
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)

        // Present the alert controller
        present(alertController, animated: true, completion: nil)
    }

    func purchaseUpgradeMaxEnergy() {
        if IAPManager.shared.products.first != nil {
            IAPManager.shared.purchaseProduct(with: ProductIdentifiers.upgradeMaxEnergy)
        } else {
            //print("Product purchaseUpgradeMaxEnergy not available")
        }
    }

    func purchaseUpgradePremium() {
        if IAPManager.shared.products.first != nil {
            IAPManager.shared.purchaseProduct(with: ProductIdentifiers.premiumSubscription)
        } else {
            //print("Product purchaseUpgradePremium not available")
        }
    }
    func purchaseEnergyRefill() {
        if IAPManager.shared.products.first != nil {
            IAPManager.shared.purchaseProduct(with: ProductIdentifiers.refillEnergy)
        } else {
            //print("Product purchaseEnergyRefill not available")
        }
    }


    @IBAction func upgradeMaxEnergyButtonTapped(_ sender: UIButton) {
        //return
        //todo in-app purchase disabled for testflight. todo re-enable when released
        if(MyData.allowInAppPurchases == 1) {

            //print("purchaseUpgradeMaxEnergy")
            if let price = IAPManager.shared.getPrice(for: ProductIdentifiers.upgradeMaxEnergy) {
                showPurchaseAlert(price: price)
            } else {
                showPurchaseAlert(price: "$0.99")
                //print("Product price not available")
            }
        }
        else {
            displayComingSoonAlert()
        }
    }



    

    @IBAction func refillEnergyButtonTapped(_ sender: UIButton) {
        //return
        //todo in-app purchase disabled for testflight. todo re-enable when released
        if(MyData.allowInAppPurchases == 1) {
            let alert: UIAlertController

#if targetEnvironment(macCatalyst)
            alert = UIAlertController(title: "Purchase Energy Refill", message: "Purchase Energy Refill To Max For $0.99", preferredStyle: .alert)
            let purchaseAction = UIAlertAction(title: "Purchase", style: .default, handler: { _ in
                // Handle purchase action
                //print("purchase energy refill")
            })
            alert.addAction(purchaseAction)
#else
            alert = UIAlertController(title: "Refill Energy", message: "Watch a Rewarded Ad to Refill Energy or Purchase Energy Refill To Max", preferredStyle: .alert)
            let watchAdAction = UIAlertAction(title: "Watch Ad", style: .default, handler: { _ in
                // Handle watch ad action
                //print("watch ad to refill energy")
                self.show()
            })
            let purchaseAction = UIAlertAction(title: "Purchase", style: .default, handler: { _ in
                // Handle purchase action
                //print("purchase energy refill")
                if let price = IAPManager.shared.getPrice(for: ProductIdentifiers.refillEnergy) {
                    self.showEnergyRefillPurchaseAlert(price: price)
                } else {
                    self.showEnergyRefillPurchaseAlert(price: "$0.99")
                    //print("Product refill energy price not available")
                }


            })
            alert.addAction(watchAdAction)
            alert.addAction(purchaseAction)
#endif

            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            alert.addAction(cancelAction)

            self.present(alert, animated: true, completion: nil)
        }
        else {
            displayComingSoonAlert()
        }
    }


    @IBAction func showResetButtonTapped(_ sender: UIButton) {
        let alertController = UIAlertController(title: "Confirmation", message: "Are you sure you want to reset your username?", preferredStyle: .alert)

        // OK Action
        let okAction = UIAlertAction(title: "OK", style: .default) { _ in
            // Perform action upon OK
            //print("OK tapped")

            let email = Defaults[.email]
            OpenspaceAPI.shared.resetUsername(email: email) { result in
                switch result {
                case .success:
                    DispatchQueue.main.async {
                        Defaults[.username] = ""
                        //print("Successfully reset username submitted to server")

                        // Use the Utils class to present the username entry
                        Utils.presentUsernameEntry(from: self) { enteredUsername in
                            Defaults[.username] = enteredUsername
                            //print("New username entered: \(enteredUsername)")
                            self.updateUsernameLabel()
                        }
                    }
                case .failure(let error):
                    print("Error submitting to server: \(error.localizedDescription)")
                }
            }
        }
        alertController.addAction(okAction)

        // Cancel Action
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in
            // Perform action upon Cancel
            //print("Cancel tapped")
            // Add your logic here, if needed
        }
        alertController.addAction(cancelAction)

        // Present the alert controller
        self.present(alertController, animated: true, completion: nil)
    }

    func loadAdAwait() async {
        do {
            // Perform the loading of the rewarded ad asynchronously
            try await loadRewardedAd()
            // Handle successful loading
        } catch {
            // Handle any errors that occur during loading
            //print("Error loading rewarded ad: \(error)")
        }
    }
    func loadRewardedAd() async {
        #if !targetEnvironment(macCatalyst)

        do {
            //print("user id is")
            //print(Defaults[.userId])


#if DEBUG
            rewardedAd = try await GADRewardedAd.load(
                withAdUnitID: MyData.testRewardedVideo, request: GADRequest())


#else
            rewardedAd = try await GADRewardedAd.load(
                withAdUnitID: MyData.rewardedVideoForRefillEnergy, request: GADRequest())

#endif


            let serverSideVerificationOptions = GADServerSideVerificationOptions()
            serverSideVerificationOptions.userIdentifier = Defaults[.userId].description
            rewardedAd?.serverSideVerificationOptions = serverSideVerificationOptions
        } catch {
            //print("Rewarded ad failed to load with error: \(error.localizedDescription)")
        }

        #endif
    }
    func show() {
    #if !targetEnvironment(macCatalyst)
        guard let rewardedAd = rewardedAd else {
        return //print("Ad wasn't ready.")
      }

        // The UIViewController parameter is an optional.
        rewardedAd.present(fromRootViewController: nil) {
            // The server refills energy when Google's signed reward callback reaches it, a few
            // seconds after the ad. Save the refill now (the label used to be reset to the old
            // value when the ad closed), then confirm with the server once the callback is in.
            Defaults[.currentEnergy] = Defaults[.totalEnergy]
            self.lastRewardAt = Date()
            self.refreshLabels()
            DispatchQueue.main.asyncAfter(deadline: .now() + 10) { [weak self] in
                Utils.shared.getLocation {
                    DispatchQueue.main.async { self?.refreshLabels() }
                }
            }
      }
    #endif
    }

//    @objc func buttonTappedRewarded() {
//        //print("rewarded tap")
//        show()
//    }

    @IBAction func deleteButtonTapped(_ sender: UIButton) {
        let confirmationAlert = UIAlertController(title: "Delete Account", message: "Are you sure you want to delete your account? This removes your game permanently.", preferredStyle: .alert)
        confirmationAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        confirmationAlert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { [weak self] _ in
            guard let self = self else { return }
            // Sign in with Apple accounts must have their Apple token revoked when the account is
            // deleted. Apple asks the player to confirm once more; nothing is deleted if they cancel.
            guard AppleSignInRevoker.isAppleUser(Auth.auth().currentUser) else {
                // Ask the server first, while we still have the credentials. (Signing out and
                // clearing them first meant the server never received a valid delete request.)
                self.deleteUser()
                return
            }
            AppleSignInRevoker.revoke(presentingFrom: self.view) { [weak self] outcome in
                switch outcome {
                case .revoked:
                    self?.deleteUser()
                case .cancelled:
                    break
                case .failed:
                    let alert = UIAlertController(title: "Couldn't confirm with Apple",
                                                  message: "Your account was not deleted. Please try again with the Apple ID you use for Open Space.",
                                                  preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    self?.present(alert, animated: true)
                }
            }
        }))
        self.present(confirmationAlert, animated: true, completion: nil)
    }

    /// Signs out of Firebase and forgets every stored credential and cached value.
    private func clearLocalAccount() {
        try? Auth.auth().signOut()
        Defaults.removeAll()
        AppSecrets.appToken = ""
        AppSecrets.authToken = ""
    }

    func goToSignIn() {
        // Get the frame of the existing view controller's view
            let frame = self.view.frame

        // User is not signed in
        rootViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SignInViewController") as? SignInViewController

        // Set the frame of the new view controller's view to match the existing view controller's frame
        rootViewController!.view.frame = frame

        // Assuming you have a reference to your app's UIWindow object
        guard let window = UIApplication.shared.windows.first else {
            return
        }
        window.rootViewController = rootViewController
        window.makeKeyAndVisible()
    }

    @IBAction func signOutButtonTapped(_ sender: UIButton) {
        guard isGuest else {
            performSignOut()
            return
        }
        let alert = UIAlertController(title: "You're playing as a guest",
                                      message: "If you sign out without saving your account, this game can't be recovered.",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Save Your Account", style: .default) { [weak self] _ in self?.saveAccountTapped() })
        alert.addAction(UIAlertAction(title: "Sign Out Anyway", style: .destructive) { [weak self] _ in self?.performSignOut() })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }

    private func performSignOut() {
        clearLocalAccount()
        goToSignIn()
    }

    // Delete user
    ////////////////////
    ///
    func deleteUser() {
        let email = Defaults[.email] // Replace with the actual email
        let authToken = AppSecrets.authToken // Replace with the actual auth token

        OpenspaceAPI.shared.deleteUser(email: email, authToken: authToken) { [weak self] result in
            switch result {
            case .success:
                DispatchQueue.main.async {
                    // Remove the Firebase user too (may need a recent sign-in for Google/Apple;
                    // the game account is already gone either way).
                    Auth.auth().currentUser?.delete { _ in }
                    self?.clearLocalAccount()
                    self?.goToSignIn()
                }
            case .failure:
                DispatchQueue.main.async {
                    let alert = UIAlertController(title: "Couldn't delete your account",
                                                  message: "Please check your connection and try again.",
                                                  preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    self?.present(alert, animated: true)
                }
            }
        }
    }
    // Define the callback method with @objc attribute
      @objc func upgradeAction() {
          // Handle the button tap event
          //print("Upgrade button tapped")
          // Add your custom logic here
      }
    // Define the callback method with @objc attribute
      @objc func manageAction() {
          // Handle the button tap event
          //print("Manage Your Account button tapped")
          // Add your custom logic here
          showSubscriptionManagement()

      }
    func showSubscriptionManagement() {
        if let url = URL(string: "https://support.apple.com/en-us/HT202039") {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }

    func setPriceForLabel(price : String) {
        print("price")
        print(price)
        priceLabel.text="   Subscription to Premium lasts 1 month. It is \(price).   "

    }
    override func viewDidLoad() {
        //backgroundImageName = "conenebula.jpg"
           // Set the overlay alpha if you want a different value than the default
           //overlayAlpha = 0.5

        super.viewDidLoad()
        scrollView.delaysContentTouches = false
        scrollView.canCancelContentTouches = true
        addRestorePurchasesButton()


        if let price = IAPManager.shared.getPrice(for: ProductIdentifiers.premiumSubscription) {
            setPriceForLabel(price: price)
        } else {
            setPriceForLabel(price: "$4.99")
            //print("Product price not available")
        }

        NotificationCenter.default.addObserver(self, selector: #selector(handlePurchaseCompletion(_:)), name: .purchaseCompleted, object: nil)

    }

    deinit {
        NotificationCenter.default.removeObserver(self, name: .purchaseCompleted, object: nil)
    }
    func displayComingSoonAlert() {
        // Create the UIAlertController
        let alertController = UIAlertController(title: "Functionality Coming Soon",
                                                message: "This functionality will be available soon.",
                                                preferredStyle: .alert)

        // Create the OK action
        let okAction = UIAlertAction(title: "OK", style: .default) { _ in
            // Handle OK button tap if needed
        }

        // Add the OK action to the alert controller
        alertController.addAction(okAction)

        // Present the alert controller
        self.present(alertController, animated: true, completion: nil)
    }

    @objc func handlePurchaseCompletion(_ notification: Notification) {
          //print("handlePurchaseCompletion called")
          // Refresh Defaults and labels
        Utils.shared.getLocation() {
              //print("Refreshing labels after location update")
              DispatchQueue.main.async {
                  self.refreshLabels()
              }
          }
      }

      func refreshLabels() {
          //print("refreshing labels")
          self.energyLabel.text = "   Energy: \(Defaults[.currentEnergy]) out of \(Defaults[.totalEnergy])   "
          self.updateUsernameLabel()
          self.updateAccountTypeLabel()
      }

      func updateAccountTypeLabel() {
          var accountType = "Basic"
          if Defaults[.premium] == 1 {
              accountType = "Premium"
              self.upgradeToPremium.setTitle("Manage Your Account", for: .normal)
              self.upgradeToPremium.removeTarget(self, action: #selector(upgrade), for: .touchUpInside)
              self.upgradeToPremium.addTarget(self, action: #selector(manageAction), for: .touchUpInside)
          } else {
              self.upgradeToPremium.setTitle("Upgrade To Premium. Remove Ads.", for: .normal)
              self.upgradeToPremium.removeTarget(self, action: #selector(manageAction), for: .touchUpInside)
              self.upgradeToPremium.addTarget(self, action: #selector(upgrade), for: .touchUpInside)
          }
          if Auth.auth().currentUser?.isAnonymous ?? false {
            accountType += " (Guest)"
        }
        self.accountTypeLabel.text = "   Account Type: \(accountType)   "
        self.updateGuestUI()
      }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Ensure buttons are enabled and have default interaction
        signOutButton.isUserInteractionEnabled = true
        deleteButton.isUserInteractionEnabled = true
        upgradeToPremium.isUserInteractionEnabled = true
        refillEnergy.isUserInteractionEnabled = true

        // Ensure buttons have default highlight behavior
        signOutButton.adjustsImageWhenHighlighted = true
        deleteButton.adjustsImageWhenHighlighted = true
        upgradeToPremium.adjustsImageWhenHighlighted = true
        refillEnergy.adjustsImageWhenHighlighted = true

        updateUsernameLabel()
        self.energyLabel.text = "   Energy: \(Defaults[.currentEnergy]) out of \(Defaults[.totalEnergy])   "
        // Show the server's numbers, except right after a rewarded ad: Google's callback may not
        // have reached the server yet, and the delayed refresh above handles that case.
        if lastRewardAt.map({ Date().timeIntervalSince($0) > 15 }) ?? true {
            Utils.shared.getLocation { [weak self] in
                DispatchQueue.main.async { self?.refreshLabels() }
            }
        }
        var accountType = "Basic"
        if(Defaults[.premium] == 1) {
            accountType = "Premium"
            self.upgradeToPremium.setTitle("Manage Your Account", for: .normal)
            self.upgradeToPremium.addTarget(self, action: #selector(manageAction), for: .touchUpInside)
        }
        else {
            self.upgradeToPremium.setTitle("Upgrade To Premium. Remove Ads.", for: .normal)
            self.upgradeToPremium.addTarget(self, action: #selector(upgrade), for: .touchUpInside)
        }
        self.accountTypeLabel.text = "   Account Type: \(accountType)   "
        Task {
            await loadRewardedAd()
        }

        let amountFromSpheres = Defaults[.earningFromSpheresDaily]
        let amountFromObjects = Defaults[.earningFromObjectsDaily]
        let sphereCount = Defaults[.numberOfSpheres]
        let objectCount = Defaults[.theNumberOfObjects]


        //spheres
        if(amountFromSpheres == 10) {
            self.yourAccountIsEarning.text = "   Earning virtual $\(amountFromSpheres) per day from \(sphereCount) sphere.   "

        }
        else if(amountFromSpheres == 0) {
            self.yourAccountIsEarning.text = "   Earning virtual $\(amountFromSpheres) per day. Create a sphere to earn.   "

        }
        else {
            self.yourAccountIsEarning.text = "   Earning virtual $\(amountFromSpheres) per day from \(sphereCount) spheres.   "
        }

        // Objects. Creating new 3D objects is switched off, so only players who already
        // have some see this line (the stack view closes the gap when it is hidden).
        self.yourAccountIsEarningObjects.isHidden = (objectCount == 0)
        self.yourAccountIsEarningObjects.text = "   Earning virtual $\(amountFromObjects) per day from \(objectCount) \(objectCount == 1 ? "object" : "objects").   "


    }

    func updateUsernameLabel() {
        guard let user = Auth.auth().currentUser else { return }
        loggedInAs.text = user.isAnonymous ? "   Playing as a guest   " : "   Logged In As: \(user.email ?? "")   "
        username.text = "   Your Username: \(Defaults[.username])   "
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
}


/// Saves a guest (Firebase anonymous) game by linking Google or Apple sign-in. FirebaseUI's
/// auto-upgrade keeps the same Firebase user, so the server keeps the same game and records
/// the email. If that Google/Apple sign-in already has its own game, the player can switch to it.
final class AccountSaver: NSObject, FUIAuthDelegate {
    static let shared = AccountSaver()

    private var completion: ((Bool) -> Void)?

    func save(from presenter: UIViewController, completion: @escaping (Bool) -> Void) {
        guard Auth.auth().currentUser?.isAnonymous == true, let authUI = FUIAuth.defaultAuthUI() else {
            completion(false)
            return
        }
        self.completion = completion
        authUI.delegate = self
        authUI.shouldAutoUpgradeAnonymousUsers = true
        authUI.providers = [FUIGoogleAuth(authUI: authUI), FUIOAuth.appleAuthProvider()]
        let controller = authUI.authViewController()
        controller.modalPresentationStyle = .fullScreen
        presenter.present(controller, animated: true)
    }

    func authPickerViewController(forAuthUI authUI: FUIAuth) -> FUIAuthPickerViewController {
        return OpenSpaceAuthPickerViewController(nibName: "FUIAuthPickerViewController",
                                                 bundle: FUIAuthUtils.authUIBundle(),
                                                 authUI: authUI)
    }

    func authUI(_ authUI: FUIAuth, didSignInWith authDataResult: AuthDataResult?, error: Error?) {
        authUI.shouldAutoUpgradeAnonymousUsers = false

        if let error = error as NSError? {
            if error.domain == FUIAuthErrorDomain,
               error.code == Int(FUIAuthErrorCode.mergeConflict.rawValue),
               let credential = error.userInfo[FUIAuthCredentialKey] as? AuthCredential {
                askToSwitch(to: credential)
            } else if error.domain == FUIAuthErrorDomain, error.code == Int(FUIAuthErrorCode.userCancelledSignIn.rawValue) {
                finish(false)
            } else {
                show("Couldn't save your account", error.localizedDescription)
                finish(false)
            }
            return
        }

        guard let user = authDataResult?.user else {
            finish(false)
            return
        }
        register(user, success: ("Account saved", "Sign in with this account on any device to keep playing."))
    }

    /// Tells the game server about the signed-in user (it records the email for a saved guest).
    private func register(_ user: User, success: (String, String)) {
        user.getIDTokenForcingRefresh(true) { token, _ in
            guard let token = token else {
                self.show("Couldn't save your account", "Please try again.")
                self.finish(false)
                return
            }
            OpenspaceAPI.shared.loginWithEmail(email: user.email ?? "", authToken: token) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success:
                        Defaults[.email] = user.email ?? ""
                        AppSecrets.authToken = token
                        Utils.shared.getLocation()
                        self.show(success.0, success.1)
                        self.finish(true)
                    case .failure(let error):
                        self.show("Couldn't save your account", error.localizedDescription)
                        self.finish(false)
                    }
                }
            }
        }
    }

    private func askToSwitch(to credential: AuthCredential) {
        let alert = UIAlertController(title: "This account already has a game",
                                      message: "Switch to that game? The guest game on this device will be lost.",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in self.finish(false) })
        alert.addAction(UIAlertAction(title: "Switch", style: .destructive) { _ in
            Auth.auth().signIn(with: credential) { result, error in
                guard let user = result?.user else {
                    self.show("Couldn't switch accounts", error?.localizedDescription ?? "Please try again.")
                    self.finish(false)
                    return
                }
                self.register(user, success: ("Switched", "You're now playing your saved game."))
            }
        })
        AccountSaver.topViewController()?.present(alert, animated: true)
    }

    private func finish(_ saved: Bool) {
        let completion = self.completion
        self.completion = nil
        DispatchQueue.main.async { completion?(saved) }
    }

    private func show(_ title: String, _ message: String) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            AccountSaver.topViewController()?.present(alert, animated: true)
        }
    }

    static func topViewController() -> UIViewController? {
        let window = UIApplication.shared.delegate?.window ?? nil
        guard var top = window?.rootViewController else { return nil }
        while let presented = top.presentedViewController { top = presented }
        return top
    }
}


/// The Account screen's scroll view. UIKit normally won't let a drag that starts on a button
/// scroll the page once the button has the touch, so the page felt stuck. Here a drag always
/// scrolls; the button just loses its highlight, and a tap still presses it.
final class DragFriendlyScrollView: UIScrollView {
    override func touchesShouldCancel(in view: UIView) -> Bool {
        if view is UIControl { return true }
        return super.touchesShouldCancel(in: view)
    }
}
