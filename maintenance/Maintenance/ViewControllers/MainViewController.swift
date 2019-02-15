//
//  ViewController.swift
//  Maintenance
//
//  Created by Maximilian Alexander on 11/26/18.
//  Copyright © 2018 DittoLive. All rights reserved.
//

import UIKit
import Cartography
import Ditto

class MainViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    let cellsPerRow = 7
    
    let mainSubBar = MainSubBar()

    var seatDocs: [Document] = []
    
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
    
    lazy var collectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        let margin: CGFloat = 15
        flowLayout.minimumInteritemSpacing = margin // The minimum spacing to use between items in the same row.
        flowLayout.minimumLineSpacing = margin * 3 // The minimum spacing to use between lines of items in the grid.
        flowLayout.sectionInset = UIEdgeInsets(top: margin, left: margin, bottom: margin, right: margin)
        
        let c = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        c.backgroundColor = .white
        c.contentInsetAdjustmentBehavior = .always
        c.register(SeatCollectionViewCell.self, forCellWithReuseIdentifier: SeatCollectionViewCell.REUSE_ID)
        return c
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Seat Cover Tool"
        view.backgroundColor = .white
        navigationItem.leftBarButtonItem = {
            let barButton = UIBarButtonItem(title: "eDoc", style: .plain, target: nil, action: nil)
            barButton.setTitleTextAttributes([
                NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 20)
                ], for: UIControl.State.normal)
            return barButton
        }()
        
        navigationItem.rightBarButtonItem = {
            let image = UIImage(named: "hamburger_icon")?.withRenderingMode(.alwaysTemplate)
            let barButton = UIBarButtonItem(image: image, style: .plain, target: nil, action: nil)
            return barButton
        }()
        
        view.addSubview(mainSubBar)
        view.addSubview(collectionView)
        
        constrain([mainSubBar, collectionView]) { (proxies) in
            let mainSubBar = proxies[0]
            mainSubBar.top == mainSubBar.superview!.topMargin
            mainSubBar.left == mainSubBar.superview!.left
            mainSubBar.right == mainSubBar.superview!.right
            mainSubBar.height == 50
            
            let collectionView = proxies[1]
            
            collectionView.left == collectionView.superview!.left
            collectionView.right == collectionView.superview!.right
            collectionView.bottom == collectionView.superview!.bottom
            collectionView.top == mainSubBar.bottom
        }
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        
        //SETUP DITTO
        
        // Reading ACCESS_TOKEN.txt file.
        let ACCESS_TOKEN = try! String(contentsOfFile: Bundle.main.path(forResource: "ACCESS_TOKEN", ofType: "txt")!)
        
        // Use default TLS certficates for encryption
        // This does not support validation to provide integrity
        DittoMeshKit.set(serverTLSCertificates: DittoMeshKitDefaultTLSCertficates)
        DittoMeshKit.set(accessToken: ACCESS_TOKEN)
        DittoMeshKit.set(userIdentifier: "\(userIdentifier)")
        DittoMeshKit.set(displayName: UserDefaults.standard.name)
        
        // Create an announcement packet to identify devices in the group
        // See the MeshKit delegate callback shouldConnect(mesh:host:announcement:) -> Bool
        // where this will be passed back from other devices where you can confirm if that
        // device should connect based on its announcement data
        DittoMeshKit.set(announcement: ["groupId": "789".data(using: String.Encoding.utf16)!])
        DittoMeshKit.set(applicationId: "MaintenanceDemo")
        DittoMeshKit.shared().minimumLogLevel = .debug
        DittoMeshKit.shared().start()
        
        let seatsCollection = try! DittoMeshKit.shared().collection("seats")
        
        let rowLetters = ["A", "B", "C", "D", "E", "F", "G"]
        var missingSeatIds = [String]()
        for index in stride(from: 1, to: 31, by: 1) {
            for l in rowLetters {
                let seatId = "\(String(format: "%02d", index))\(l)"
                if seatsCollection.findById(seatId) == nil {
                    missingSeatIds.append(seatId)
                }
            }
        }
        
        try! seatsCollection.write { (tx) in
            for missingSeatId in missingSeatIds {
                tx.insert([
                    "_id": missingSeatId,
                    "missingFluxCapacitors": 0,
                    "isOxygenEquipmentBroken": false,
                    "isLightBroken": false,
                    "isPowerBroken": false,
                    "isSeatAdjustBroken": false,
                    "isSeatBeltBroken": false,
                    "isLifeJacketMissing": false,
                ])
                tx.updateById(missingSeatId, [UpdateOperation.replaceWithCounter(fieldName: "missingFluxCapacitors", isDefault: true)])
            }
        }
        
        disposable = seatsCollection.find().observe({ [weak self] (docs, changes) in
            guard let `self` = self else { return  }
            switch changes {
            case .initial:
                self.seatDocs = docs;
                self.collectionView.reloadData()
                break
            case .update(let oldDocs, let insertions, let updates, let deletions, let moves):
                self.seatDocs = docs
                self.collectionView.performBatchUpdates({
                    self.collectionView.insertItems(at: insertions.map({ IndexPath(row: $0, section: 0) }))
                    self.collectionView.deleteItems(at: deletions.map({ IndexPath(row: $0, section: 0) }))
                    self.collectionView.reloadItems(at: updates.map({ IndexPath(row: $0, section: 0) }))
                    moves.forEach({ (from, to) in
                        self.collectionView.moveItem(at: IndexPath(row: from, section: 0), to: IndexPath(row: to, section: 0))
                    })
                }, completion: { (isComplete) in
                    
                })
                
                for update in updates {
                    let oldDoc = oldDocs[update]
                    let newDoc = docs[update]
                    
                    let oldDocHasIssues = doesSeatHaveAnyIssues(document: oldDoc)
                    let newDocHasIssues = doesSeatHaveAnyIssues(document: newDoc)
                    
                    if newDocHasIssues && !oldDocHasIssues {
                        // do animation for new issue
                        if let cell = self.collectionView.cellForItem(at: IndexPath(row: update, section: 0)) as? SeatCollectionViewCell  {
                            cell.animateNewError()
                        }
                    }
                    
                    if !newDocHasIssues && oldDocHasIssues {
                        // do animation for issue resolved!
                        if let cell = self.collectionView.cellForItem(at: IndexPath(row: update, section: 0)) as? SeatCollectionViewCell  {
                            cell.animateSuccess()
                        }
                    }
                }
                
                break;
            case .error(error: let error):
                fatalError(error.localizedDescription)
            }
        })
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SeatCollectionViewCell.REUSE_ID, for: indexPath) as! SeatCollectionViewCell
        let seatDoc = seatDocs[indexPath.row]
        cell.seatLabel.text = seatDoc["_id"] as? String
        
        if doesSeatHaveAnyIssues(document: seatDoc) {
            cell.tintColor = .red
            cell.seatLabel.textColor = .red
        } else {
            cell.tintColor = Constants.Colors.silver
            cell.seatLabel.textColor = .black
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return seatDocs.count
    }
    
    override func viewWillLayoutSubviews() {
        guard
            let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return }
        let marginsAndInsets = flowLayout.sectionInset.left + flowLayout.sectionInset.right + collectionView.safeAreaInsets.left + collectionView.safeAreaInsets.right + flowLayout.minimumInteritemSpacing * CGFloat(cellsPerRow - 1)
        let itemWidth = ((collectionView.bounds.size.width - marginsAndInsets) / CGFloat(cellsPerRow)).rounded(.down)
        flowLayout.itemSize =  CGSize(width: itemWidth, height: itemWidth * 1.3)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        collectionView.collectionViewLayout.invalidateLayout()
        super.viewWillTransition(to: size, with: coordinator)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        let seatDoc = self.seatDocs[indexPath.row]
        let seatId = seatDoc["_id"] as! String
        let nav = UINavigationController(rootViewController: SeatFormViewController(seat: seatId))
        if UI_USER_INTERFACE_IDIOM() == .pad {
            nav.modalPresentationStyle = .formSheet
        }
        self.present(nav, animated: true, completion: nil)
    }
}

