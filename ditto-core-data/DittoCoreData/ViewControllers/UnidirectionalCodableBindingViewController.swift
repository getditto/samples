//
//  UnidirectionalCodableBinding.swift
//  DittoCoreData
//
//  Created by Maximilian Alexander on 6/22/21.
//

import UIKit
import DittoSwift
import CoreData
import Fakery
import CodableWrappers


extension MenuItem {

}

class UnidirectionalCodableBindingViewController: UIViewController {

    let tableView = UITableView()

    lazy var fetchedResultsController: NSFetchedResultsController<MenuItem> = {
        // Initialize Fetch Request
        let fetchRequest: NSFetchRequest<MenuItem> = MenuItem.fetchRequest()
        // Initialize Fetched Results Controller
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: AppDelegate.persistentContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        // Configure Fetched Results Controller
        return fetchedResultsController
    }()

    var ditto = AppDelegate.ditto
    var liveQuery: DittoLiveQuery?
    var menuItems = [MenuItem]()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Codable Binding"
        view.addSubview(tableView)
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(rightBarButtonItemDidClick))

        tableView.dataSource = self
        tableView.delegate = self

        liveQuery = ditto?.store.collection("menuItems").findAll().observe(eventHandler: { [weak self] docs, _ in
            guard let `self` = self else { return }
            self.tableView.reloadData()
        })

        try! fetchedResultsController.performFetch()
        let initiallyFetchedObjects = fetchedResultsController.fetchedObjects ?? []

        for menuItem in initiallyFetchedObjects {
            ditto?.store.collection("menuItems").findByID(menuItem.id)
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = self.view.frame
    }

    @objc func rightBarButtonItemDidClick() {

    }

}

extension UnidirectionalCodableBindingViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuItems.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = self.menuItems[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") ?? UITableViewCell(style: .subtitle, reuseIdentifier: "Cell")
        cell.textLabel?.text = item.name
        cell.detailTextLabel?.text = {
            let details = "\(item.price) \(item.detail ?? "")"
            return details
        }()
        return cell
    }


}

extension UnidirectionalCodableBindingViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let menuItemId = menuItems[indexPath.row].id
            ditto?.store.collection("menuItems").findByID(menuItemId).remove()
        }
    }
}
