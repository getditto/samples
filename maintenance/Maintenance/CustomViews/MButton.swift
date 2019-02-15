//
//  MButton.swift
//  Maintenance
//
//  Created by Maximilian Alexander on 11/26/18.
//  Copyright © 2018 DittoLive. All rights reserved.
//

import UIKit

class MButton: UIButton {

    init() {
        super.init(frame: .zero)
        self.backgroundColor = Constants.Colors.mainColor
        self.setTitleColor(.white, for: .normal)
        self.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        self.layer.masksToBounds = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.cornerRadius = Constants.Layout.cornerRadius
    }
    
}
