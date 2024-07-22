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

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
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

        return true
    }

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

    func applicationDidBecomeActive(_ application: UIApplication) {
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
