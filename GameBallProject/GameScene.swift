import SpriteKit
import CoreMotion

struct PhysicsCategory {
    static let None: UInt32 = 0
    static let PinkBall: UInt32 = 0b1
    static let GreenBall: UInt32 = 0b10
    static let BlackHole: UInt32 = 0b100
    static let Border: UInt32 = 0b1000
}

class GameScene: SKScene {
    
    private var pinkBall: SKSpriteNode!
    private var greenBall: SKSpriteNode!
    private var blackHoles: [SKSpriteNode] = []
    private var borders: [SKSpriteNode] = []
    private var timerLabel: SKLabelNode!
    private var levelLabel: SKLabelNode!
    private var timerOutline: SKLabelNode!
    private var levelOutline: SKLabelNode!
    private var timer: Timer?
    private var myScore = 0
    private var score = 200
    private var currentLevel = 1
    private var timeRemaining = 120
    private var scoreDisplayed = false
    private var isTransitioning = false
    private var isBallDisappearing = false

    
    private let motionManager = CMMotionManager()
    private var initialPosition: CGPoint = .zero

    override func didMove(to view: SKView) {
        
        physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        
        pinkBall = childNode(withName: "pinkBall") as? SKSpriteNode
        greenBall = childNode(withName: "greenBall") as? SKSpriteNode
        setupLabels()

        if let pinkBall = pinkBall {
            initialPosition = pinkBall.position
            pinkBall.physicsBody?.affectedByGravity = false
            pinkBall.physicsBody = SKPhysicsBody(circleOfRadius: pinkBall.size.width / 2)
            pinkBall.physicsBody?.isDynamic = true
            pinkBall.physicsBody = nil
            pinkBall.physicsBody?.categoryBitMask = PhysicsCategory.PinkBall
            pinkBall.physicsBody?.collisionBitMask = PhysicsCategory.Border | PhysicsCategory.BlackHole
            pinkBall.physicsBody?.contactTestBitMask = PhysicsCategory.Border | PhysicsCategory.BlackHole
        }

        for node in self.children {
            if node.name?.starts(with: "border") == true, let border = node as? SKSpriteNode {
                let path = UIBezierPath(roundedRect: CGRect(origin: CGPoint.zero, size: border.size), cornerRadius: 7)
                border.physicsBody = SKPhysicsBody(edgeLoopFrom: path.cgPath)
                border.physicsBody?.affectedByGravity = false
                border.physicsBody = nil
                border.physicsBody?.isDynamic = false
                border.physicsBody?.categoryBitMask = PhysicsCategory.Border
                border.physicsBody?.collisionBitMask = PhysicsCategory.PinkBall
                borders.append(border)
            }
        }

        for node in self.children {
            if node.name?.contains("blackHole") == true {
                if let blackHole = node as? SKSpriteNode {
                    blackHoles.append(blackHole)
                }
            }
        }

        startAccelerometerUpdates()
        startTimer()
    }
        
        private func setupLabels() {
            
            timerOutline = SKLabelNode(fontNamed: "tacone-regular")
            timerOutline.fontSize = 64
            timerOutline.position = CGPoint(x: frame.midX - 100, y: frame.maxY - 47)
            timerOutline.zPosition = 9
            timerOutline.fontColor = UIColor(red: 39/255, green: 0, blue: 194/255, alpha: 1)
            addChild(timerOutline)
            
            timerLabel = SKLabelNode(fontNamed: "tacone-regular")
            timerLabel.fontSize = 60
            timerLabel.position = timerOutline.position
            timerLabel.fontColor = .white
            timerLabel.zPosition = 10
            addChild(timerLabel)

            levelOutline = SKLabelNode(fontNamed: "tacone-regular")
            levelOutline.fontSize = 62
            levelOutline.position = CGPoint(x: frame.midX + 100, y: frame.maxY - 47)
            levelOutline.zPosition = 9
            levelOutline.fontColor = UIColor(red: 39/255, green: 0, blue: 194/255, alpha: 1)
            addChild(levelOutline)
            
            levelLabel = SKLabelNode(fontNamed: "tacone-regular")
            levelLabel.fontSize = 60
            levelLabel.position = levelOutline.position
            levelLabel.fontColor = .white
            levelLabel.zPosition = 10
            addChild(levelLabel)

            updateLevelLabel()
        }

    private func updateLevelLabel() {
        let sceneName = self.name ?? "GameScene"
        let levelNumber: String
        if sceneName == "GameScene" {
            levelNumber = "LEVEL 1"
        } else if sceneName.hasPrefix("Level") {
            let levelSuffix = sceneName.dropFirst("Level".count)
            levelNumber = "LEVEL \(levelSuffix)"
        } else {
            levelNumber = "LEVEL 1"
        }
        
        levelLabel.text = levelNumber
        levelOutline.text = levelNumber
    }

       
    func loadNextLevel() {
        guard !isTransitioning else { return }
        isTransitioning = true
        addScore(points: score)
        score = 200

        let nextLevelName: String
        switch currentLevel {
        case 1:
            nextLevelName = "Level2"
            currentLevel = 2
        case 2:
            nextLevelName = "Level3"
            currentLevel = 3
        case 3:
            nextLevelName = "Level4"
            currentLevel = 4
        case 4:
            nextLevelName = "Level5"
            currentLevel = 5
        case 5:
            nextLevelName = "Level6"
            currentLevel = 6
        case 6:
            nextLevelName = "Level7"
            currentLevel = 7
        case 7:
            nextLevelName = "Level8"
            currentLevel = 8
        case 8:
            nextLevelName = "Level9"
            currentLevel = 9
        case 9:
            nextLevelName = "Level10"
            currentLevel = 10
        case 10:
            isTransitioning = false
            return
        default:
            isTransitioning = false
            return
        }

        let updateLevelAction = SKAction.run {
            self.updateLevelLabel()
        }

        let wait = SKAction.wait(forDuration: 2.0)

        let loadSceneAction = SKAction.run { [weak self] in
            guard let self = self else { return }
            if let nextScene = SKScene(fileNamed: nextLevelName) {
                nextScene.scaleMode = .aspectFill
                if let gameScene = nextScene as? GameScene {
                    gameScene.currentLevel = self.currentLevel
                }
                self.view?.presentScene(nextScene, transition: .fade(withDuration: 0.2))
            } else {
            }
            self.isTransitioning = false
        }

        let sequence = SKAction.sequence([updateLevelAction, wait, loadSceneAction])
        run(sequence)
    }



        private func startTimer() {
            timeRemaining = 120
            timerLabel.text = formatTime(timeRemaining)
            timerOutline.text = timerLabel.text
            timer?.invalidate()
            
            timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
                guard let self = self else { return }
                self.timeRemaining -= 1
                self.timerLabel.text = self.formatTime(self.timeRemaining)
                self.timerOutline.text = self.timerLabel.text
                
                if self.timeRemaining <= 0 {
                    self.timer?.invalidate()
                    self.reduceMaxScore()
                    self.resetGame()
                    self.startTimer()
                }
            }
        }
    
    private func reduceMaxScore() {
        if score > 0{
            score -= 10
        }
        else { score = 0 }
       }
    
        private func formatTime(_ time: Int) -> String {
            let minutes = time / 60
            let seconds = time % 60
            return "\(minutes)\n:\n\(String(format: "%02d", seconds))"
        }
    
    private func addScore(points: Int) {
        myScore += points
        if !scoreDisplayed {
            scoreDisplayed = true
            showScoreAnimation()
        }
    }

    
    private func showScoreAnimation() {
        
        let scoreLabel2 = SKLabelNode(text: "+\(score)")
        scoreLabel2.fontName = "tacone-regular"
        scoreLabel2.fontSize = 147
        scoreLabel2.fontColor = UIColor(red: 39/255, green: 0, blue: 194/255, alpha: 1)
        scoreLabel2.position = CGPoint(x: frame.midX + 100, y: frame.midY)
        scoreLabel2.zPosition = 9
        addChild(scoreLabel2)
        
        let scoreLabel = SKLabelNode(text: "+\(score)")
        scoreLabel.fontName = "tacone-regular"
        scoreLabel.fontSize = 140
        scoreLabel.position = CGPoint(x: frame.midX + 100, y: frame.midY)
        scoreLabel.zPosition = 10
        addChild(scoreLabel)
       
        
        let moveAction = SKAction.moveBy(x: 0, y: 50, duration: 1.3)
        let fadeOutAction = SKAction.fadeOut(withDuration: 1.3)
        let removeAction = SKAction.removeFromParent()
        
        scoreLabel.run(SKAction.sequence([moveAction, fadeOutAction, removeAction]))
        scoreLabel2.run(SKAction.sequence([moveAction, fadeOutAction, removeAction]))
    }
}

extension GameScene {
    func startAccelerometerUpdates() {
        guard motionManager.isAccelerometerAvailable else { return }
        
        motionManager.accelerometerUpdateInterval = 0.02
        motionManager.startAccelerometerUpdates(to: .main) { [weak self] (data, error) in
            guard let self = self, let data = data else { return }
            
            let dx = CGFloat(data.acceleration.x) * 10
            let dy = CGFloat(data.acceleration.y) * -10
            
            self.pinkBall.position.x += dy
            self.pinkBall.position.y += dx
            
            self.checkCollisions()
            self.restrictBallWithinBoundaries()
        }
    }
    
    private func restrictBallWithinBoundaries() {
        guard let pinkBall = pinkBall else { return }
        let ballFrame = pinkBall.frame
        
        for border in borders {
            let borderFrame = border.frame
            
            if ballFrame.intersects(borderFrame) {
                if ballFrame.maxX > borderFrame.minX && ballFrame.minX < borderFrame.minX {
                    pinkBall.position.x = borderFrame.minX - pinkBall.size.width / 2
                } else if ballFrame.minX < borderFrame.maxX && ballFrame.maxX > borderFrame.maxX {
                    pinkBall.position.x = borderFrame.maxX + pinkBall.size.width / 2
                } else if ballFrame.maxY > borderFrame.minY && ballFrame.minY < borderFrame.minY {
                    pinkBall.position.y = borderFrame.minY - pinkBall.size.height / 2
                } else if ballFrame.minY < borderFrame.maxY && ballFrame.maxY > borderFrame.maxY {
                    pinkBall.position.y = borderFrame.maxY + pinkBall.size.height / 2
                }
            }
        }
    }
}


extension GameScene {
    func checkCollisions() {
        guard let pinkBall = pinkBall, !isBallDisappearing else { return }
        
        for blackHole in blackHoles {
            let insetFrame = blackHole.frame.insetBy(dx: 0.1, dy: 0.1)
            if insetFrame.contains(pinkBall.position) {
                isBallDisappearing = true
                animatePinkBallDisappearing {
                    self.reduceMaxScore()
                    self.resetGame()
                    self.isBallDisappearing = false 
                    self.startTimer()
                }
                return
            }
        }
        
        if pinkBall.intersects(greenBall) {
            animatePinkBallDisappearing {
                self.loadNextLevel()
            }
        }
    }

    
    private func animatePinkBallDisappearing(completion: @escaping () -> Void) {
        let fadeOut = SKAction.fadeOut(withDuration: 0.3)
        let wait = SKAction.wait(forDuration: 0.3)
        let fadeIn = SKAction.fadeIn(withDuration: 0.3)
        
        let sequence = SKAction.sequence([fadeOut, wait, fadeIn])
        pinkBall.run(sequence) {
            completion()
        }
    }
    
    private func resetGame() {
        pinkBall.position = initialPosition
           pinkBall.alpha = 1.0
           timeRemaining = 120
           timerLabel.text = formatTime(timeRemaining)
           timerOutline.text = timerLabel.text
    }
}

