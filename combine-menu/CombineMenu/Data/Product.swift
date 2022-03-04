//
//  Product.swift
//  CombineMenu
//
//  Created by Maximilian Alexander on 3/3/22.
//

import Foundation
import DittoSwift

struct Product: Codable {
    var _id: String
    var name: String
    var detail: String
    var categoryId: String
}

extension Product: Identifiable {
    var id: String {
        return self._id
    }
}
