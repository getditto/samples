//
//  Category.swift
//  CombineMenu
//
//  Created by Maximilian Alexander on 3/3/22.
//

import DittoSwift
import Foundation

struct Category: Identifiable, Equatable, Hashable {
    var id: String
    var name: String
    
    init(document: DittoDocument) {
        self.id = document["_id"].stringValue
        self.name = document["name"].stringValue
    }
}
