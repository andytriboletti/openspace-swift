//
//  InformationOverlayScene.swift
//  GridHackSceneKit
//
//  Created by Andy Triboletti on 1/30/20.
//  Copyright © 2020 GreenRobot LLC. All rights reserved.
//

import SpriteKit
import SceneKit
open class InfoOverlayScene: SKScene {
    weak var appDelegate: AppDelegate!
    var gs: GridHackGameState!

    open var labelNode: SKLabelNode?
    open var labelNode2: SKLabelNode?
    open var labelNode3: SKLabelNode?
    var timer: Timer?
    open var scoreLabelNode: SKLabelNode?
    open var timerLabelNode: SKLabelNode?
    open var instructionsLabelNode: SKLabelNode?
    var fontSize: Float = 24.0
    var timeLeft: Int = Int(Common.timeLeft)

    public var gameScene: GameScene?
    let attackerButton = SKSpriteNode()
    let builderButton = SKSpriteNode()
    let hackerButton = SKSpriteNode()

    var scoreX = 0
    var scoreY = 0

    var timerY = 0

    let hackerY = 100
    let attackerY = 100
    let builderY = 100

    class func calculateOptimalFontSize(textLength: CGFloat, boundingBox: CGRect) -> CGFloat {
        let area: CGFloat = boundingBox.width * boundingBox.height
        return sqrt(area / textLength)
    }

    func getTimeAndInstructionsFontSize(quote: String) -> Float {
        // swiftlint:disable:next line_length
        return Float(InfoOverlayScene.calculateOptimalFontSize(textLength: CGFloat(quote.count), boundingBox: CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: self.frame.size.width - 20, height: self.getHeightForTimeAndInstructions()))))
    }
    func getFontSizeForUnits() -> CGFloat {
        print(GridHackUtils().modelIdentifier())
        var fontSize = 20.0
        if GridHackUtils().modelIdentifier() == "iPhone8,4" {
            fontSize = 16.0
        }
        return CGFloat(fontSize)
    }
    func getHeightForTimeAndInstructions() -> CGFloat {
        var height = 50
        if GridHackUtils().modelIdentifier() == "iPhone8,4" {
            height = 30
        }
        return CGFloat(height)
    }
    func getYForTimeAndInstructions() -> CGFloat {
        var padding = 180
        if GridHackUtils().modelIdentifier() == "iPhone8,4" {
            padding = 160
        }
        return CGFloat(padding)
    }
    func getXCoordinatesForUnitLables() -> [Int] {
        let builderX = Int(self.frame.minX) + 70
        let attackerX = Int(self.frame.midX)
        let hackerX = Int(self.frame.maxX) - 70
        return [builderX, attackerX, hackerX]
    }
    override init(size: CGSize) {
        super.init(size: size)

        // scaleMode = .resizeFill
        scoreX = Int(self.frame.maxX - 200)
        scoreY = Int(self.frame.maxY - 120)
        timerY = Int(self.frame.maxY - self.getYForTimeAndInstructions())
        var quote = " Instigators "
        var attributedQuote = NSMutableAttributedString(string: quote)
        var attributes: [NSAttributedString.Key: Any] = [.backgroundColor: UIColor.white, NSAttributedString.Key.font: UIFont.systemFont(ofSize: self.getFontSizeForUnits())]
        attributedQuote.addAttributes(attributes, range: NSRange(location: 0, length: quote.count))
        labelNode = SKLabelNode(attributedText: attributedQuote)
        labelNode?.position = CGPoint(x: self.getXCoordinatesForUnitLables()[0], y: builderY)
        labelNode?.fontColor=UIColor.black
        // labelNode?.width = labelNode?.intrinsicContentSize.width + 10
        // labelNode?.frame.size.height = labelNode?.intrinsicContentSize.height + 10
        // labelNode?.textAlignment = .center
        self.addChild(labelNode!)

        quote = " Protesters "// "Attackers"
        attributedQuote = NSMutableAttributedString(string: quote)
        attributes = [.backgroundColor: UIColor.white, NSAttributedString.Key.font: UIFont.systemFont(ofSize: self.getFontSizeForUnits())]
        attributedQuote.addAttributes(attributes, range: NSRange(location: 0, length: quote.count))
        labelNode2 = SKLabelNode(attributedText: attributedQuote)
        labelNode2?.position = CGPoint(x: self.getXCoordinatesForUnitLables()[1], y: attackerY)
        labelNode2?.fontColor=UIColor.black
        self.addChild(labelNode2!)

        quote = " Independents "// "Hackers"
        attributedQuote = NSMutableAttributedString(string: quote)
        attributes = [.backgroundColor: UIColor.white, NSAttributedString.Key.font: UIFont.systemFont(ofSize: self.getFontSizeForUnits())]
        attributedQuote.addAttributes(attributes, range: NSRange(location: 0, length: quote.count))
        labelNode3 = SKLabelNode(attributedText: attributedQuote)
        labelNode3?.position = CGPoint(x: self.getXCoordinatesForUnitLables()[2], y: hackerY)
        labelNode3?.fontColor=UIColor.black
        self.addChild(labelNode3!)

        quote = " Your Score: 0   Opponent Score: 0 "
        self.fontSize = getTimeAndInstructionsFontSize(quote: quote)
        print("fontSize is \(fontSize)")
        attributedQuote = NSMutableAttributedString(string: quote)
        attributes = [.backgroundColor: UIColor.white, NSAttributedString.Key.font: UIFont.systemFont(ofSize: CGFloat(fontSize))]
        attributedQuote.addAttributes(attributes, range: NSRange(location: 0, length: quote.count))
        scoreLabelNode = SKLabelNode(attributedText: attributedQuote)
        scoreLabelNode?.position = CGPoint(x: Int(self.frame.midX), y: scoreY)
        scoreLabelNode?.lineBreakMode = NSLineBreakMode.byWordWrapping
        scoreLabelNode?.numberOfLines = 0
        scoreLabelNode?.preferredMaxLayoutWidth = self.frame.maxX
        scoreLabelNode?.fontColor=UIColor.black
        self.addChild(scoreLabelNode!)

        quote = " Time Left: 30s. Tap unselected squares. "
        // swiftlint:disable:next line_length
        let fontSize2 = getTimeAndInstructionsFontSize(quote: quote)
        print("fontSize is \(fontSize2)")
        attributedQuote = NSMutableAttributedString(string: quote)
        attributes = [.backgroundColor: UIColor.white, NSAttributedString.Key.font: UIFont.systemFont(ofSize: CGFloat(fontSize2))]
        attributedQuote.addAttributes(attributes, range: NSRange(location: 0, length: quote.count))
        timerLabelNode = SKLabelNode(attributedText: attributedQuote)
        timerLabelNode?.position = CGPoint(x: Int(self.frame.midX), y: timerY)
        timerLabelNode?.lineBreakMode = NSLineBreakMode.byWordWrapping
        timerLabelNode?.numberOfLines = 0
        timerLabelNode?.preferredMaxLayoutWidth = self.frame.maxX
        timerLabelNode?.fontColor=UIColor.black
        self.addChild(timerLabelNode!)

        createAddBuilderButton()
        createAddAttackerButton()
        createAddHackerButton()
        self.appDelegate = UIApplication.shared.delegate as? AppDelegate
        gs = appDelegate.gridHackGameState

    }
    func stopTimer() {
      timer?.invalidate()
      timer = nil
    }
    func startTimer() {
        self.timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: Selector(("runTimer")), userInfo: nil, repeats: true)
    }

    @objc func runTimer() {
        let showBuilder = shouldShowBuilder()
        let showAttacker = shouldShowAttacker()
        let showHacker = shouldShowHacker()
        if showBuilder {
            builderButton.isHidden=false
        } else {
            builderButton.isHidden=true
        }
        if showAttacker {
            attackerButton.isHidden=false
        } else {
            attackerButton.isHidden=true
        }
        if showHacker {
            hackerButton.isHidden=false
        } else {
            hackerButton.isHidden=true
        }

        calculateAndUpdateScore()
        updateTimeLeft(showBuilder: showBuilder, showAttacker: showAttacker, showHacker: showHacker)
    }
    func getGameInstructions(showBuilder: Bool, showAttacker: Bool, showHacker: Bool) -> String {
        var instructions = "Tap unselected squares."
        let tapUnselected = "Tap unselected squares,"
        if showBuilder && showAttacker && showHacker {
            instructions = "\(tapUnselected) or send in an Instigator, Protester, or Independent unit."
        } else if showBuilder && showAttacker {
                instructions = "\(tapUnselected) or send in an Instigator or Protester unit"
        } else if showBuilder && showHacker {
            instructions = "\(tapUnselected) or send in an Instigator or an Independent unit"
        } else if showAttacker && showHacker {
            instructions = "\(tapUnselected) or send in a Protester or Independent unit."
        } else if showHacker {
            instructions = "\(tapUnselected) or send in an Independent unit."
        } else if showBuilder {
            instructions = "\(tapUnselected) or send in an Instigator unit."
        } else if showAttacker {
            instructions = "\(tapUnselected) or send in a Protester unit."
        }
        return instructions
    }
    func updateTimeLeft(showBuilder: Bool, showAttacker: Bool, showHacker: Bool) {
        if self.timeLeft == 0 {
            self.timeLeft = 30
            self.appDelegate.multiplayer.delegate?.endGame()
            return
        }
        self.timeLeft -= 1

        let instructions = self.getGameInstructions(showBuilder: showBuilder, showAttacker: showAttacker, showHacker: showHacker)
        let updatedScoreText = " Time Left: \(self.timeLeft)s. \(instructions) "

        let attributedQuote = NSMutableAttributedString(string: updatedScoreText)
        let attributes = [.backgroundColor: UIColor.white, NSAttributedString.Key.font: UIFont.systemFont(ofSize: CGFloat(self.getTimeAndInstructionsFontSize(quote: updatedScoreText)))]
               attributedQuote.addAttributes(attributes, range: NSRange(location: 0, length: updatedScoreText.count))

        attributedQuote.addAttributes(attributes, range: NSRange(location: 0, length: updatedScoreText.count))

        timerLabelNode?.attributedText = attributedQuote
    }
    func calculateAndUpdateScore() {
        let gameScore = GameScore()
        let opponentScore = gameScore.getOpponentScore()
        let yourScore = gameScore.getYourScore()

        let updatedScoreText = " Your Score: \(yourScore)   Opponent Score: \(opponentScore) "

        // swiftlint:disable:next line_length
        self.fontSize = Float(InfoOverlayScene.calculateOptimalFontSize(textLength: CGFloat(updatedScoreText.count), boundingBox: CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: self.frame.size.width, height: 50))))

        let attributedQuote = NSMutableAttributedString(string: updatedScoreText)
        let attributes = [.backgroundColor: UIColor.white, NSAttributedString.Key.font: UIFont.systemFont(ofSize: CGFloat(fontSize))]
               attributedQuote.addAttributes(attributes, range: NSRange(location: 0, length: updatedScoreText.count))

        attributedQuote.addAttributes(attributes, range: NSRange(location: 0, length: updatedScoreText.count))

        scoreLabelNode?.attributedText = attributedQuote

    }

    func shouldShowAttacker() -> Bool {
        let howManyUnits = GridHackUtils().howManyFriendlyAttackers()
        if howManyUnits >= Common.maxUnitAmount {
            return false
        }
         if gs.enemies?.count == 0 {
            return false
        }
        return true
    }
    func shouldShowBuilder() -> Bool {
        let howManyUnits = GridHackUtils().howManyFriendlyBuilders()
        if howManyUnits >= Common.maxUnitAmount {
            return false
        }
        print("builders: \(howManyUnits)")
        for xPoints in gs.points {
            for point in xPoints {
                if point == GridState.waitingForFriendlyConstruction {
                    return true
                }
            }
        }
        return false
    }
    func shouldShowHacker() -> Bool {
        let howManyUnits = GridHackUtils().howManyFriendlyHackers()
        if howManyUnits >= Common.maxUnitAmount {
            return false
        }
        for xPoints in gs.points {
            for point in xPoints {
                if point == GridState.enemyOwned {
                    return true
                }
            }
        }
        return false
    }

    func createAddAttackerButton() {
        attackerButton.name = "attacker"
        attackerButton.isUserInteractionEnabled = false
        let texture = SKTexture(imageNamed: Friendly().getAttackerTexture())
        attackerButton.texture = texture
        attackerButton.position = CGPoint(x: self.getXCoordinatesForUnitLables()[1], y: attackerY - 50)
        attackerButton.size = CGSize(width: 50, height: 50)
        attackerButton.isHidden=true
        self.addChild(attackerButton)

    }

    func createAddHackerButton() {
        hackerButton.name = "hacker"
        hackerButton.isUserInteractionEnabled = false
        let texture = SKTexture(imageNamed: Friendly().getHackerTexture())
        hackerButton.texture = texture
        hackerButton.position = CGPoint(x: self.getXCoordinatesForUnitLables()[2], y: hackerY - 50)
        hackerButton.size = CGSize(width: 50, height: 50)
        hackerButton.isHidden=true
        self.addChild(hackerButton)

    }
    func createAddBuilderButton() {
        builderButton.name = "builder"
        builderButton.isUserInteractionEnabled = false
        let texture = SKTexture(imageNamed: Friendly().getBuilderTexture())
        builderButton.texture = texture
        builderButton.position = CGPoint(x: self.getXCoordinatesForUnitLables()[0], y: builderY - 50)
        builderButton.size = CGSize(width: 50, height: 50)
        builderButton.isHidden=true
        self.addChild(builderButton)

    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override open func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) { let touch: UITouch = touches.first! as UITouch
        let positionInScene = touch.location(in: self)
        let touchedNode = self.atPoint(positionInScene)
        let appDelegate = UIApplication.shared.delegate as? AppDelegate

        if let name = touchedNode.name {
            if name == "attacker" {
                self.attackerButton.colorBlendFactor = 0.5
                self.attackerButton.color = UIColor.black
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.attackerButton.colorBlendFactor = 0.0
                }
                print("add attacker")

                FriendlyAttackerFactory.spawnAttacker(character: nil)

                if appDelegate!.isMultiplayer == false {
                    EnemyAttackerFactory.spawnEnemyAttacker(character: nil)
                } else {
                    appDelegate!.multiplayer.spawnedUnit(enemyType: "attacker")

                }
            } else if name == "builder" {
                self.builderButton.colorBlendFactor = 0.5
                self.builderButton.color = UIColor.black
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.builderButton.colorBlendFactor = 0.0
                }

                print("add builder")

                FriendlyBuilderFactory.spawnBuilder(character: nil)

                if appDelegate!.isMultiplayer == false {
                    EnemyBuilderFactory.spawnEnemyBuilder(character: nil)
                } else {
                    appDelegate!.multiplayer.spawnedUnit(enemyType: "builder")
                }
            } else if name == "hacker" {
                self.hackerButton.colorBlendFactor = 0.5
                self.hackerButton.color = UIColor.black
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.hackerButton.colorBlendFactor = 0.0
                }
                print("add enemy hacker")
                FriendlyHackerFactory.spawnHacker(character: nil)

                if appDelegate!.isMultiplayer == false {
                    EnemyHackerFactory.spawnHacker(character: nil)
                } else {
                    appDelegate!.multiplayer.spawnedUnit(enemyType: "hacker")
                }
            }

        }

    }

}
