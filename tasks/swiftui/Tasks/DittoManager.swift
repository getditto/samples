//
//  DittoManager.swift
//  Tasks
//
//  Created by Rae McKelvey on 11/23/22.
//

import Foundation
import DittoSwift


class DittoManager {
    
    var ditto: Ditto
    var obs: DittoSwift.DittoObserver
    
    static var shared = DittoManager()
    
//    // dev https://portal-dev.ditto.live/app/jonathans-dev-app/devices
//    static let baseURL = "084735c7-3c1c-4018-b22c-9365e5e916c9.cloud-dev.ditto.live"
//    static let authURL = "https://\(baseURL)"
//    static let appID = "084735c7-3c1c-4018-b22c-9365e5e916c9"
//    static let token = "0c506e20-2550-4ec6-8032-39ee654b6a97"
    
    // local http://localhost:3000/local-org/testing-devices
    static let baseURL = "subscriptions-jonathan-ditto.dev.k8s.ditto.live"
    static let authURL = "https://\(baseURL)/0c12e43c-3d4b-442f-8cae-422b7b373028"
    static let appID = "0c12e43c-3d4b-442f-8cae-422b7b373028"
    static let token = "536d77e4-6909-4e9d-9cda-f87758fae640"
    
    init() {
        self.ditto = Ditto(
            identity: .onlinePlayground(
                appID: Self.appID,
                token: Self.token,
                enableDittoCloudSync: false,
                customAuthURL: URL(string: Self.authURL)
            )
        )
        self.ditto.transportConfig.connect.webSocketURLs.insert("wss://\(Self.baseURL)")
        self.ditto.smallPeerInfo.isEnabled = true
        self.ditto.smallPeerInfo.syncScope = .bigPeerOnly
        DittoLogger.minimumLogLevel = .debug
        dump(DittoLogger.minimumLogLevel, name: "minimumLogLevel")
        dump(ditto.smallPeerInfo.isEnabled, name: "SPI enabled")
        dump(ditto.smallPeerInfo.syncScope, name: "SPI syncScope")
        
        self.obs = self.ditto.presence.observe(didChangeHandler: { DittoPresenceGraph in
            print(DittoPresenceGraph.localPeer.peerKey.base64EncodedString())
        })
        
        //try! ditto.setOfflineOnlyLicenseToken("o2d1c2VyX2lkbnJhZUBkaXR0by5saXZlZmV4cGlyeXgYMjAyMi0xMi0yNFQwNzo1OTo1OS45OTlaaXNpZ25hdHVyZXhYMnJMQmZkZjZnVnZOTGFKSmpRQmcyYmNFRUR2WUswa0pHQlNFTmJOUFhuR1lFcHFyMkJzSHZteFlaQmRZRTExUEdBc2FZS2h0TTh2Qm9KaWNEVjF4Z3c9PQ==")
    }
    
    
}
