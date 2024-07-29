import UIKit
import FirebaseAuth
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

    #if !targetEnvironment(macCatalyst)
    var rewardedAd: GADRewardedAd?
    #endif

//    @IBAction func upgradeToPremium(_ sender: UIButton) {
//            upgrade()
//      }

    @objc func upgrade() {
        //return
        //todo in-app purchase disabled for testflight. todo re-enable when released
        if(MyData.allowInAppPurhcases == 1) {
            
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
    func showMineralPurchaseAlert(price: String) {
        // Create the alert controller with the price
        let msgText = "Do you want to purchase a small mineral pack with 20 of each type of mineral for \(price)?"
        let alertController = UIAlertController(title: "Confirm Purchase: Small Energy Pack", message: msgText, preferredStyle: .alert)

        // Create OK action
        let okAction = UIAlertAction(title: "OK", style: .default) { _ in
            // Call your method to initiate the purchase here
            self.purchaseSmallMineral()
            //print("purchase small Mineral")
        }
        alertController.addAction(okAction)

        // Create Cancel action
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)

        // Present the alert controller
        present(alertController, animated: true, completion: nil)
    }
    func showLargeMineralPurchaseAlert(price: String) {
        // Create the alert controller with the price
        let msgText = "Do you want to purchase a large mineral pack with 150 of each type of mineral for \(price)?"
        let alertController = UIAlertController(title: "Confirm Purchase: Large Mineral Pack", message: msgText, preferredStyle: .alert)

        // Create OK action
        let okAction = UIAlertAction(title: "OK", style: .default) { _ in
            // Call your method to initiate the purchase here
            self.purchaseLargeMineral()
            //print("purchase small Mineral")
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
    func purchaseSmallMineral() {
        if IAPManager.shared.products.first != nil {
            IAPManager.shared.purchaseProduct(with: ProductIdentifiers.smallMineralPack)
        } else {
            //print("Product smallMineralPack not available")
        }
    }
    func purchaseLargeMineral() {
        if IAPManager.shared.products.first != nil {
            IAPManager.shared.purchaseProduct(with: ProductIdentifiers.largeMineralPack)
        } else {
            //print("Product largeMineralPack not available")
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
        if(MyData.allowInAppPurhcases == 1) {

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

    @IBAction func buySmallMineralPack(_ sender: UIButton) {
        //return
        //todo in-app purchase disabled for testflight. todo re-enable when released
        if(MyData.allowInAppPurhcases == 1) {

            //print("buysmallMineralPack")

            if let price = IAPManager.shared.getPrice(for: ProductIdentifiers.smallMineralPack) {
                showMineralPurchaseAlert(price: price)
            } else {
                showMineralPurchaseAlert(price: "$0.99")
                //print("Product smallMineralPack price not available")
            }
        }
        else {
            displayComingSoonAlert()
        }
    }
    @IBAction func buyLargeMineralPack(_ sender: UIButton) {
        //return
        //todo in-app purchase disabled for testflight. todo re-enable when released

        //print("buyLargeMineralPack")
        if(MyData.allowInAppPurhcases == 1) {

            if let price = IAPManager.shared.getPrice(for: ProductIdentifiers.largeMineralPack) {
                showLargeMineralPurchaseAlert(price: price)
            } else {
                showLargeMineralPurchaseAlert(price: "$2.99")
                //print("Product largeMineralPack price not available")
            }
        }
        else {
            displayComingSoonAlert()
        }
    }

    

    @IBAction func refillEnergyButtonTapped(_ sender: UIButton) {
        //return
        //todo in-app purchase disabled for testflight. todo re-enable when released
        if(MyData.allowInAppPurhcases == 1) {
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
            let reward = rewardedAd.adReward
            //print("Refill Reward received with currency \(reward.amount), amount \(reward.amount.doubleValue)")
            //update energy label
            self.energyLabel.text = "   Energy: \(Defaults[.totalEnergy]) out of \(Defaults[.totalEnergy])   "

      }
    #endif
    }

//    @objc func buttonTappedRewarded() {
//        //print("rewarded tap")
//        show()
//    }

    @IBAction func deleteButtonTapped(_ sender: UIButton) {
           let confirmationAlert = UIAlertController(title: "Delete Account", message: "Are you sure you want to delete your account?", preferredStyle: .alert)
           confirmationAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
           confirmationAlert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { [weak self] _ in
               do {
                   try Auth.auth().signOut()
               } catch let signOutError as NSError {
                   //print("Error signing out: \(signOutError.localizedDescription)")
               }

               self?.deleteUser()
           }))

           // Present the confirmation alert
           self.present(confirmationAlert, animated: true, completion: nil)
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
        do {
            try Auth.auth().signOut()

            // Clear all stored values
            Defaults.removeAll()

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

            // Perform any additional actions or UI updates after sign out
        } catch let signOutError as NSError {
            //print("Error signing out: \(signOutError.localizedDescription)")
        }

    }

    // Delete user
    ////////////////////
    ///
    func deleteUser() {
        let email = Defaults[.email] // Replace with the actual email
        let authToken = Defaults[.authToken] // Replace with the actual auth token

        OpenspaceAPI.shared.deleteUser(email: email, authToken: authToken) { [weak self] result in
            switch result {
            case .success(let message):
                // User deleted successfully
                //print("Success: \(message)")

                // Clear all stored values
                Defaults.removeAll()

                DispatchQueue.main.async {
                    // Your UI update code or UI-related task
                    self?.goToSignIn()
                }
            case .failure(let error):
                // Handle the error
                print("Error: \(error.localizedDescription)")
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

    override func viewDidLoad() {
        //backgroundImageName = "conenebula.jpg"
           // Set the overlay alpha if you want a different value than the default
           //overlayAlpha = 0.5

        super.viewDidLoad()
        scrollView.delaysContentTouches = false
        scrollView.canCancelContentTouches = true



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
          self.accountTypeLabel.text = "   Account Type: \(accountType)   "
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

        //objects
        if(amountFromObjects == 5) {
            self.yourAccountIsEarningObjects.text = "   Earning virtual $\(amountFromObjects) per day from \(objectCount) object.   "

        }
        else if(amountFromSpheres == 0) {
            self.yourAccountIsEarningObjects.text = "   Earning virtual $\(amountFromObjects) per day. Create a object to earn.   "

        }
        else {
            self.yourAccountIsEarningObjects.text = "   Earning virtual $\(amountFromObjects) per day from \(objectCount) objects.   "
        }


    }

    func updateUsernameLabel() {
        if let user = Auth.auth().currentUser, let email = user.email {
            loggedInAs.text = "   Logged In As: \(email)   "
            username.text = "   Your Username: \(Defaults[.username])   "
        }
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
