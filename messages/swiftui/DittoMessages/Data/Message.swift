//
//  Message.swift
//  DittoMessages
//
//  Created by Maximilian Alexander on 7/19/22.
//

import Foundation

struct Message: Identifiable, Equatable, Hashable {
    var id: String
    var text: String
    var createdOn: Date
    var userId: String
    var roomId: String
}

