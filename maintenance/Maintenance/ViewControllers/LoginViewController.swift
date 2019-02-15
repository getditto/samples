//
//  LoginViewController.swift
//  Maintenance
//
//  Created by Maximilian Alexander on 11/27/18.
//  Copyright © 2018 DittoLive. All rights reserved.
//

import UIKit
import Eureka

protocol LoginViewControllerDelegate: class {
    func didLogin(name: String)
}

class LoginViewController: FormViewController {
    
    weak var delegate: LoginViewControllerDelegate?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let textRow: TextRow? = self.form.rowBy(tag: "Name")
        textRow?.cell.textField.becomeFirstResponder()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.largeTitleDisplayMode = .always
        title = "Welcome"
        
        view.backgroundColor = .white
        
        let row = TextRow("Name") { row in
            row.cell.height = { 60 }
            row.cell.textField.placeholder = "Enter Your Name"
            row.cell.textField.textAlignment = .center
            row.cell.textField.font = UIFont.systemFont(ofSize: 18)
        }
        
        let row2 = ButtonRow() { row in
            row.title = "Login"
            row.cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 18)
            }.onCellSelection({ [weak self] (_, _) in
                self?.onLoginClick()
            })
        
        let section = Section()
        section.append(row)
        form.append(section)
        let section2 = Section()
        section2.append(row2)
        form.append(section2)
    }
    
    func onLoginClick() {
        let name = self.form.values()["Name"] as? String ?? ""
        if name == "" {
            let alert = UIAlertController(title: "Uh Oh", message: "Please Enter A Name", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
            return
        }
        self.dismiss(animated: true) {
            self.delegate?.didLogin(name: name)
        }
    }

}
