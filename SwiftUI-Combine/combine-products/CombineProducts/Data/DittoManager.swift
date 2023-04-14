import Combine
import DittoSwift
import Foundation

final class DittoManager {
    static var shared = DittoManager()
    let ditto: Ditto

    private init() {
        self.ditto = Ditto(
            // 1. Create an app in your Ditto Portal
            // 2. Initialize identity with AppID and Online Playground Authentication Token
            identity: .onlinePlayground(
                appID: "YOUR_PORTAL_APP_ID",
                token: "YOUR_PORTAL_PLAYGROUND_TOKEN"
            )
        )

        do {
          try ditto.startSync()
        } catch {
          print(error.localizedDescription)
        }
    }
    
    func startSync() {
        let isPreview: Bool = ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
        if !isPreview {
            var transportConfig = DittoTransportConfig()
            transportConfig.enableAllPeerToPeer()
            ditto.transportConfig = transportConfig
            try! ditto.startSync()
        }
    }
}
