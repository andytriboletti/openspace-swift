import UIKit
import SceneKit
import Alamofire
import Firebase
import ShowTime
// import GoogleMobileAds
import MaterialComponents.MaterialButtons
import MaterialComponents.MaterialButtons_Theming
import FirebaseCore
import SpriteKit
import DynamicBlurView
import GoogleSignIn
import IQKeyboardManagerSwift
import StoreKit
import GameKit
import Defaults

#if !targetEnvironment(macCatalyst)

import GoogleMobileAds
#endif

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    #if !targetEnvironment(macCatalyst)

    var interstitial: GADInterstitialAd?

    #endif

    var containerSchemeBlue: MDCContainerScheme!
    var containerSchemeRed: MDCContainerScheme!

    #if targetEnvironment(macCatalyst)
    #else
        // var interstitial: GADInterstitial!
    #endif
    let animationDuration = 2.0

    var gridNode = SCNNode()
    var donkeyNode: SCNNode?
    var elephantNode: SCNNode?
    var bernieProtesterNode: SCNNode?
    var trumpProtesterNode: SCNNode?
    var fistNodeBlue: SCNNode?
    var fistNodeRed: SCNNode?

    let donkeyScene = SCNScene(named: "donkeyWithEyes.dae")
    let elephantScene = SCNScene(named: "elephant3.dae")

    var team: String?
    var username: String?
    var isMultiplayer: Bool = false

    var scene: GameScene?
    var gameViewController: GridHackGameViewController?
    var session: Session = Alamofire.Session()
    var multiplayer: Multiplayer = Multiplayer()
    var window: UIWindow?

    var gameState: GameState!
    var gridHackGameState: GridHackGameState!
    var blurView: DynamicBlurView?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Common setup
        team="bernie"
        FirebaseApp.configure()
        IQKeyboardManager.shared.enable = true

        // GridHack setup
        ShowTime.enabled = .never
        containerSchemeBlue = MDCContainerScheme()
        containerSchemeBlue.colorScheme.primaryColor = UIColor.blue.darker()!
        containerSchemeBlue.colorScheme.primaryColorVariant = .blue

        let customTypographyScheme = MDCTypographyScheme(defaults: .material201902)
        customTypographyScheme.button = UIFont.systemFont(ofSize: 20)
        containerSchemeBlue.typographyScheme = customTypographyScheme

        containerSchemeRed = MDCContainerScheme()
        containerSchemeRed.colorScheme.primaryColor = UIColor.red.darker()!
        containerSchemeRed.colorScheme.primaryColorVariant = .red
        containerSchemeRed.typographyScheme = customTypographyScheme

        self.gameState = GameState()

        #if targetEnvironment(macCatalyst)
        #else
        //    GADMobileAds.sharedInstance().start(completionHandler: nil)
        //    interstitial = createAndLoadInterstitial()
        #endif

        initializeNodes()

        IAPManager.shared.requestProducts()
        // Add IAPManager as a transaction observer
        SKPaymentQueue.default().add(IAPManager.shared)

        #if !targetEnvironment(macCatalyst)

        // Initialize Google Mobile Ads SDK
        GADMobileAds.sharedInstance().start(completionHandler: nil)

        // Preload the interstitial ad
        preloadInterstitialAd()

        GADMobileAds.sharedInstance().requestConfiguration.testDeviceIdentifiers = [ "7650f474f6d6bc3a6b6a069fe06b8248" ]
        
        #endif

        authenticateGameCenter()

      // Configure AlienTavernManager with app-level configuration
      let appConfig = ATAppConfig(app_id: "1499913239")
      AlienTavernManager.shared.configure(with: appConfig)


      // Setup AlienTavernManager
      AlienTavernManager.shared.setup { success, errorMessage in
          if success {
              print("AlienTavernManager setup successful")
          } else {
              print("AlienTavernManager setup failed: \(errorMessage ?? "Unknown error")")
              // Handle setup failure (e.g., show an alert to the user)
          }
      }

        
        return true
    }

    #if !targetEnvironment(macCatalyst)

    func preloadInterstitialAd() {

#if DEBUG
        GADInterstitialAd.load(withAdUnitID: MyData.testInterstitialAd, request: GADRequest()) { [weak self] ad, error in
            if let error = error {
                //print("Failed to load test travel interstitial ad with error: \(error.localizedDescription)")
                return
            }
            self?.interstitial = ad
            //print("Interstitial test ad loaded successfully.")
        }



#else
        GADInterstitialAd.load(withAdUnitID: MyData.travelInterstitialAd, request: GADRequest()) { [weak self] ad, error in
            if let error = error {
                //print("Failed to load travel interstitial ad with error: \(error.localizedDescription)")
                return
            }
            self?.interstitial = ad
            //print("Interstitial ad loaded successfully.")
        }

#endif



    }
    #endif

    func initializeNodes() {
        donkeyNode = SCNNode()
        let shipScene = SCNScene(named: "donkeyWithEyes.dae")
        shipScene?.rootNode.childNodes.forEach { donkeyNode!.addChildNode($0) }

        elephantNode = SCNNode()
        let eScene = SCNScene(named: "elephant3.dae")
        eScene?.rootNode.childNodes.forEach { elephantNode!.addChildNode($0) }

        bernieProtesterNode = SCNNode()
        let bScene = SCNScene(named: "sm_Protester_Bernie.dae")
        bScene?.rootNode.childNodes.forEach { bernieProtesterNode!.addChildNode($0) }

        trumpProtesterNode = SCNNode()
        let tScene = SCNScene(named: "sm_Protester_Trump.dae")
        tScene?.rootNode.childNodes.forEach { trumpProtesterNode!.addChildNode($0) }

        fistNodeBlue = SCNNode()
        let fScene = SCNScene(named: "fist_instant_mesh_blue.dae")
        fScene?.rootNode.childNodes.forEach { fistNodeBlue!.addChildNode($0) }

        fistNodeRed = SCNNode()
        let rScene = SCNScene(named: "fist_instant_mesh_red.dae")
        rScene?.rootNode.childNodes.forEach { fistNodeRed!.addChildNode($0) }
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
      // Show the app open ad when the app is foregrounded.

#if targetEnvironment(macCatalyst)

#else
        let isPremium = Defaults[.premium]
        //only non premium users should get ad
        if(isPremium == 0 ) {
            let username = Defaults[.username]

            //only logged in users should get ad
            if(username != "") {
                AppOpenAdManager.shared.showAdIfAvailable()
            }
        }
#endif

    }

    func authenticateGameCenter() {
        let localPlayer = GKLocalPlayer.local
        localPlayer.authenticateHandler = { viewController, error in
            if let viewController = viewController {
                // Present the Game Center login view controller
                self.window?.rootViewController?.present(viewController, animated: true, completion: nil)
            } else if localPlayer.isAuthenticated {
                // Player is authenticated
                //print("Player is authenticated")
            } else {
                // Game Center is disabled or there was an error
                //print("Game Center authentication failed")
            }
        }
    }

    func submitScore() {
        let cash = Defaults[.currency]
        let score = GKScore(leaderboardIdentifier: "com.greenrobot.openspace.top_cash")
        score.value = Int64(cash)

        GKScore.report([score]) { error in
            if let error = error {
                //print("Error submitting score: \(error.localizedDescription)")
            } else {
                //print("Score submitted successfully")
            }
        }
    }




    #if targetEnvironment(macCatalyst)
    #else
//        func interstitialDidDismissScreen(_ ad: GADInterstitial) {
//            interstitial = createAndLoadInterstitial()
//        }
//
//        func createAndLoadInterstitial() -> GADInterstitial {
//            interstitial = GADInterstitial(adUnitID: Common.interstitialAdmobId)
//            interstitial.delegate = self
//            interstitial.load(GADRequest())
//            return interstitial
//        }
    #endif

    func applicationWillResignActive(_ application: UIApplication) {
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
    }


    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        return GIDSignIn.sharedInstance.handle(url)
    }
}

// Extensions
extension UIViewController {
    var appDelegate: AppDelegate {
        return (UIApplication.shared.delegate as? AppDelegate?)!!
    }
}

extension SCNScene {
    var appDelegate: AppDelegate {
        return (UIApplication.shared.delegate as? AppDelegate?)!!
    }
}
extension GameScore {
    var appDelegate: AppDelegate {
        return (UIApplication.shared.delegate as? AppDelegate?)!!
    }
}
extension GridHackUtils {
    var appDelegate: AppDelegate {
        return (UIApplication.shared.delegate as? AppDelegate?)!!
    }
    var gameState: GameState {
        return appDelegate.gameState
    }
}

extension FactoryFactory {
    var appDelegate: AppDelegate {
        return (UIApplication.shared.delegate as? AppDelegate?)!!
    }
}

extension SCNNode {
    convenience init(named name: String) {
        self.init()
        guard let scene = SCNScene(named: name) else { return }
        scene.rootNode.childNodes.forEach { addChildNode($0) }
    }
}

extension UIColor {
    func lighter(by percentage: CGFloat = 30.0) -> UIColor? {
        return self.adjust(by: abs(percentage))
    }

    func darker(by percentage: CGFloat = 30.0) -> UIColor? {
        return self.adjust(by: -1 * abs(percentage))
    }

    func adjust(by percentage: CGFloat = 30.0) -> UIColor? {
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        if self.getRed(&red, green: &green, blue: &blue, alpha: &alpha) {
            return UIColor(red: min(red + percentage/100, 1.0), green: min(green + percentage/100, 1.0), blue: min(blue + percentage/100, 1.0), alpha: alpha)
        } else {
            return nil
        }
    }
}

public extension UIBezierPath {
    var elements: [PathElement] {
        var pathElements = [PathElement]()
        withUnsafeMutablePointer(to: &pathElements) { elementsPointer in
            cgPath.apply(info: elementsPointer) { (userInfo, nextElementPointer) in
                let nextElement = PathElement(element: nextElementPointer.pointee)
                let elementsPointer = userInfo!.assumingMemoryBound(to: [PathElement].self)
                elementsPointer.pointee.append(nextElement)
            }
        }
        return pathElements
    }
}

public enum PathElement {
    case moveToPoint(CGPoint)
    case addLineToPoint(CGPoint)
    case addQuadCurveToPoint(CGPoint, CGPoint)
    case addCurveToPoint(CGPoint, CGPoint, CGPoint)
    case closeSubpath

    init(element: CGPathElement) {
        switch element.type {
        case .moveToPoint: self = .moveToPoint(element.points[0])
        case .addLineToPoint: self = .addLineToPoint(element.points[0])
        case .addQuadCurveToPoint: self = .addQuadCurveToPoint(element.points[0], element.points[1])
        case .addCurveToPoint: self = .addCurveToPoint(element.points[0], element.points[1], element.points[2])
        case .closeSubpath: self = .closeSubpath
        @unknown default:
            fatalError()
        }
    }
}

public extension SCNAction {

    class func moveAlong(path: UIBezierPath) -> SCNAction {
        let animationDuration = 2.0

        let points = path.elements
        var actions = [SCNAction]()
        for point in points {
            switch point {
            case .moveToPoint(let aaa):
                let moveAction = SCNAction.move(to: SCNVector3(aaa.x, aaa.y, 0), duration: animationDuration)
                actions.append(moveAction)
            case .addCurveToPoint(let aaa, let bbb, let ccc):
                let moveAction1 = SCNAction.move(to: SCNVector3(aaa.x, aaa.y, 0), duration: animationDuration)
                let moveAction2 = SCNAction.move(to: SCNVector3(bbb.x, bbb.y, 0), duration: animationDuration)
                let moveAction3 = SCNAction.move(to: SCNVector3(ccc.x, ccc.y, 0), duration: animationDuration)
                actions.append(moveAction1)
                actions.append(moveAction2)
                actions.append(moveAction3)
            case .addLineToPoint(let aaa):
                let moveAction = SCNAction.move(to: SCNVector3(aaa.x, aaa.y, 0), duration: animationDuration)
                actions.append(moveAction)
            case .addQuadCurveToPoint(let aaa, let bbb):
                let moveAction1 = SCNAction.move(to: SCNVector3(aaa.x, aaa.y, 0), duration: animationDuration)
                let moveAction2 = SCNAction.move(to: SCNVector3(bbb.x, bbb.y, 0), duration: animationDuration)
                actions.append(moveAction1)
                actions.append(moveAction2)
            default:
                let moveAction = SCNAction.move(to: SCNVector3(0, 0, 0), duration: animationDuration)
                actions.append(moveAction)
            }
        }
        return SCNAction.sequence(actions)
    }
}

extension SCNNode {
    func getTopParent(rootNode: SCNNode) -> SCNNode {
        if self.parent == nil || self.parent == rootNode {
            return self
        } else {
            return (self.parent?.getTopParent(rootNode: rootNode))!
        }

    }
}


//extension AppDelegate: GADFullScreenContentDelegate {
//    func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
//        //print("Interstitial ad failed to present with error: \(error.localizedDescription)")
//    }
//
////    func adDidPresentFullScreenContent(_ ad: GADFullScreenPresentingAd) {
////        //print("Interstitial ad did present.")
////    }
//
//    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
//        //print("Interstitial ad did dismiss.")
//        // Preload another ad after the current one is dismissed
//        preloadInterstitialAd()
//    }
//}
extension Notification.Name {
    static let purchaseCompleted = Notification.Name("purchaseCompleted")
}
