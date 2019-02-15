//
//  CustomChatInputView.swift
//  DittoChat
//
//  Created by Maximilian Alexander on 8/9/18.
//  Copyright © 2018 Badoo. All rights reserved.
//

import UIKit
import Cartography
import RSKPlaceholderTextView

protocol CustomChatInputViewDelegate: class {
    func sendText(_ text: String)
}

class CustomChatInputView : UIView, UITextViewDelegate {
    
    weak var delegate: CustomChatInputViewDelegate?
    
    let textView : RSKPlaceholderTextView = {
        let textView = RSKPlaceholderTextView()
        textView.font = UIFont.systemFont(ofSize: UIFont.labelFontSize)
        textView.textContainerInset = UIEdgeInsets(top: 8, left: 10, bottom: 8, right: 40)
        textView.isScrollEnabled = false
        //textView.layer.borderColor = Constants.Colors.concrete.cgColor
        //textView.layer.borderWidth = 1.0
        textView.layer.cornerRadius = 36 / 2
        textView.layer.masksToBounds = true
        textView.placeholder = "Say a something already..."
        textView.placeholderColor = Constants.Colors.silver
        textView.backgroundColor = Constants.Colors.clouds
        return textView
    }()
    
    lazy var topBorder : UIView = {
        let view = UIView()
        view.backgroundColor = Constants.Colors.clouds
        return view
    }()
    
    lazy var sendButton : UIButton = {
        let button = UIButton()
        button.layer.cornerRadius = 28 / 2
        button.layer.masksToBounds = true
        button.backgroundColor = Constants.Colors.primary
        let image = UIImage(named: "send_icon")?.withRenderingMode(.alwaysTemplate)
        button.setImage(image, for: .normal)
        button.tintColor = .white
        button.imageView?.tintColor = .white
        button.imageView?.contentMode = .scaleAspectFit
        button.imageEdgeInsets = UIEdgeInsetsMake(5, 5, 5, 5)
        button.alpha = 0
        return button
    }()
    
    
    init(){
        super.init(frame: CGRect.zero)
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = UIColor.white
        
        addSubview(textView)
        addSubview(topBorder)
        addSubview(sendButton)
        
        textView.delegate = self
        
        constrain(textView, sendButton, block: { (growTextView, sendButton) in

            growTextView.left == growTextView.superview!.left + 16
            growTextView.right == growTextView.superview!.right - 16
            growTextView.top == growTextView.superview!.top + 8
            growTextView.bottom == growTextView.superview!.bottom - 8 ~ LayoutPriority(750)
            growTextView.height >= 37
            
            sendButton.width == 28
            sendButton.height == 28
            sendButton.bottom == sendButton.superview!.bottom - 13
            sendButton.right == sendButton.superview!.right - 22
        })
        constrain(topBorder, block: { (topBorder) in
            topBorder.left == topBorder.superview!.left
            topBorder.right == topBorder.superview!.right
            topBorder.top == topBorder.superview!.top
            topBorder.height == 1
        })
        
        sendButton.addTarget(self, action: #selector(sendButtonDidTap), for: .touchUpInside)
    }
    
    func textViewDidChange(_ textView: UITextView) {
        let shouldHide = textView.text == nil || textView.text.count == 0
        
        UIView.animate(withDuration: 0.1, animations: {
            self.sendButton.alpha = shouldHide ? 0 : 1
            self.sendButton.transform = shouldHide ? CGAffineTransform(scaleX: 0.25, y: 0.25) : CGAffineTransform.identity
        })
    }
    
    override func layoutSubviews() {
        self.updateConstraints() // Interface rotation or size class changes will reset constraints as defined in interface builder -> constraintsForVisibleTextView will be activated
        super.layoutSubviews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func sendButtonDidTap(){
        guard textView.text != nil && textView.text.count != 0, let text = self.textView.text else { return }
        self.delegate?.sendText(text)
        self.textView.text = ""
        
    }
    
}
