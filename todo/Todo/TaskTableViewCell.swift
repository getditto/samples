//
//  TaskTableViewCell.swift
//  Todo
//
//  Created by Maximilian Alexander on 10/29/18.
//  Copyright © 2018 DittoLive. All rights reserved.
//

import UIKit
import Cartography

class TaskTableViewCell: UITableViewCell {
    
    static let REUSE_ID = "TaskTableViewCell"

    var task: Task? = nil
    
    lazy var isDoneButton: UIButton = {
        let b = UIButton()
        b.translatesAutoresizingMaskIntoConstraints = false
        b.layer.masksToBounds = true
        b.layer.cornerRadius = 15
        b.layer.borderColor = UIColor.gray.cgColor
        b.layer.borderWidth = 1.5
        return b
    }()
    
    lazy var titleLabel: VerticalTopAlignLabel = {
        let t = VerticalTopAlignLabel()
        return t
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(isDoneButton)
        contentView.addSubview(titleLabel)
        
        selectionStyle = .none
        
        constrain(isDoneButton, titleLabel) { (isDoneButton, titleLabel) in
            isDoneButton.left == isDoneButton.superview!.left + 16
            isDoneButton.top == isDoneButton.superview!.top + 8
            isDoneButton.height == 30
            isDoneButton.width == 30
            
            titleLabel.left == isDoneButton.right + 16
            titleLabel.right == titleLabel.superview!.right - 16
            titleLabel.top == titleLabel.superview!.top + 12
            titleLabel.height >= 30
            titleLabel.bottom == titleLabel.superview!.bottom - 16 ~ .defaultLow
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setTask(_ task: Task) {
        self.task = task
        if task.isDone {
            self.isDoneButton.backgroundColor = Constants.Colors.blue
            self.isDoneButton.layer.borderColor = UIColor.clear.cgColor
        } else {
            self.isDoneButton.backgroundColor = .white
            self.isDoneButton.layer.borderColor = UIColor.lightGray.cgColor
        }
        self.titleLabel.text = task.text
    }
    
}
