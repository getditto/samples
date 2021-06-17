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
    let text: String
    let isCompleted: Bool
    let ordinal: Float

    init(_ document: DittoDocument) {
        id = document.id.value as! String
        text = document["name"].stringValue
        isCompleted = document["isCompleted"].boolValue
        ordinal = document["ordinal"].floatValue
    }
}
