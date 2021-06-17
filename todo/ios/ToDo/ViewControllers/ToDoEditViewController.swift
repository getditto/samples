//
//  ToDoEditViewController.swift
//  ToDo
//
//  Created by Maximilian Alexander on 6/11/21.
//

import UIKit

class ToDoEditViewController: UIViewController {

    @IBOutlet weak var closeBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var saveBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var isDoneSwitch: UISwitch!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction @objc func closeButtonDidClick() {
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction @objc func saveButtonDidClick() {
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction @objc func switchDidChange(switch: UISwitch) {

    }
}
