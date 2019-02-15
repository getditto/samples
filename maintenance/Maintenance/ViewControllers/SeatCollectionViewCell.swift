//
//  SeatCollectionViewCell.swift
//  Maintenance
//
//  Created by Maximilian Alexander on 11/26/18.
//  Copyright © 2018 DittoLive. All rights reserved.
//

import UIKit
import THLabel
import Cartography

class SeatCollectionViewCell: UICollectionViewCell {
    
    static let REUSE_ID = "SeatCollectionViewCell"
    
    let seatLabel: THLabel = {
        let u = THLabel()
        u.textAlignment = .center
        u.text = "AF"
        u.font = Constants.Fonts.bold
        u.strokeSize = 2.0
        u.strokeColor = .white
        return u
    }()
    
    lazy var seatImageView: UIImageView = {
        let i = UIImageView(image: UIImage(named: "seat_icon")?.withRenderingMode(.alwaysTemplate))
        i.contentMode = .scaleAspectFit
        return i
    }()
    
    let redRingView: UIView = {
        let v = UIView()
        v.layer.borderColor = UIColor.red.cgColor
        v.layer.borderWidth = 1
        v.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
        v.layer.cornerRadius = 20 / 2
        v.alpha = 0
        return v
    }()
    
    let checkIconImageView: UIImageView = {
        let v = UIImageView()
        v.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        v.image = UIImage(named: "check_icon")?.withRenderingMode(.alwaysTemplate)
        v.tintColor = Constants.Colors.successColor
        v.alpha = 0
        return v
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(seatImageView)
        contentView.addSubview(seatLabel)
        contentView.addSubview(redRingView)
        contentView.addSubview(checkIconImageView)
        
        redRingView.center = contentView.center
        
        // backgroundColor = Constants.Colors.clouds
        // layer.borderWidth = 1.5
        // layer.borderColor = Constants.Colors.asbestos?.cgColor
        constrain(seatLabel, seatImageView) { (seatLabel, seatImageView) in
            seatImageView.left == seatImageView.superview!.left
            seatImageView.height == seatImageView.superview!.height * (2 / 3)
            seatImageView.bottom == seatImageView.superview!.bottom
            seatImageView.right == seatImageView.superview!.right
            
            seatLabel.height == seatImageView.superview!.height * (1 / 3)
            seatLabel.top == seatImageView.top
            seatLabel.right == seatLabel.superview!.right
            seatLabel.left == seatLabel.superview!.left
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        redRingView.alpha = 0
        redRingView.center = self.contentView.center
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func animateNewError() {
        redRingView.transform = CGAffineTransform.identity
        redRingView.alpha = 1
        redRingView.center = self.contentView.center
        
        UIView.animate(withDuration: 0.75, animations: {
            self.redRingView.transform = CGAffineTransform(scaleX: 10, y: 10)
            self.redRingView.alpha = 0
        }) { (_) in
            self.redRingView.transform = CGAffineTransform.identity
        }
    }
    
    func animateSuccess() {
        checkIconImageView.transform = CGAffineTransform.identity
        checkIconImageView.alpha = 1
        checkIconImageView.center = self.contentView.center
        
        UIView.animate(withDuration: 0.75, animations: {
            self.checkIconImageView.center = CGPoint(x: self.checkIconImageView.center.x, y: self.checkIconImageView.center.y - 50)
            self.checkIconImageView.alpha = 0
        }) { (_) in
            self.checkIconImageView.center = self.contentView.center
        }
    }
    
}
