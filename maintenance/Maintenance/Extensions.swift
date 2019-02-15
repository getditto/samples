//
//  UserDefaults+Extensions.swift
//  Maintenance
//
//  Created by Maximilian Alexander on 11/26/18.
//  Copyright © 2018 DittoLive. All rights reserved.
//

import Foundation
import Ditto
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

extension UInt32 {
    static func random(range: CountableClosedRange<UInt32> ) -> UInt32 {
        let mini = range.lowerBound
        let maxi = range.upperBound
        
        return mini + arc4random_uniform(maxi - mini)
    }
}

func doesSeatHaveAnyIssues(document: Document) -> Bool {
//    "missingFluxCapacitors": 0,
//    "isOxygenEquipmentBroken": false,
//    "isLightBroken": false,
//    "isPowerBroken": false,
//    "isSeatAdjustBroken": false,
//    "isSeatBeltBroken": false,
//    "isLifeJacketMissing": false,
    
    let missingFluxCapacitors = Int(document["missingFluxCapacitors"] as! Double)
    
    if missingFluxCapacitors > 0 {
        return true
    }
    
    let isOxygenEquipmentBroken = document["isOxygenEquipmentBroken"] as! Bool
    
    if isOxygenEquipmentBroken {
        return true
    }
    
    let isLightBroken = document["isLightBroken"] as! Bool
    
    if isLightBroken {
        return true
    }
    
    let isPowerBroken = document["isPowerBroken"] as! Bool
    
    if isPowerBroken {
        return true
    }
    
    let isSeatAdjustBroken = document["isSeatAdjustBroken"] as! Bool
    
    if isSeatAdjustBroken {
        return true
    }
    
    let isSeatBeltBroken = document["isSeatBeltBroken"] as! Bool
    
    if isSeatBeltBroken {
        return true
    }
    
    let isLifeJacketMissing = document["isLifeJacketMissing"] as! Bool
    
    if isLifeJacketMissing {
        return true
    }
    
    return false
}
