//
//  MainSubBar.swift
//  Maintenance
//
//  Created by Maximilian Alexander on 11/26/18.
//  Copyright © 2018 DittoLive. All rights reserved.
//

import UIKit

class MainSubBar: UIToolbar {

    init() {
        super.init(frame: .zero)
        
        let backButton = UIBarButtonItem(image: UIImage(named: "back_icon"), style: .plain, target: nil, action: nil)
        let planeButton = UIBarButtonItem(image: UIImage(named: "plane_icon"), style: .plain, target: nil, action: nil)
        let mDeckButton = UIBarButtonItem(title: "M-Deck", style: .plain, target: nil, action: nil)
        
        mDeckButton.setTitleTextAttributes([
            NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14),
            NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue
        ], for: UIControl.State.normal)
        
        let uDeckButton = UIBarButtonItem(title: "U-Deck", style: .plain, target: nil, action: nil)
        
        uDeckButton.setTitleTextAttributes([
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14)
        ], for: UIControl.State.normal)
        
        let menuButton = UIBarButtonItem(image: UIImage(named: "hamburger_shaved_icon"), style: .plain, target: nil, action: nil)
        let flexButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)

        self.setItems([
            backButton,
            planeButton,
            mDeckButton,
            uDeckButton,
            flexButton,
            menuButton
        ], animated: true)
        
        self.tintColor = .black
        self.barTintColor = Constants.Colors.clouds
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
