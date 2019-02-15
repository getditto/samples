//
//  SeatFormViewController.swift
//  Maintenance
//
//  Created by Maximilian Alexander on 11/26/18.
//  Copyright © 2018 DittoLive. All rights reserved.
//

import UIKit
import Eureka
import Ditto

class SeatFormViewController: FormViewController, UIGestureRecognizerDelegate {
    
    let seat: String
    
    static let SPRITE = "SPRITE"
    
    static let OXYGEN_EQUIP_NEEDS_REPLACEMENT = "isOxygenEquipmentBroken"
    static let IS_LIGHT_BROKEN = "isLightBroken"
    static let MISSING_FLUX_CAPACITORS = "missingFluxCapacitors"
    
    static let POWER_BROKEN = "isPowerBroken"
    static let SEAT_ADJUST_BROKEN = "isSeatAdjustBroken"
    static let SEAT_BELT_BROKEN = "isSeatBeltBroken"
    static let LIFE_JACKET_MISSING = "isLifeJacketMissing"
    
    var disposable: Disposable?
    
    init(seat: String) {
        self.seat = seat
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Seat \(self.seat)"
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelButtonDidClick))
        
        let seatCollection = try! DittoMeshKit.shared().collection("seats")
        
        form
            +++ Section()
            <<< MSpriteRow(tag: SeatFormViewController.SPRITE)
            
            +++ Section("Overhead")
            <<< MSwitchRow(SeatFormViewController.OXYGEN_EQUIP_NEEDS_REPLACEMENT) { row in
                row.title = "Is Oxygen Equipment Broken?"
                row.cell.switchControl.onTintColor = .red
                }.onSwitchChange({ [weak self] (isOn) in
                    guard let `self` = self else { return }
                    try! seatCollection.updateById(self.seat, [
                        SeatFormViewController.OXYGEN_EQUIP_NEEDS_REPLACEMENT: isOn
                    ])
                })
            <<< MSwitchRow(SeatFormViewController.IS_LIGHT_BROKEN) { row in
                row.title = "Is Light Broken?"
                row.cell.switchControl.onTintColor = .red
                }.onSwitchChange({ [weak self] (isOn) in
                    guard let `self` = self else { return }
                    try! seatCollection.updateById(self.seat, [
                    SeatFormViewController.IS_LIGHT_BROKEN: isOn
                    ])
                })
            <<< MStepperRow(SeatFormViewController.MISSING_FLUX_CAPACITORS) { row in
                row.title = "Missing Flux Capacitors"
                row.cell.tintColor = .red
            }.onPlusDidClick { [weak self] in
                guard let `self` = self else { return }
                try! seatCollection.updateById(self.seat, [
                    UpdateOperation.increment(fieldName: SeatFormViewController.MISSING_FLUX_CAPACITORS, amount: 1)
                ])
            }.onMinusDidClick { [weak self] in
                guard let `self` = self else { return }
                try! seatCollection.updateById(self.seat, [
                    UpdateOperation.increment(fieldName: SeatFormViewController.MISSING_FLUX_CAPACITORS, amount: -1)
                ])
            }
            +++ Section("Seat")
            <<< MSwitchRow(SeatFormViewController.POWER_BROKEN, { (row) in
                row.title = "Is Power Broken?"
                row.cell.switchControl.onTintColor = .red
            }).onSwitchChange({ [weak self] (isOn) in
                guard let `self` = self else { return }
                try! seatCollection.updateById(self.seat, [
                    SeatFormViewController.POWER_BROKEN: isOn
                ])
            })
            <<< MSwitchRow(SeatFormViewController.SEAT_ADJUST_BROKEN, { (row) in
                row.title = "Is Seat Adjust Broken?"
                row.cell.switchControl.onTintColor = .red
            }).onSwitchChange({ [weak self] (isOn) in
                guard let `self` = self else { return }
                try! seatCollection.updateById(self.seat, [
                    SeatFormViewController.SEAT_ADJUST_BROKEN: isOn
                ])
            })
            <<< MSwitchRow(SeatFormViewController.SEAT_BELT_BROKEN, { (row) in
                row.title = "Is Seat Belt Broken?"
                row.cell.switchControl.onTintColor = .red
            }).onSwitchChange({ [weak self] (isOn) in
                guard let `self` = self else { return }
                try! seatCollection.updateById(self.seat, [
                    SeatFormViewController.SEAT_BELT_BROKEN: isOn
                ])
            })
            <<< MSwitchRow(SeatFormViewController.LIFE_JACKET_MISSING, { (row) in
                row.title = "Is Life Jacket Missing?"
                row.cell.switchControl.onTintColor = .red
            }).onSwitchChange({ [weak self] (isOn) in
                guard let `self` = self else { return }
                try! seatCollection.updateById(self.seat, [
                    SeatFormViewController.LIFE_JACKET_MISSING: isOn
                ])
            })
            
            +++ Section()
            <<< ButtonRow("Save") { row in
                row.title = "Save Changes"
                }
                .onCellSelection({ [weak self] (_, _) in
                    self?.dismiss(animated: true, completion: nil)
                })
        
        
        self.form.setValues([
            SeatFormViewController.SPRITE: UIImage(named: "seat_icon")?.withRenderingMode(.alwaysTemplate)
        ])
        
        disposable = seatCollection.find(NSPredicate(format: "_id == %@", self.seat)).observe({ [weak self] (docs, updates) in
            guard let `self` = self else { return }
            guard let doc = docs.first else { return }
            self.form.setValues(doc)
            self.form.allRows.forEach({ $0.reload(with: UITableView.RowAnimation.automatic) })
            guard let spriteRow: MSpriteRow = self.form.rowBy(tag: SeatFormViewController.SPRITE) else { return }
            UIView.animate(withDuration: 0.25, animations: {
                let hasIssues = doesSeatHaveAnyIssues(document: doc)
                spriteRow.cell.tintColor = hasIssues ? .white : Constants.Colors.asbestos
                spriteRow.cell.backgroundColor = hasIssues ? .red : .white
                spriteRow.cell.exclaimImageView.alpha = hasIssues ? 1 : 0
            })
        })
        
    }
    
    @objc func cancelButtonDidClick() {
        self.dismiss(animated: true, completion: nil)
    }
    
    // tap outside (code from: https://stackoverflow.com/a/44171475)
    
    private var tapOutsideRecognizer: UITapGestureRecognizer!
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if (self.tapOutsideRecognizer == nil) {
            self.tapOutsideRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.handleTapBehind))
            self.tapOutsideRecognizer.numberOfTapsRequired = 1
            self.tapOutsideRecognizer.cancelsTouchesInView = false
            self.tapOutsideRecognizer.delegate = self
            self.view.window?.addGestureRecognizer(self.tapOutsideRecognizer)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if(self.tapOutsideRecognizer != nil) {
            self.view.window?.removeGestureRecognizer(self.tapOutsideRecognizer)
            self.tapOutsideRecognizer = nil
        }
    }
    
    func close(sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Gesture methods to dismiss this with tap outside
    @objc func handleTapBehind(sender: UITapGestureRecognizer) {
        if (sender.state == UIGestureRecognizer.State.ended) {
            let location: CGPoint = sender.location(in: self.view)
            
            if (!self.view.point(inside: location, with: nil)) {
                self.view.window?.removeGestureRecognizer(sender)
                self.close(sender: sender)
            }
        }
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
