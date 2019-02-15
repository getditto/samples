//
//  LoginViewController.swift
//  Todo
//
//  Created by Maximilian Alexander on 9/7/18.
//  Copyright © 2018 DittoLive. All rights reserved.
//

import UIKit
import Eureka

class WelcomeViewController: FormViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.largeTitleDisplayMode = .always
        title = "Ditto Todo"
        
        view.backgroundColor = .white
        
        let row = TextRow("Name") { row in
            row.cell.height = { 60 }
            row.cell.textField.placeholder = "Enter Your Name"
            row.cell.textField.textAlignment = .center
            row.cell.textField.font = UIFont.systemFont(ofSize: 18)
        }
        
        let row2 = ButtonRow() { row in
            row.title = "Login to Ditto Todo"
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
        UserDefaults.standard.name = name
        navigationController?.setViewControllers([MainViewController()], animated: true)
    }
    
}
