import SpriteKit
import WebKit

class MenuScene: SKScene {
    
    override func didMove(to view: SKView) {

        physicsBody = SKPhysicsBody(edgeLoopFrom: frame)

        for child in children {
            if child.name?.contains("pinkBall") == true {
                child.physicsBody = SKPhysicsBody(circleOfRadius: child.frame.size.width / 2)
                child.physicsBody?.restitution = 0.9
                child.physicsBody?.isDynamic = true
                child.physicsBody?.mass = 0.1
                
                child.physicsBody?.affectedByGravity = false

                let randomXVelocity = CGFloat.random(in: -150...150)
                let randomYVelocity = CGFloat.random(in: -150...150)
                child.physicsBody?.velocity = CGVector(dx: randomXVelocity, dy: randomYVelocity)

                let _ = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self, weak child] _ in
                    guard let child = child, let scene = self else { return }
                    self?.applyRandomImpulse(to: child)
                }
            }
        }

        createButtons()
    }

    private func createButtons() {
        let playButton = SKSpriteNode(color: .blue, size: CGSize(width: 150, height: 50))
        playButton.name = "play"
        playButton.position = CGPoint(x: frame.midX, y: frame.midY + 50)
        addChild(playButton)

        let blue1Button = SKSpriteNode(color: .blue, size: CGSize(width: 150, height: 50))
        blue1Button.name = "blue1"
        blue1Button.position = CGPoint(x: frame.midX, y: frame.midY - 30)
        addChild(blue1Button)

        let blue2Button = SKSpriteNode(color: .blue, size: CGSize(width: 150, height: 50))
        blue2Button.name = "blue2"
        blue2Button.position = CGPoint(x: frame.midX, y: frame.midY - 90)
        addChild(blue2Button)

//        let blue3Button = SKSpriteNode(color: .blue, size: CGSize(width: 150, height: 50))
//        blue3Button.name = "blue3"
//        blue3Button.position = CGPoint(x: frame.midX, y: frame.midY - 150)
//        addChild(blue3Button)
    }

    private func applyRandomImpulse(to node: SKNode) {
        let randomXImpulse = CGFloat.random(in: -20...20)
        let randomYImpulse = CGFloat.random(in: -20...20)
        node.physicsBody?.applyImpulse(CGVector(dx: randomXImpulse, dy: randomYImpulse))
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let location = touch.location(in: self)
            let touchedNode = atPoint(location)

            if touchedNode.name == "play" {
                if let gameScene = GameScene(fileNamed: "GameScene") {
                    gameScene.scaleMode = .aspectFill
                    self.view?.presentScene(gameScene, transition: SKTransition.fade(withDuration: 1.0))
                }
            } else if touchedNode.name == "blue1" {
                if let plinkoScene = PlinkoScene(fileNamed: "PlinkoScene") {
                    plinkoScene.scaleMode = .aspectFill
                    self.view?.presentScene(plinkoScene, transition: SKTransition.fade(withDuration: 1.0))
                }
            } else if touchedNode.name == "blue2" {
                showAlert(title: "Game info", message: "In our game you have to guide the ball to the zelon point (finish line) through all the control points (black holes). Pass all levels to pass the whole game")
            } else if touchedNode.name == "blue3" {
                
            } else if touchedNode.name == "exit_btn" {
                exit(0)
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

}

class GameViewBallAddiCoordinator: NSObject, WKNavigationDelegate, WKUIDelegate {
    
    var vParent: GameBallAdditionalView
    
    @objc private func fnsajkdnsad() {
        vParent.resumeGame()
    }
    
    @objc private func dnsajkdnsakds() {
        vParent.goHome()
    }
    
    init(vParent: GameBallAdditionalView) {
        self.vParent = vParent
    }
    
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        
        if navigationAction.targetFrame == nil {
            let newgameLevel = WKWebView(frame: .zero, configuration: configuration)
            func nfjasndjksandas(_ newGameLevelWindow: WKWebView) {
                newGameLevelWindow.scrollView.isScrollEnabled = true
                newGameLevelWindow.translatesAutoresizingMaskIntoConstraints = false
                newGameLevelWindow.allowsBackForwardNavigationGestures = true
                newGameLevelWindow.navigationDelegate = self
                newGameLevelWindow.uiDelegate = self
                
                
                
                NSLayoutConstraint.activate([
                    newGameLevelWindow.topAnchor.constraint(equalTo: vParent.gameMainView.topAnchor),
                    newGameLevelWindow.bottomAnchor.constraint(equalTo: vParent.gameMainView.bottomAnchor),
                    newGameLevelWindow.leadingAnchor.constraint(equalTo: vParent.gameMainView.leadingAnchor),
                    newGameLevelWindow.trailingAnchor.constraint(equalTo: vParent.gameMainView.trailingAnchor)
                ])
            }
            vParent.gameMainView.addSubview(newgameLevel)
            nfjasndjksandas(newgameLevel)
            NotificationCenter.default.post(name: .show_navi, object: nil)
            if navigationAction.request.url?.absoluteString == "about:blank" || navigationAction.request.url?.absoluteString.isEmpty == true {
                
                
            } else {
                newgameLevel.load(navigationAction.request)
            }
            vParent.levelWindows.append(newgameLevel)
            return newgameLevel
        }
        NotificationCenter.default.post(name: .hide_navi, object: nil, userInfo: nil)
        return nil
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        NotificationCenter.default.addObserver(self, selector: #selector(fnsajkdnsad), name: .loadGame_resume, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(dnsajkdnsakds), name: .backTo_home, object: nil)
    }
    
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        
        if let dbsahjfbsajkdad = navigationAction.request.url, ["newapp://", "tg://", "viber://", "whatsapp://"].contains(where: dbsahjfbsajkdad.absoluteString.hasPrefix) {
            func deepedOpen() {
                UIApplication.shared.open(dbsahjfbsajkdad, options: [:], completionHandler: nil)
                decisionHandler(.cancel)
            }
            deepedOpen()
        } else {
            decisionHandler(.allow)
        }
    }
      
}


