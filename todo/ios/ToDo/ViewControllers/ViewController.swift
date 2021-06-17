//
//  ViewController.swift
//  ToDo
//
//  Created by Maximilian Alexander on 5/27/21.
//

import UIKit
import DittoSwift

class ViewController: UIViewController, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var plusBarButtonItem: UIBarButtonItem!

    var liveQuery: DittoLiveQuery?
    var todos: [ToDo] = []
    /**
     This variable needs to be held if you want to keep observing peer information.
     */
    var observer: DittoPeersObserver?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.tableView.rowHeight = UITableView.automaticDimension;
        self.tableView.estimatedRowHeight = 44.0;
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.title = "To Do"

        liveQuery = AppDelegate.ditto.store["todos"].findAll().sort("ordinal", direction: .ascending)
            .observe(eventHandler: { docs, event in
                self.todos = docs.map({ ToDo($0) })

            })
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todos.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") ?? UITableViewCell(style: .subtitle, reuseIdentifier: "Cell")
        let todo = todos[indexPath.row]
        cell.detailTextLabel?.numberOfLines = 0
        cell.textLabel?.text = todo.text
        return cell
    }

    @IBAction @objc func plusBarButtonDidClick() {
        
    }

}

