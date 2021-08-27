//
//  Task.swift
//  Tasks
//
//  Created by Maximilian Alexander on 8/16/21.
//

import Foundation

struct Task: Codable {
    let _id: String
    let body: String
    let isCompleted: Bool
}
