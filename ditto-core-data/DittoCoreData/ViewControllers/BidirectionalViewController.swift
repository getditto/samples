//
//  BidirectionalViewController.swift
//  DittoCoreData
//
//  Created by Maximilian Alexander on 6/18/21.
//
import UIKit
import CoreData
import DittoSwift
import Fakery

class BidirectionalViewController: UIViewController {
    let tableView = UITableView()

    lazy var fetchedResultsController: NSFetchedResultsController<Task> = {
        // Initialize Fetch Request
        let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
        // Add Sort Descriptors
        let sortDescriptor = NSSortDescriptor(key: "createdOn", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        // Initialize Fetched Results Controller
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: AppDelegate.persistentContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        // Configure Fetched Results Controller
        fetchedResultsController.delegate = self
        return fetchedResultsController
    }()

    var liveQuery: DittoLiveQuery?

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Bidirectional"
        view.addSubview(tableView)
        tableView.dataSource = self
        tableView.delegate = self

        // set the delegate to get notified from the fetch controller
        fetchedResultsController.delegate = self;
        // begin the initial fetch
        try! fetchedResultsController.performFetch()

        // setup navigation bars
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(trashButtonDidClick)),
            UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonDidClick))
        ]

        // hook up ditto live queries
        setupLiveQuery()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = self.view.frame
    }

    @objc func addButtonDidClick() {
        let faker = Faker()
        let body = faker.lorem.sentence()
        let isDone = faker.number.randomBool()

        let context = fetchedResultsController.managedObjectContext
        let newTask = Task(context: context)
        newTask.id = UUID().uuidString
        newTask.body = body
        newTask.isDone = isDone
        newTask.createdOn = Date()
        context.insert(newTask)
    }

    @objc func trashButtonDidClick() {
        AppDelegate.ditto.store["tasks"].findAll().remove()
    }
}

extension BidirectionalViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController.fetchedObjects?.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let task = fetchedResultsController.fetchedObjects![indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") ?? UITableViewCell(style: .subtitle, reuseIdentifier: "Cell")
        cell.textLabel?.text = task.body
        cell.detailTextLabel?.text = {
            guard let createdOn = task.createdOn else { return "" }
            let formatter = DateFormatter()
            formatter.dateStyle = .long
            formatter.timeStyle = .short
            let dateString = formatter.string(from: createdOn)
            return "createdOn: \(dateString)"
        }()
        cell.imageView?.image = task.isDone ? UIImage(named: "box_checked") : UIImage(named: "box_empty")
        cell.imageView?.tintColor = task.isDone ? .systemBlue : .darkGray
        cell.selectionStyle = .none
        return cell
    }
}

extension BidirectionalViewController: UITableViewDelegate {

    /**
     This adds swipe to delete functionality
     */
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let task = fetchedResultsController.fetchedObjects![indexPath.row]
            fetchedResultsController.managedObjectContext.delete(task)
        }
    }

    /**
     When a user clicks on a table row, get the fetched tasks and toggle the isDone
     */
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let task = fetchedResultsController.fetchedObjects![indexPath.row]
        task.isDone = !task.isDone
        try! fetchedResultsController.managedObjectContext.save()
    }
}

extension BidirectionalViewController: NSFetchedResultsControllerDelegate {

    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:

            let insertedTask = anObject as! Task
            try! AppDelegate.ditto.store["tasks"].insert([
                "body": insertedTask.body,
                "isDone": insertedTask.isDone,
                "createdOn": insertedTask.createdOn!.timeIntervalSince1970,
            ], id: DittoDocumentID(value: insertedTask.id))

            tableView.insertRows(at: [newIndexPath!], with: .automatic)
        case .delete:
            let taskToDelete = anObject as! Task
            AppDelegate.ditto.store["tasks"].findByID(taskToDelete.id!).remove()
            tableView.deleteRows(at: [indexPath!], with: .automatic)
        case .update:
            let taskToUpdate = anObject as! Task
            AppDelegate.ditto.store["tasks"].findByID(taskToUpdate.id!).update { mutableDoc in
                mutableDoc?["body"].set(taskToUpdate.body)
                mutableDoc?["isDone"].set(taskToUpdate.isDone)
                mutableDoc?["createdOn"].set(taskToUpdate.createdOn!.timeIntervalSince1970)
            }

            tableView.reloadRows(at: [indexPath!], with: .none)
        case .move:
            tableView.moveRow(at: indexPath!, to: newIndexPath!)
        default:
            return
        }
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
}

extension BidirectionalViewController {

    func setupLiveQuery() {
        liveQuery = AppDelegate.ditto.store["tasks"].findAll().observe(eventHandler: { docs, _ in
            let context = self.fetchedResultsController.managedObjectContext
            let tasks = self.fetchedResultsController.fetchedObjects ?? []

            let documentIds = docs.map({ $0.id.toString() })

            // remove tasks that don't have the same document ids
            tasks.filter({ !documentIds.contains($0.id!) }).forEach({ taskToRemoveFromCoreData in
                context.delete(taskToRemoveFromCoreData)
            })

            // update tasks that have the same documentIds
            tasks.compactMap({ task -> (task: Task, document: DittoDocument)? in
                guard let document = docs.first(where: { $0.id.toString() == task.id }) else { return nil }
                return (task, document)
            })
            .filter{ (task, document) in
                return !task.isSameValue(as: document)
            }
            .forEach { (task, document) in
                guard let doc = docs.first(where: { $0.id.toString() == task.id }) else { return }
                task.body = doc["body"].stringValue
                task.isDone = doc["isDone"].boolValue
                task.createdOn = Date(timeIntervalSince1970: doc["createdOn"].doubleValue)
            }

            // insert tasks that are missing from the documentIds
            docs.filter({ !tasks.compactMap({ task in task.id }).contains($0.id.toString()) }).forEach { doc in
                let task = Task(context: context)
                task.id = doc.id.toString()
                task.body = doc["body"].stringValue
                task.createdOn = Date(timeIntervalSince1970: doc["createdOn"].doubleValue)
                task.isDone = doc["isDone"].boolValue
                context.insert(task)
            }

            try! context.save()
        })
    }

}
