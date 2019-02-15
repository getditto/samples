//
//  ViewController.swift
//  Todo
//
//  Created by Maximilian Alexander on 9/7/18.
//  Copyright © 2018 DittoLive. All rights reserved.
//

import UIKit
import Cartography
import Ditto

class MainViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    static let COLLECTION_NAME = "tasks"
    
    lazy var tableView: UITableView = {
        let tableView = UITableView()
        return tableView
    }()
    
    let userIdentifier: UInt32 = {
        var randomSiteId = UserDefaults.standard.siteId
        if randomSiteId != 0 {
            return randomSiteId
        }
        randomSiteId = UInt32.random(range: 0...2147483646)
        UserDefaults.standard.siteId = randomSiteId
        return randomSiteId
    }()
    
    var disposable: Disposable?
    
    var tasks: [Task] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Ditto Todo"
        // Do any additional setup after loading the view, typically from a nib.
        view.addSubview(tableView)
        constrain(tableView) { (t) in
            t.left == t.superview!.left
            t.top == t.superview!.top
            t.right == t.superview!.right
            t.bottom == t.superview!.bottom
        }
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(plusButtonDidClick))
        
        tableView.register(TaskTableViewCell.self, forCellReuseIdentifier: TaskTableViewCell.REUSE_ID)
        tableView.dataSource = self
        tableView.delegate = self
        
        // Reading ACCESS_TOKEN.txt file.
        let ACCESS_TOKEN = try! String(contentsOfFile: Bundle.main.path(forResource: "ACCESS_TOKEN", ofType: "txt")!)
        
        DittoMeshKit.set(accessToken: ACCESS_TOKEN)
        DittoMeshKit.set(userIdentifier: "\(userIdentifier)")
        DittoMeshKit.set(displayName: UserDefaults.standard.name)
        DittoMeshKit.set(announcement: ["groupId": "123".data(using: String.Encoding.utf16)!])
        DittoMeshKit.set(applicationId: "DittoTodo")
        DittoMeshKit.shared().debounceDelay = -1
        DittoMeshKit.shared().minimumLogLevel = .verbose
        DittoMeshKit.shared().start()
        
        let jsonDecoder = JSONDecoder()
        
        
        
        disposable = try! DittoMeshKit.shared().collection(MainViewController.COLLECTION_NAME)
            .find()
            .observe({ [weak self] (docs, changeUpdates) in
                guard let `self` = self else { return }
                self.tasks = try! docs.map{ try JSONSerialization.data(withJSONObject: $0, options: []) }
                    .map{ try! jsonDecoder.decode(Task.self, from: $0) }
                switch changeUpdates {
                case .initial:
                    self.tableView.reloadData()
                case .update(let _, let insertions, let updates, let deletions, let moves):
                    self.tableView.beginUpdates()
                    self.tableView.insertRows(at: insertions.map({ IndexPath(row: $0, section: 0) }),
                                         with: .automatic)
                    self.tableView.deleteRows(at: deletions.map({ IndexPath(row: $0, section: 0)}),
                                         with: .automatic)
                    self.tableView.reloadRows(at: updates.map({ IndexPath(row: $0, section: 0) }),
                                         with: .automatic)
                    for move in moves {
                        self.tableView.moveRow(at: IndexPath(row: move.0, section: 0), to: IndexPath(row: move.1, section: 0))
                    }
                    self.tableView.endUpdates()
                case .error(let error):
                    fatalError("Error: \(error.localizedDescription)")
                }
            })
    }
    
    @objc func plusButtonDidClick() {
        let alertController = UIAlertController(title: "New Task", message: "Add a new Item", preferredStyle: .alert)
        
        alertController.addTextField { textField in
            textField.placeholder = "Task"
        }
        let confirmAction = UIAlertAction(title: "OK", style: .default) { [weak alertController] _ in
            guard let alertController = alertController, let textField = alertController.textFields?.first else { return }
            let text = textField.text ?? "Empty..."
            
            
            var newTask = Task()
            newTask.isDone = false
            newTask.text = text
            
            _ = try! DittoMeshKit.shared().collection(MainViewController.COLLECTION_NAME)
                .insert(newTask.toDoc())
        }
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alertController.addAction(confirmAction)
        self.present(alertController, animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // BEGIN UITableViewDataSource
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TaskTableViewCell.REUSE_ID, for: indexPath) as! TaskTableViewCell
        let task = self.tasks[indexPath.row]
        cell.setTask(task)
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks.count
    }
    // END UITableViewDataSource
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let thisTask = self.tasks[indexPath.row]
        print("This Task", thisTask);
        guard let taskId = thisTask._id else { return }
        try! DittoMeshKit.shared().collection(MainViewController.COLLECTION_NAME)
            .updateById(taskId, [
                "isDone": !thisTask.isDone
            ])
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }
        let taskId = self.tasks[indexPath.row]._id!
        try! DittoMeshKit.shared().collection(MainViewController.COLLECTION_NAME)
            .removeById(taskId)
    }
    
}

