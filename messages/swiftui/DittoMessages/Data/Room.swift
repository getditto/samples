//
//  Room.swift
//  DittoMessages
//
//  Created by Maximilian Alexander on 7/20/22.
//

import Foundation
import DittoSwift

struct Room: Identifiable, Hashable, Equatable {
    var id: String
    var name: String
    var createdOn: Date
}

extension Room {
    init(document: DittoDocument) {
        self.id = document["_id"].stringValue
        self.name = document["name"].stringValue
        self.createdOn = ISO8601DateFormatter().date(from: document["createdOn"].stringValue)!
    }
}
