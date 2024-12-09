import SwiftUI
import WebKit

struct GameBallView: View {
    
    @State var visibilityOfCoordinations = false
    @State var visibilityOfCoor = false
    private var publisherForShow = NotificationCenter.default.publisher(for: .show_navi)
    @State var dnsjadn = false
    private var publisherForHide = NotificationCenter.default.publisher(for: .hide_navi)
    
    var body: some View {
        VStack {
            GameBallAdditionalView(gameViewStarter: URL(string: UserDefaults.standard.string(forKey: "state_game_addi") ?? "")!)
            if visibilityOfCoordinations {
                ZStack {
                    Color.black
                    HStack {
                        Button {
                            func dnasjkdnasjkndsa(_ name: Notification.Name) {
                                NotificationCenter.default.post(name: name, object: nil)
                            }
                            dnasjkdnasjkndsa(.backTo_home)
                        } label: {
                            Image(systemName: "arrow.left")
                                .resizable()
                                .frame(width: 25, height: 25)
                                .foregroundColor(.blue)
                        }
                        Spacer()
                        
                        Button {
                            func dsjandjksandsa(_ name: Notification.Name) {
                                NotificationCenter.default.post(name: name, object: nil)
                            }
                            dsjandjksandsa(.loadGame_resume)
                        } label: {
                            Image(systemName: "arrow.clockwise")
                                .resizable()
                                .frame(width: 25, height: 25)
                                .foregroundColor(.blue)
                        }
                    }
                    
                    .padding(5)
                }
                .frame(height: 61)
            }
            
        }
        .edgesIgnoringSafeArea([.trailing,.leading])
        .onReceive(publisherForShow, perform: { _ in
            withAnimation(.linear(duration: 0.4)) { visibilityOfCoordinations = true }
        })
        .onReceive(publisherForHide, perform: { _ in
            withAnimation(.linear(duration: 0.4)) { visibilityOfCoordinations = false }
        })
        .preferredColorScheme(.dark)
    }
}

#Preview {
    GameBallView()
}

extension Notification.Name {
    static let bdashjbdsajbdjaskndasd = Notification.Name("ndsjandads")
    static let hide_navi = Notification.Name("hide_navi")
    static let show_navi = Notification.Name("show_navi")
    static let backTo_home = Notification.Name("back_to_home")
    static let loadGame_resume = Notification.Name("load_game_resume")
}

struct GameBallAdditionalView: UIViewRepresentable {
    
    let gameViewStarter: URL
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        uiView.load(URLRequest(url: gameViewStarter))
    }
    
    @State var gameMainView: WKWebView = WKWebView()
    
    
    func makeUIView(context: Context) -> WKWebView {
        let hdfsajkdhnkjsad = WKWebpagePreferences()
        let dnsajkdnsajkdsad = WKWebViewConfiguration()
        let dnsajkdnasd = WKPreferences()
        dnsajkdnsajkdsad.allowsInlineMediaPlayback = true
        dnsajkdnsajkdsad.defaultWebpagePreferences = hdfsajkdhnkjsad
        hdfsajkdhnkjsad.allowsContentJavaScript = true
        dnsajkdnasd.javaScriptCanOpenWindowsAutomatically = true
        dnsajkdnsajkdsad.requiresUserActionForMediaPlayback = false
        dnsajkdnsajkdsad.preferences = dnsajkdnasd
        
        
        
        gameMainView = WKWebView(frame: .zero, configuration: dnsajkdnsajkdsad)
        gameMainView.uiDelegate = context.coordinator
        
        
        gameMainView.allowsBackForwardNavigationGestures = true
        gameMainView.navigationDelegate = context.coordinator
        return gameMainView
    }
    
    @State var levelWindows: [WKWebView] = []
    
    func makeCoordinator() -> GameViewBallAddiCoordinator {
        GameViewBallAddiCoordinator(vParent: self)
    }
    
}

