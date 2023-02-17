//
//  Flight.swift
//  SwitchToLatestExample
//
//  Created by Maximilian Alexander on 8/10/22.
//

import Foundation
import DittoSwift

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

extension Flight {
    init(document: DittoDocument) {
        self._id = document["_id"].intValue
        self.from = document["from"].stringValue
        self.to = document["to"].stringValue
        self.number = document["number"].intValue
        self.carrier = document["carrier"].stringValue
    }
}
