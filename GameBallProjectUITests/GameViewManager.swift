import Foundation
import SpriteKit
import SwiftUI

class GameViewManager: ObservableObject {
    static let shared = GameViewManager()
    @Published var currentScene: SKScene?

    private init() {}

    func showGameScene() {
        let scene = GameScene(size: CGSize(width: 750, height: 1334))
        scene.scaleMode = .aspectFill
        self.currentScene = scene
    }

    func showPlinkoScene() {
        let scene = PlinkoScene(size: CGSize(width: 750, height: 1334))
        scene.scaleMode = .aspectFill
        self.currentScene = scene
    }
}

