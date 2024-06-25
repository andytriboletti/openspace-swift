import Foundation
import SceneKit

class Troll: SCNNode {
    var body: SCNNode!

    static func timeRange(forStartingAtFrame start: Int, endingAtFrame end: Int, fps: Double = 30) -> (offset: TimeInterval, duration: TimeInterval) {
        let startTime = self.time(atFrame: start, fps: fps)
        let endTime = self.time(atFrame: end, fps: fps)
        return (offset: startTime, duration: endTime - startTime)
    }

    static func time(atFrame frame: Int, fps: Double = 30) -> TimeInterval {
        return TimeInterval(frame) / fps
    }

    static func animation(from full: CAAnimation, startingAtFrame start: Int, endingAtFrame end: Int, fps: Double = 30) -> CAAnimation? {
        let range = self.timeRange(forStartingAtFrame: start, endingAtFrame: end, fps: fps)
        let animation = CAAnimationGroup()

        if let sub = full.copy() as? CAAnimation {
            sub.timeOffset = range.offset
            animation.animations = [sub]
            animation.duration = range.duration
            return animation
        } else {
            print("Failed to copy and cast CAAnimation")
            return nil
        }
    }

    func load() {
        guard let trollScene = SCNScene(named: "donkeyWithEyes.dae") else {
            fatalError("Can't load the scene")
        }

        guard let troll_body = trollScene.rootNode.childNode(withName: "j_Donkey_Body", recursively: true) else {
            fatalError("found no troll")
        }

        guard let troll_weapon = trollScene.rootNode.childNode(withName: "troll_weapon", recursively: true) else {
            fatalError("found no troll_weapon")
        }

        guard let troll_bracelet = trollScene.rootNode.childNode(withName: "troll_bracelet", recursively: true) else {
            fatalError("found no troll_bracelet")
        }

        guard let bips = trollScene.rootNode.childNode(withName: "Bip01", recursively: true) else {
            fatalError("found no Bip01")
        }

        guard let fullKey = bips.animationKeys.first else {
            fatalError("Bip01 got no animation")
        }

        guard let fullPlayer = bips.animationPlayer(forKey: fullKey) else {
            fatalError("Bip01 got no player for \(fullKey)")
        }

        let fullAnimation = CAAnimation(scnAnimation: fullPlayer.animation)

        self.addChildNode(troll_body)
        self.addChildNode(troll_weapon)
        self.addChildNode(troll_bracelet)
        self.addChildNode(bips)

        self.body = bips
        self.body.removeAllAnimations()

        if let walkAnimation = Troll.animation(from: fullAnimation, startingAtFrame: 10, endingAtFrame: 60) {
            walkAnimation.repeatCount = .greatestFiniteMagnitude
            walkAnimation.fadeInDuration = 0.3
            walkAnimation.fadeOutDuration = 0.3
            let walkPlayer = SCNAnimationPlayer(animation: SCNAnimation(caAnimation: walkAnimation))
            self.body.addAnimationPlayer(walkPlayer, forKey: "walk")
        } else {
            print("Failed to create walk animation")
        }

        if let deathAnimation = Troll.animation(from: fullAnimation, startingAtFrame: 1810, endingAtFrame: 1850) {
            deathAnimation.isRemovedOnCompletion = false
            deathAnimation.fadeInDuration = 0.3
            deathAnimation.fadeOutDuration = 0.3
            let deathPlayer = SCNAnimationPlayer(animation: SCNAnimation(caAnimation: deathAnimation))
            self.body.addAnimationPlayer(deathPlayer, forKey: "death")
        } else {
            print("Failed to create death animation")
        }

        self.scale = SCNVector3(0.1, 0.1, 0.1)
    }

    func walk() {
        print("+++ walk +++")
        self.body.animationPlayer(forKey: "walk")?.play()
    }

    func death() {
        print("+++ death +++")
        self.body.animationPlayer(forKey: "walk")?.stop(withBlendOutDuration: 0.3)
        self.body.animationPlayer(forKey: "death")?.play()
    }
}
