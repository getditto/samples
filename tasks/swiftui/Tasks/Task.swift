//
//  Task.swift
//  Tasks
//
//  Created by Maximilian Alexander on 8/26/21.
//

import DittoSwift

struct Task {
    let _id: String
    let body: String
    let isCompleted: Bool
    let invitationIds: [String?]

    init(document: DittoDocument) {
        _id = document["_id"].stringValue
        body = document["body"].stringValue
        isCompleted = document["isCompleted"].boolValue
        invitationIds = document["invitationIds"].arrayValue as! [String]
    }

    init(body: String, isCompleted: Bool, invitationIds: [String]) {
        self._id = UUID().uuidString
        self.body = body
        self.isCompleted = isCompleted
        self.invitationIds = invitationIds
    }
}

extension Task: Identifiable {
    var id: String {
        return _id
    }
}
