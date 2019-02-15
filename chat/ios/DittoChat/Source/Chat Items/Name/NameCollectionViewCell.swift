//
//  NameCollectionViewCell.swift
//  ChattoApp
//
//  Created by Maximilian Alexander on 7/26/18.
//  Copyright © 2018 Badoo. All rights reserved.
//

import UIKit

class NameCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet private weak var label: UILabel!
    
    var text: NSAttributedString? {
        didSet {
            self.label.attributedText = self.text
        }
    }
}
