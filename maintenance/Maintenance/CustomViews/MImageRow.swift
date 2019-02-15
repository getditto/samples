//
//  MImageRow.swift
//  Maintenance
//
//  Created by Maximilian Alexander on 11/26/18.
//  Copyright © 2018 DittoLive. All rights reserved.
//

import UIKit
import Cartography
import Eureka

final class MSpriteCell: Cell<UIImage>, CellType {
    
    lazy var spriteImageView: UIImageView = {
        return UIImageView()
    }()
    
    lazy var exclaimImageView: UIImageView = {
        let u = UIImageView()
        u.contentMode = .scaleAspectFit
        u.image = UIImage(named: "exclaim")?.withRenderingMode(.alwaysTemplate)
        u.alpha = 0
        u.tintColor = .white
        return u
    }()
    
    required init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(spriteImageView)
        contentView.addSubview(exclaimImageView)
        constrain(spriteImageView, exclaimImageView) { (spriteImageView, exclaimImageView) in
            spriteImageView.height == 60
            spriteImageView.width == 60
            spriteImageView.centerY == spriteImageView.superview!.centerY
            spriteImageView.centerX == spriteImageView.superview!.centerX
            
            exclaimImageView.centerX == exclaimImageView.superview!.centerX
            exclaimImageView.centerY == exclaimImageView.superview!.centerY - 10
            exclaimImageView.height == 25
            exclaimImageView.width == 25
        }
        textLabel?.isHidden = true
        detailTextLabel?.isHidden = true
        selectionStyle = .none
        self.backgroundColor = .white
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func setup() {
        super.setup()
        self.height = { 100 }
    }
    
    override func update() {
        super.update()
        guard let value = row.value else {
            self.spriteImageView.image = nil
            return
        }
        self.spriteImageView.image = value
    }
}

final class MSpriteRow: Row<MSpriteCell>, RowType {
    required init(tag: String?) {
        super.init(tag: tag)
        cellProvider = CellProvider<MSpriteCell>()
    }
}
