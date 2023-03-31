//
//  Product.swift
//  CombineMenu
//
//  Created by Maximilian Alexander on 3/3/22.
//

import DittoSwift
import Foundation

struct Product: Identifiable, Equatable, Hashable {
    var id: String
    var name: String
    var detail: String
    var categoryId: String
    
    init(document: DittoDocument) {
        self.id = document["_id"].stringValue
        self.name = document["name"].stringValue
        self.detail = document["detail"].stringValue
        self.categoryId = document["categoryId"].stringValue
    }
}
