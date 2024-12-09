import SpriteKit

class LoadingScene: SKScene {
    private var loadingBar: SKSpriteNode!
    private var loadingLabel: SKLabelNode!

    override func didMove(to view: SKView) {
        loadingBar = SKSpriteNode(color: .systemPink, size: CGSize(width: 0, height: 30))
        loadingBar.position = CGPoint(x: frame.midX, y: frame.midY)
        addChild(loadingBar)

    
        startLoadingAnimation()
        
        isUserInteractionEnabled = true
    }

    private func startLoadingAnimation() {
        let loadingDuration: TimeInterval = 10.0

        loadingBar.run(SKAction.resize(toWidth: frame.width * 0.8, duration: loadingDuration))
        
        run(SKAction.wait(forDuration: loadingDuration)) {
            // self.presentMenuScene()
        }
    }

    private func presentMenuScene() {
        if let menuScene = MenuScene(fileNamed: "MenuScene") {
            menuScene.scaleMode = .aspectFill
            
            if let view = self.view {
                view.presentScene(menuScene, transition: SKTransition.crossFade(withDuration: 1.0))
            } else {
            }
        } else {
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        presentMenuScene()
    }
}

