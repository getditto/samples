//
//  UInt32+Extensions.swift
//  Todo
//
//  Created by Maximilian Alexander on 9/7/18.
//  Copyright © 2018 DittoLive. All rights reserved.
//

import Foundation

extension UInt32 {
    static func random(range: CountableClosedRange<UInt32> ) -> UInt32 {
        let mini = range.lowerBound
        let maxi = range.upperBound
        
        return mini + arc4random_uniform(maxi - mini)
    }
}
