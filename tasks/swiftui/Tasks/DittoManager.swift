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
        let transports = DittoTransportConfig()
    }
}
