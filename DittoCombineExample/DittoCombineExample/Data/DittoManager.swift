import Combine
import DittoSwift
import Foundation

final class DittoManager {
    static var shared = DittoManager()
    let ditto: Ditto

    private init() {
        ditto = Ditto()
//        try! ditto.setOfflineOnlyLicenseToken("YOUR_OFFLINE_PORTAL_TOKEN")
        try! ditto.setOfflineOnlyLicenseToken(
            "o2d1c2VyX2lkdTExODE0NDU2ODIwNjc3NjI1MjAxN2ZleHBpcnl4GDIwMjMtMDEtMTVUMjA6MjM6MDAuMzg0WmlzaWduYXR1cmV4WGt5REdkbkhid3RqWjl1Nk5uTllhM1g1K1ZMc2ZWU1RTOUR5Q1p4TlVYUXhWRzM1RENWWHJBWWd0N3NUTEZVbmtmWEJsMXhoL1JOeWRZZXVZeEV0L1NnPT0="
        )
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
