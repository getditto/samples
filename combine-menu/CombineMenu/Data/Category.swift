//
//  Category.swift
//  CombineMenu
//
//  Created by Maximilian Alexander on 3/3/22.
//

import Foundation

struct Category: Codable {
    var _id: String
    var name: String
}

extension Category: Identifiable {
    var id: String {
        return self._id
    }
}
