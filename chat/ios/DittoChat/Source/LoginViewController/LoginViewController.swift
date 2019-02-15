//
//  LoginViewController.swift
//  ChattoApp
//
//  Created by Maximilian Alexander on 7/26/18.
//  Copyright © 2018 Badoo. All rights reserved.
//

import UIKit
import Eureka
import Ditto

class LoginViewController: FormViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Welcome to Ditto Chat"
        DittoMeshKit.set(accessToken: Constants.Ditto.ACCESS_TOKEN)
        form +++ Section()
            <<< TextRow("USERNAME") { row in
                row.title = "Username: "
            }
            +++ Section()
            <<< ButtonRow("Login") { row in
                row.title = "Login"
            }.onCellSelection({ [weak self] (_, _) in
                self?.loginButtonDidClick()
            })
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let row: TextRow? = self.form.rowBy(tag: "USERNAME")
        row?.cell.textField.becomeFirstResponder()
    }
    
    func loginButtonDidClick() {
        let username: String = self.form.values()["USERNAME"] as? String ?? ""
        if username.isEmpty {
            let alert = UIAlertController(title: "Uh Oh!", message: "Username cannot be empty", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }
        UserDefaults.standard.username = username
        self.navigationController?.setViewControllers([DemoChatViewController()], animated: true)
    }
}
