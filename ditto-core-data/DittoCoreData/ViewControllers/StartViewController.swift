//
//  StartViewController.swift
//  DittoCoreData
//
//  Created by Maximilian Alexander on 6/18/21.
//

import UIKit

struct Option {
    var title: String
    var details: String
    var controllerType: UIViewController.Type
}

class StartViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    let tableView = UITableView()
    var options: [Option] = [
        Option(title: "Unidirectional",
               details: "Edit Ditto only, Ditto updates Core Data",
               controllerType: UnidirectionalViewController.self),
        Option(title: "Bidirectional",
               details: "Edit Core Data and Ditto will move data around",
               controllerType: BidirectionalViewController.self),
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Ditto Core Data Interop"
        view.addSubview(tableView)
        tableView.dataSource = self
        tableView.delegate = self
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = self.view.frame
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let option = options[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") ?? UITableViewCell(style: .subtitle, reuseIdentifier: "Cell")
        cell.textLabel?.text = option.title
        cell.textLabel?.font = UIFont.systemFont(ofSize: UIFont.labelFontSize, weight: .bold)
        cell.detailTextLabel?.text = option.details
        return cell
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return options.count
    }


    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let option = options[indexPath.row]
        tableView.deselectRow(at: indexPath, animated: true)
        navigationController?.pushViewController(option.controllerType.init(), animated: true)
    }
    
}
