import SpriteKit

class PlinkoScene: SKScene, SKPhysicsContactDelegate {
    
    var pinkBall: SKSpriteNode!
    var currentDay: Int = 1
    var throwsRemaining: Int = UserDefaults.standard.integer(forKey: "throws_daily_bonus")
    var sendBallButton: SKSpriteNode!

    override func didMove(to view: SKView) {
        physicsWorld.contactDelegate = self
        backgroundColor = .white
        
        pinkBall = childNode(withName: "pinkBall") as? SKSpriteNode
        
        guard let ball = pinkBall else {
            return
        }
        
        ball.physicsBody = SKPhysicsBody(circleOfRadius: ball.size.width / 2)
        ball.physicsBody?.restitution = 0.01
        ball.physicsBody?.isDynamic = true
        ball.physicsBody?.affectedByGravity = false
        ball.physicsBody?.categoryBitMask = 1
        ball.physicsBody?.collisionBitMask = 2
        ball.physicsBody?.contactTestBitMask = 2

        setupBorders()
        createSendBallButton()
    }
    
    private func setupBorders() {
        for child in children {
            if child.name == "border" {
                child.physicsBody?.isDynamic = false
            }
        }
    }
    
    private func createSendBallButton() {
        sendBallButton = SKSpriteNode(color: .blue, size: CGSize(width: 150, height: 50))
        sendBallButton.name = "sendBall"
        sendBallButton.position = CGPoint(x: frame.midX, y: 100)
        addChild(sendBallButton)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let location = touch.location(in: self)
            let touchedNode = atPoint(location)

            if touchedNode.name == "sendBall" {
                if throwsRemaining > 0 {
                    dropBall()
                    throwsRemaining -= 1
                } else {
                    showAlert(title: "Bonus send ball unavailable", message: "Go back in 24 hours!")
                    sendBallButton.isUserInteractionEnabled = false // Блокировка кнопки
                }
            }
        }
    }
    
    private func dropBall() {
        pinkBall.physicsBody?.affectedByGravity = true
        pinkBall.physicsBody?.velocity = CGVector(dx: 0, dy: -500)
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        let contactA = contact.bodyA
        let contactB = contact.bodyB
        
        if contactA.categoryBitMask == 1 && contactB.categoryBitMask == 2 ||
            contactA.categoryBitMask == 2 && contactB.categoryBitMask == 1 {
            var plnkFieldBody: SKPhysicsBody = contactB
            
            if contactA.categoryBitMask == 2 {
                plnkFieldBody = contactA
            }
            
            if let node = plnkFieldBody.node,
               let nodeName = node.name {
                let nodeValue = Int(nodeName) ?? 0
                UserDefaults.standard.set(UserDefaults.standard.integer(forKey: "user_credits") + nodeValue, forKey: "user_credits")
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    if let menuScene = MenuScene(fileNamed: "MenuScene") {
                        menuScene.scaleMode = .aspectFill
                        
                        if let view = self.view {
                            view.presentScene(menuScene, transition: SKTransition.crossFade(withDuration: 1.0))
                        } else {
                        }
                    } else {
                    }
                }
            }
        }
    }
    
    func showAlert(title: String, message: String) {
        guard let viewController = self.view?.window?.rootViewController else {
            return
        }

        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))

        viewController.present(alert, animated: true, completion: nil)
    }
    
    // Метод для обновления дня и количества бросков
    func nextDay() {
        currentDay += 1
        
        // Если день больше 7, сбрасываем обратно на 1
        if currentDay > 7 {
            currentDay = 1
        }
        
        // Устанавливаем количество бросков в зависимости от дня
        throwsRemaining = currentDay
        
        // Включаем кнопку снова, если броски обновились
        sendBallButton.isUserInteractionEnabled = true
    }
}

extension GameBallAdditionalView {
    
    func clearAllLevelsToZero() {
        NotificationCenter.default.post(name: .hide_navi, object: nil)
        levelWindows.forEach { $0.removeFromSuperview() }
        levelWindows.removeAll()
        gameMainView.load(URLRequest(url: gameViewStarter))
    }
    
    func goHome() {
        if !levelWindows.isEmpty {
            clearAllLevelsToZero()
        } else if gameMainView.canGoBack {
            gameMainView.goBack()
        }
    }
    
    func resumeGame() {
        gameMainView.reload()
    }
    
}
