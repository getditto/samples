//
//  ToDo.swift
//  ToDo
//
//  Created by Maximilian Alexander on 6/11/21.
//

import Foundation
import DittoSwift

struct ToDo {

    let id: String
    let body: String
    let isDone: Bool

    init(_ document: DittoDocument) {
        id = document.id.value as! String
        body = document["body"].stringValue
        isDone = document["isDone"].boolValue
    }
}
