import UIKit
import SceneKit
import Alamofire
import Firebase
// import GoogleMobileAds
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

    #if targetEnvironment(macCatalyst)
    #else
        // var interstitial: GADInterstitial!
    #endif
    let animationDuration = 2.0

    var session: Session = Alamofire.Session()
    var window: UIWindow?

    var gameState: GameState!
    var blurView: DynamicBlurView?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        IQKeyboardManager.shared.enable = true

        self.gameState = GameState()

        #if targetEnvironment(macCatalyst)
        #else
        //    GADMobileAds.sharedInstance().start(completionHandler: nil)
        //    interstitial = createAndLoadInterstitial()
        #endif

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

        // The AlienTavern comments service (Lunar Lounge) was removed: its API no longer
        // exists, and it needed an app-wide secret that can't be kept safe inside an app.

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

    /// Shows the app open ad when the app comes to the foreground. Called by SceneDelegate:
    /// with the scene lifecycle, UIKit no longer calls applicationDidBecomeActive.
    func showAppOpenAdIfNeeded() {

#if targetEnvironment(macCatalyst)

#else
        //only non premium users should get ad
        if AdPolicy.showAutomaticAds {
            let username = Defaults[.username]

            //only logged in users should get ad, at most once a day
            if(username != "") && AdPolicy.canShowDailyAd(.lastAppOpenAdShown) {
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

/// The app's window scene. iOS 27 requires the scene-based app lifecycle: an app built with the
/// iOS 27 SDK that only has an app delegate crashes at launch
/// (_UIApplicationEvaluateRuntimeIssueForNoSceneLifecycleAdoption). Info.plist names this class
/// and Main.storyboard, so UIKit creates the window from the storyboard as before.
///
/// The window is also handed to the app delegate, so code that reads AppDelegate.window or
/// UIApplication.shared.delegate?.window (purchase alerts, Save Your Account, Game Center)
/// keeps working.
class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        (UIApplication.shared.delegate as? AppDelegate)?.window = window
        #if targetEnvironment(macCatalyst)
        // The game's screens are laid out for a portrait phone; don't let the Mac window get
        // so small that buttons overlap.
        if let windowScene = scene as? UIWindowScene {
            windowScene.sizeRestrictions?.minimumSize = CGSize(width: 600, height: 720)
        }
        #endif
        // A Google sign-in redirect that launched the app.
        handle(connectionOptions.urlContexts)
    }

    /// Google sign-in redirects. These used to arrive at application(_:open:options:).
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        handle(URLContexts)
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        (UIApplication.shared.delegate as? AppDelegate)?.showAppOpenAdIfNeeded()
    }

    private func handle(_ contexts: Set<UIOpenURLContext>) {
        for context in contexts {
            _ = GIDSignIn.sharedInstance.handle(context.url)
        }
    }
}

/// Whether to show the ads that appear on their own: the banner, the app open ad and the
/// interstitial when traveling. Premium players see none. Debug builds launched with
/// -ScreenshotMode show none either, so App Store screenshots and app preview videos can be
/// recorded without Google's test ads in them. Rewarded ads only appear when the player asks.
enum AdPolicy {
    static var showAutomaticAds: Bool {
        #if DEBUG
        if ProcessInfo.processInfo.arguments.contains("-ScreenshotMode") { return false }
        #endif
        return Defaults[.premium] == 0
    }

    /// Full-screen ads (the travel interstitial and the app-open ad) show at most once per
    /// calendar day each. Banners and rewarded ads the player chooses to watch are not limited.
    static func canShowDailyAd(_ key: Defaults.Key<Double>) -> Bool {
        let last = Defaults[key]
        guard last > 0 else { return true }
        return !Calendar.current.isDateInToday(Date(timeIntervalSince1970: last))
    }

    static func recordDailyAdShown(_ key: Defaults.Key<Double>) {
        Defaults[key] = Date().timeIntervalSince1970
    }
}
