//
//  UserDefaults+Extensions.swift
//  Todo
//
//  Created by Maximilian Alexander on 9/7/18.
//  Copyright © 2018 DittoLive. All rights reserved.
//

import Foundation

extension UserDefaults {
    
    var name: String! {
        get {
            return self.string(forKey: "_name")
        } set(val) {
            self.set(val, forKey: "_name")
        }
    }
    var siteId: UInt32 {
        get {
            return UInt32(self.integer(forKey: "_siteId"))
        } set(val) {
            self.set(val, forKey: "_siteId")
        }
    }
}
