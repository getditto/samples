//
//  ViewController.swift
//  DittoCoreData
//
//  Created by Maximilian Alexander on 6/17/21.
//

import UIKit
import Fakery
import CoreData
import DittoSwift

class MainViewController: UIViewController {

    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Model")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    lazy var fetchRequest: NSFetchRequest<Task> = {
        let request = NSFetchRequest<Task>()
        request.entity = Task.entity()
        request.sortDescriptors = [NSSortDescriptor(key: "createdOn", ascending: true)]
        return request
    }()

    lazy var fetchedResultsController: NSFetchedResultsController<Task> = {
        // Initialize Fetch Request
        let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
        // Add Sort Descriptors
        let sortDescriptor = NSSortDescriptor(key: "createdOn", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        // Initialize Fetched Results Controller
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.persistentContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        // Configure Fetched Results Controller
        fetchedResultsController.delegate = self
        return fetchedResultsController
    }()

    lazy var ditto: Ditto = {
        // read license token
        let path = Bundle.main.path(forResource: "license_token", ofType: "txt") // file path for file "data.txt"
        let licenseToken = try! String(contentsOfFile: path!, encoding: String.Encoding.utf8)
        let ditto = Ditto()
        ditto.setAccessLicense(licenseToken)
        return ditto
    }()

    var dittoLiveQuery: DittoLiveQuery?

    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.title = "Ditto CoreData"
        // set the delegate to get notified from the fetch controller
        fetchedResultsController.delegate = self;
        // begin the initial fetch
        try! fetchedResultsController.performFetch()
        ditto.startSync()
        bindIncomingChangesFromDitto()
    }

    @IBAction @objc func addButtonDidClick() {
        let faker = Faker()
        let body = faker.lorem.sentence()
        let isDone = faker.number.randomBool()
        try! ditto.store["tasks"].insert([
            "body": body,
            "isDone": isDone,
            "createdOn": Date().timeIntervalSince1970 as Double
        ])
    }

    @IBAction @objc func trashButtonDidClick() {
        ditto.store["tasks"].findAll().remove()
    }

}

extension MainViewController: UITableViewDataSource {

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

extension MainViewController: UITableViewDelegate {

    /**
     This adds swipe to delete functionality
     */
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let task = fetchedResultsController.fetchedObjects![indexPath.row]
            ditto.store.collection("tasks").findByID(DittoDocumentID(value: task.id)).remove()
        }
    }

    /**
     When a user clicks on a table row, get the fetched tasks and toggle the isDone
     */
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let task = fetchedResultsController.fetchedObjects![indexPath.row]
        task.isDone = !task.isDone
        try! fetchedResultsController.managedObjectContext.save()
        ditto.store.collection("tasks").findByID(DittoDocumentID(value: task.id)).update { doc in
            doc?["isDone"].set(task.isDone)
        }
    }

}

/**
 These delegate functions are called whenever CoreData's tasks objects are changed
 */
extension MainViewController: NSFetchedResultsControllerDelegate {

    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            tableView.insertRows(at: [newIndexPath!], with: .automatic)
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .automatic)
        case .update:
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


/**
 Handle incoming changes from Ditto
 */
extension MainViewController {

    /**
     Incoming changes from Ditto should map to core data
     */
    func bindIncomingChangesFromDitto () {
        dittoLiveQuery = ditto.store["tasks"].findAll().sort("createdOn", direction: .ascending)
            .observe { docs, event in
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
                }).forEach { (task, document) in
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
                    print("inserting")
                }

                try! context.save()
            }
    }


}


extension Task {

    func isSameValue(as dittoDocument: DittoDocument) -> Bool {
        return
            self.id == dittoDocument.id.toString() &&
            self.body == dittoDocument["body"].stringValue &&
            self.isDone == dittoDocument["isDone"].boolValue &&
            self.createdOn?.timeIntervalSince1970 == dittoDocument["createdOn"].doubleValue
    }


}
