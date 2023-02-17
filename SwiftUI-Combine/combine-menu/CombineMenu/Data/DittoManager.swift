//
//  DittoManager.swift
//  CombineMenu
//
//  Created by Maximilian Alexander on 3/3/22.
//

import Foundation
import DittoSwift

class DittoManager {
    static var shared = DittoManager()
    let ditto: Ditto

    init() {
        ditto = Ditto()
    }
}
