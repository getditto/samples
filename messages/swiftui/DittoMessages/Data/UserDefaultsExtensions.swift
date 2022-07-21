//
//  UserDefaultsExtensions.swift
//  DittoMessages
//
//  Created by Maximilian Alexander on 7/20/22.
//

import Foundation
import Combine

extension UserDefaults {

    @objc var userId: String? {
        get {
            return string(forKey: "userId")
        }
        set(value) {
            set(value, forKey: "userId")
        }
    }

    var userIdPublisher: AnyPublisher<String?, Never> {
        UserDefaults.standard
            .publisher(for: \.userId)
            .eraseToAnyPublisher()
    }

}
