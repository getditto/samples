//
//  TasksTableViewController.swift
//  Tasks
//
//  Created by Adam Fish on 9/18/19.
//  Copyright © 2019 DittoLive Incorporated. All rights reserved.
//

import UIKit
import DittoSwift

class TasksTableViewController: UITableViewController {
    // These hold references to Ditto for easy access
    var ditto: Ditto!
    var store: DittoStore!
    var liveQuery: DittoLiveQuery?
    var collection: DittoCollection!

    // This is the UITableView data source
    var tasks: [DittoDocument] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        // Create an instance of Ditto
        ditto = Ditto()

        // Set your Ditto access license
        // The SDK will not work without this!
        do {
            // set the access token
            try ditto.setOfflineOnlyLicenseToken("o2d1c2VyX2lkbnJhZUBkaXR0by5saXZlZmV4cGlyeXgYMjAyMi0wOC0yMVQwNjo1OTo1OS45OTlaaXNpZ25hdHVyZXhYNkhOVlFEblFpQnFta3hjbzZEZGkra1VSV01yWkJERXdRZG5aa3E3c0dBSFBYYk9kbHVOMFlVbzMxWkR4dmlkK2lHS05VTldPM2duazZPUzhOc3F5Z1E9PQ==")
            // This starts Ditto's background synchronization
            try ditto.startSync()
        } catch(let err) {
            let alert = UIAlertController(title: "Uh oh", message: "Ditto wasn't able to start syncing. That's okay it'll still work as a local database. Here's the error: \n \(err.localizedDescription)", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }


        // Create some helper variables for easy access
        store = ditto.store
        // We will store data in the "tasks" collection
        // Ditto stores data as collections of documents
        collection = store.collection("tasks")

        // This function will create a "live-query" that will update
        // our UITableView
        setupTaskList()
    }

    func setupTaskList() {
        // Query for all tasks
        // Observe changes with a live-query and update the UITableView
        liveQuery = collection.findAll().observe { [weak self] docs, event in
            guard let `self` = self else { return }
            switch event {
            case .update(let changes):
                guard changes.insertions.count > 0 || changes.deletions.count > 0 || changes.updates.count > 0  || changes.moves.count > 0 else { return }
                DispatchQueue.main.async {
                    self.tableView.beginUpdates()
                    self.tableView.performBatchUpdates({
                        let deletionIndexPaths = changes.deletions.map { idx -> IndexPath in
                            return IndexPath(row: idx, section: 0)
                        }
                        self.tableView.deleteRows(at: deletionIndexPaths, with: .automatic)
                        let insertionIndexPaths = changes.insertions.map { idx -> IndexPath in
                            return IndexPath(row: idx, section: 0)
                        }
                        self.tableView.insertRows(at: insertionIndexPaths, with: .automatic)
                        let updateIndexPaths = changes.updates.map { idx -> IndexPath in
                            return IndexPath(row: idx, section: 0)
                        }
                        self.tableView.reloadRows(at: updateIndexPaths, with: .automatic)
                        for move in changes.moves {
                            let from = IndexPath(row: move.from, section: 0)
                            let to = IndexPath(row: move.to, section: 0)
                            self.tableView.moveRow(at: from, to: to)
                        }
                    }) { _ in }
                    // Set the tasks array backing the UITableView to the new documents
                    self.tasks = docs
                    self.tableView.endUpdates()
                }
            case .initial:
                // Set the tasks array backing the UITableView to the new documents
                self.tasks = docs
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            default: break
            }
        }
    }

    @IBAction func didClickAddTask(_ sender: UIBarButtonItem) {
        // Create an alert
        let alert = UIAlertController(
            title: "Add New Task",
            message: nil,
            preferredStyle: .alert)

        // Add a text field to the alert for the new task text
        alert.addTextField(configurationHandler: nil)

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

        // Add a "OK" button to the alert. The handler calls addNewTasksItem()
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak self] (_) in
            guard let `self` = self else { return }
            if let text = alert.textFields?[0].text
            {
                // Insert the data into Ditto
                let _ = try! self.collection.upsert([
                    "body": text,
                    "isCompleted": false
                ])
            }
        }))

        // Present the alert to the user
        present(alert, animated: true, completion: nil)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks.count
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "taskCell", for: indexPath)

        // Configure the cell...
        let task = tasks[indexPath.row]
        cell.textLabel?.text = task["body"].stringValue
        let isCompleted = task["isCompleted"].boolValue
        cell.imageView?.image = UIImage(systemName: isCompleted ? "largecircle.fill.circle" : "circle")
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Deselect the row so it is not highlighted
        tableView.deselectRow(at: indexPath, animated: true)
        // Retrieve the task at the row selected
        let task = tasks[indexPath.row]
        // Update the task to mark completed
        collection.findByID(task.id).update({ (newTask) in
            newTask?["isCompleted"].set(!task["isCompleted"].boolValue)
        })
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Retrieve the task at the row swiped
            let task = tasks[indexPath.row]
            // Delete the task from Ditto
            collection.findByID(task.id).remove()
        }
    }

}
