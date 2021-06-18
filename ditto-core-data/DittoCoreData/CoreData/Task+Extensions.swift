//
//  Task+Extensions.swift
//  DittoCoreData
//
//  Created by Maximilian Alexander on 6/18/21.
//

import Foundation
import DittoSwift

extension Task {

    func isSameValue(as dittoDocument: DittoDocument) -> Bool {
        return
            self.id == dittoDocument.id.toString() &&
            self.body == dittoDocument["body"].stringValue &&
            self.isDone == dittoDocument["isDone"].boolValue &&
            self.createdOn?.timeIntervalSince1970 == dittoDocument["createdOn"].doubleValue
    }
}
