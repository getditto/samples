import Combine
import DittoSwift
import Foundation

final class DittoManager {
    static var shared = DittoManager()
    let ditto: Ditto

    private init() {
        ditto = Ditto()
        try! ditto.setOfflineOnlyLicenseToken("YOUR_OFFLINE_PORTAL_TOKEN")
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
