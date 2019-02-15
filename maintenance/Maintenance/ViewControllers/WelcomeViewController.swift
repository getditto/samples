//
//  WelcomeViewController.swift
//  Maintenance
//
//  Created by Maximilian Alexander on 11/26/18.
//  Copyright © 2018 DittoLive. All rights reserved.
//

import UIKit
import Cartography

class WelcomeViewController: UIViewController, LoginViewControllerDelegate {

    lazy var welcomeImageView: UIImageView = {
        let image = UIImage(named: "welcome_logo_jal")
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    lazy var welcomeButton: MButton = {
        let b = MButton()
        b.setTitle("Welcome", for: .normal)
        return b
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        view.addSubview(welcomeImageView)
        view.addSubview(welcomeButton)
        
        constrain(welcomeImageView, welcomeButton) { (welcomeImageView, welcomeButton) in
            welcomeImageView.width == 234
            welcomeImageView.height == 234
            welcomeImageView.centerX == welcomeImageView.superview!.centerX
            welcomeImageView.centerY == welcomeImageView.superview!.centerY
            
            if UI_USER_INTERFACE_IDIOM() == .pad {
                welcomeButton.width == welcomeButton.superview!.width * (1 / 3)
                welcomeButton.centerX == welcomeButton.superview!.centerX
            } else {
                welcomeButton.left == welcomeButton.superview!.left + Constants.Layout.major
                welcomeButton.right == welcomeButton.superview!.right - Constants.Layout.major
            }
            welcomeButton.height == 50
            welcomeButton.bottom == welcomeButton.superview!.bottomMargin - Constants.Layout.major
        }
        
        welcomeButton.addTarget(self, action: #selector(welcomeButtonDidClick), for: .touchUpInside)
    }
    
    @objc func welcomeButtonDidClick() {
        let loginViewController = LoginViewController()
        loginViewController.delegate = self
        let nav = UINavigationController(rootViewController: loginViewController)
        if UI_USER_INTERFACE_IDIOM() == .pad {
            nav.modalPresentationStyle = .formSheet
        }
        present(nav, animated: true, completion: nil)
    }

    func didLogin(name: String) {
        UserDefaults.standard.name = name
        navigationController?.setViewControllers([MainViewController()], animated: true)
    }
}
