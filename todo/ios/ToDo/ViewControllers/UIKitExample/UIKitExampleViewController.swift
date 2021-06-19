//
//  ViewController.swift
//  ToDo
//
//  Created by Maximilian Alexander on 5/27/21.
//

import UIKit
import DittoSwift

class UIKitExampleViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var plusBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var textField: UITextField?

    var liveQuery: DittoLiveQuery?
    var todos: [ToDo] = []
    /**
     This variable needs to be held if you want to keep observing peer information.
     */
    var observer: DittoPeersObserver?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "To Do"
        liveQuery = AppDelegate.ditto.store["todos"].findAll().sort("ordinal", direction: .ascending)
            .observe(eventHandler: { docs, event in
                self.todos = docs.map({ ToDo($0) })
                self.tableView.reloadData()
            })
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }
        return todos.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "INSERT_CELL", for: indexPath) as! InsertTableViewCell
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "TODO_CELL", for: indexPath) as! ToDoTableViewCell
        let todo = todos[indexPath.row]
        cell.checkBoxImageView.image = todo.isDone ? UIImage(named: "box_checked"): UIImage(named: "box_empty")
        cell.bodyLabel?.text = todo.body
        cell.selectionStyle = .none
        return cell
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Create new todo"
        }
        return "Todos"
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let todo = todos[indexPath.row]
        AppDelegate.ditto.store["todos"].findByID(todo.id).update { mutableDoc in
            mutableDoc?["isDone"].set(!todo.isDone)
        }
    }


    @IBAction @objc func addButtonDidClick() {
        guard let insertCell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? InsertTableViewCell else { return }
        try! AppDelegate.ditto.store["todos"].insert([
            "body": insertCell.textField.text ?? "",
            "isDone": false
        ])
        insertCell.textField.text = ""
    }



}

