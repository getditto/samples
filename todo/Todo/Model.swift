//
//  Model.swift
//  Todo
//
//  Created by Maximilian Alexander on 9/7/18.
//  Copyright © 2018 DittoLive. All rights reserved.
//

import Foundation
import Ditto

typealias Codable = Encodable & Decodable

struct Task: Codable {
    var _id: String?
    var text: String = ""
    var isDone: Bool = false
}

extension Task  {
    func toDoc() throws -> Document {
        let jsonEncoder = JSONEncoder()
        let jsonData = try jsonEncoder.encode(self)
        return try JSONSerialization.jsonObject(with: jsonData, options: []) as! Document
    }
}
