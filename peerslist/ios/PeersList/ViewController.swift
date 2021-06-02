//
//  ViewController.swift
//  PeersList
//
//  Created by Maximilian Alexander on 5/27/21.
//

import UIKit
import DittoSwift

class ViewController: UIViewController, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    var peers: [DittoRemotePeer] = []
    /**
     This variable needs to be held if you want to keep observing peer information.
     */
    var observer: DittoPeersObserver?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.tableView.rowHeight = UITableView.automaticDimension;
        self.tableView.estimatedRowHeight = 44.0;
        self.title = "Ditto Remote Peers"

        observer = AppDelegate.ditto.observePeers { [weak self] peers in
            self?.peers = peers
            self?.tableView.reloadData()
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return peers.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") ?? UITableViewCell(style: .subtitle, reuseIdentifier: "Cell")
        let peer = peers[indexPath.row]
        cell.detailTextLabel?.numberOfLines = 0
        cell.textLabel?.text = peer.id
        cell.detailTextLabel?.text = """
            Connections: \(peer.connections.joined(separator: ","))
            approximateDistanceInMeters: \(String(describing: peer.approximateDistanceInMeters))m
            """
        return cell
    }


}

