//
//  Constants.swift
//  Maintenance
//
//  Created by Maximilian Alexander on 11/26/18.
//  Copyright © 2018 DittoLive. All rights reserved.
//

import Foundation
import HexColors

struct Constants {
    struct Colors {
        static let mainColor = UIColor("#bd0803")
        
        // Following color palette is available for reference here:
        // https://flatuicolors.com/palette/defo
        static let clouds = UIColor("#ecf0f1")
        static let silver = UIColor("#bdc3c7")
        static let concrete = UIColor("#95a5a6")
        static let asbestos = UIColor("#7f8c8d")
        static let wetAsphalt = UIColor("#34495e")
        
        // error color
        static let errorColor = UIColor("#bd0803")
        static let successColor = UIColor("#00BC7F")
    }
    
    struct Fonts {
        static let regular = UIFont.systemFont(ofSize: 18)
        static let bold = UIFont.boldSystemFont(ofSize: 18)
    }
    
    struct Layout {
        static let minor: CGFloat = 8
        static let major: CGFloat = 16
        static let cornerRadius: CGFloat = 8
    }
}
