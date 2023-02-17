//
//  Flight.swift
//  SwitchToLatestExample
//
//  Created by Maximilian Alexander on 8/10/22.
//

import Foundation

struct Flight: Codable {
    var _id: Int
    var from: String
    var to: String
    var number: Int
    var carrier: String
}

extension Flight: Identifiable, Hashable, Equatable {
    var id: Int {
        return _id
    }
}
