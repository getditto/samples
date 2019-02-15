//
//  Constants.swift
//  ChattoApp
//
//  Created by Maximilian Alexander on 7/26/18.
//  Copyright © 2018 Badoo. All rights reserved.
//

import Foundation
import UIKit

struct Constants {
    
    struct Ditto {
        static var ACCESS_TOKEN: String! = {
            // Reading ACCESS_TOKEN.txt file.
            let ACCESS_TOKEN = try! String(contentsOfFile: Bundle.main.path(forResource: "ACCESS_TOKEN", ofType: "txt")!)
            return ACCESS_TOKEN
        }()
    }
    
    struct Fonts {
        static let baseFont: CGFloat = 16.0
    }
    
    struct Colors {
        static let primary = UIColor(hexString: "#007AFF")
        static let clouds = UIColor(hexString: "#ecf0f1")
        static let silver = UIColor(hexString: "#bdc3c7")
    }
}

extension UserDefaults {
    var username: String! {
        get {
            return self.string(forKey: "_username")
        } set(val) {
            self.set(val, forKey: "_username")
        }
    }
    var siteId: UInt32 {
        get {
            guard self.integer(forKey: "_siteId") != 0 else {
                let diceRoll = Int(arc4random_uniform(6000) + 1)
                self.set(diceRoll, forKey: "_siteId")
                return UInt32(diceRoll)
            }
            return UInt32(self.integer(forKey: "_siteId"))
        }
    }
}
