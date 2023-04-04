import Combine
import DittoSwift
import Foundation

final class DittoManager {
    static var shared = DittoManager()
    let ditto: Ditto

    private init() {
        self.ditto = Ditto(
            // Create a test app in your Ditto Portal for AppID and
            // Online Playground Authentication Token
            identity: .onlinePlayground(
                appID: "REPLACE_ME_WITH_YOUR_APP_ID",
                token: "REPLACE_ME_WITH_YOUR_PLAYGROUND_TOKEN",
                // Disable syncing with the cloud here to demo offline features
                enableDittoCloudSync: false)
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
