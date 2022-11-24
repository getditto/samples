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
    
    static var shared = DittoManager()
    
    init() {
        self.ditto = Ditto(identity: .onlinePlayground(appID: "b11a1267-8d3c-4a24-bd98-3772fe28d298", token: "c13f160a-606d-435b-85eb-c716b6aa76d3"))
        
        //try! ditto.setOfflineOnlyLicenseToken("o2d1c2VyX2lkbnJhZUBkaXR0by5saXZlZmV4cGlyeXgYMjAyMi0xMi0yNFQwNzo1OTo1OS45OTlaaXNpZ25hdHVyZXhYMnJMQmZkZjZnVnZOTGFKSmpRQmcyYmNFRUR2WUswa0pHQlNFTmJOUFhuR1lFcHFyMkJzSHZteFlaQmRZRTExUEdBc2FZS2h0TTh2Qm9KaWNEVjF4Z3c9PQ==")
    }
    
    
}
