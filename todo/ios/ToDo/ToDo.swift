//
//  ToDo.swift
//  ToDo
//
//  Created by Maximilian Alexander on 6/11/21.
//

import Foundation
import DittoSwift

struct ToDo: Ordinal {

    let id: String
    let body: String
    let isDone: Bool
    let ordinal: Float

    init(_ document: DittoDocument) {
        id = document.id.value as! String
        body = document["body"].stringValue
        isDone = document["isDone"].boolValue
        ordinal = document["ordinal"].floatValue
    }
}
