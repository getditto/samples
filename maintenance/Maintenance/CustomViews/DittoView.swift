//
//  DittoView.swift
//  Maintenance
//
//  Created by Maximilian Alexander on 11/28/18.
//  Copyright © 2018 DittoLive. All rights reserved.
//

import UIKit
import Cartography

class DittoView: UIView {
    
    lazy var logoImageView: UIImageView = {
        let image = UIImage(named: "ditto_logo")
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    lazy var blurView = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffect.Style.extraLight))

    init() {
        super.init(frame: .zero)
        addSubview(blurView)
        addSubview(logoImageView)
        
        constrain(blurView, logoImageView) { (blurView, welcomeImageView) in
            blurView.left == blurView.superview!.left
            blurView.right == blurView.superview!.right
            blurView.top == blurView.superview!.top
            blurView.bottom == blurView.superview!.bottom
            
            welcomeImageView.width == 200
            welcomeImageView.height == 200
            welcomeImageView.centerX == welcomeImageView.superview!.centerX
            welcomeImageView.centerY == welcomeImageView.superview!.centerY
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
