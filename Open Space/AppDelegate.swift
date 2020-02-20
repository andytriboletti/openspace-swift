//
//  AppDelegate.swift
//  Open Space
//
//  Created by Andy Triboletti on 2/19/20.
//  Copyright © 2020 GreenRobot LLC. All rights reserved.
//

import UIKit
import SceneKit
import SpriteKit
import MaterialComponents.MaterialButtons
import MaterialComponents.MaterialButtons_Theming

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var containerScheme:MDCContainerScheme!
    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        containerScheme = MDCContainerScheme()
        
        //containerScheme.colorScheme.primaryColor = .green
        
        let shapeScheme = MDCShapeScheme()
        // Small Component Shape
        shapeScheme.smallComponentShape = MDCShapeCategory(cornersWith: .cut, andSize: 4)

        // Medium Component Shape
        shapeScheme.mediumComponentShape = MDCShapeCategory(cornersWith: .rounded, andSize: 10)

        // Large Component Shape
        let largeShapeCategory = MDCShapeCategory()
        let rounded50PercentCorner = MDCCornerTreatment.corner(withRadius: 0.5,
                                                               valueType: .percentage)
        let cut8PointsCorner = MDCCornerTreatment.corner(withCut: 8)
        largeShapeCategory?.topLeftCorner = rounded50PercentCorner
        largeShapeCategory?.topRightCorner = rounded50PercentCorner
        largeShapeCategory?.bottomLeftCorner = cut8PointsCorner
        largeShapeCategory?.bottomRightCorner = cut8PointsCorner
        shapeScheme.largeComponentShape = largeShapeCategory!
        
        
        containerScheme.shapeScheme = shapeScheme
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
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

let animationDuration = 2.0

public extension SCNAction {
    
    class func moveAlong(path: UIBezierPath) -> SCNAction {
        
        let points = path.elements
        var actions = [SCNAction]()
        
        for point in points {
            
            switch point {
            case .moveToPoint(let aaa):
                let moveAction = SCNAction.move(to: SCNVector3(aaa.x, aaa.y, 0), duration: animationDuration)
                actions.append(moveAction)
                break
                
            case .addCurveToPoint(let aaa, let bbb, let ccc ):
                let moveAction1 = SCNAction.move(to: SCNVector3(aaa.x, aaa.y, 0), duration: animationDuration)
                let moveAction2 = SCNAction.move(to: SCNVector3(bbb.x, bbb.y, 0), duration: animationDuration)
                let moveAction3 = SCNAction.move(to: SCNVector3(ccc.x, ccc.y, 0), duration: animationDuration)
                actions.append(moveAction1)
                actions.append(moveAction2)
                actions.append(moveAction3)
                break
                
            case .addLineToPoint(let aaa ):
                let moveAction = SCNAction.move(to: SCNVector3(aaa.x, aaa.y, 0), duration: animationDuration)
                actions.append(moveAction)
                break
                
            case .addQuadCurveToPoint(let aaa, let bbb ):
                let moveAction1 = SCNAction.move(to: SCNVector3(aaa.x, aaa.y, 0), duration: animationDuration)
                let moveAction2 = SCNAction.move(to: SCNVector3(bbb.x, bbb.y, 0), duration: animationDuration)
                actions.append(moveAction1)
                actions.append(moveAction2)
                break
                
            default:
                let moveAction = SCNAction.move(to: SCNVector3(0, 0, 0), duration: animationDuration)
                actions.append(moveAction)
                break
            }
        }
        return SCNAction.sequence(actions)
    }
    
}

extension SCNNode {

    convenience init(named name: String) {
        self.init()

        guard let scene = SCNScene(named: name) else {
            return
        }

        for childNode in scene.rootNode.childNodes {
            addChildNode(childNode)
        }
    }

}
//extensions
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
