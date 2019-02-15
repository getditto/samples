//
//  MSwitchRow.swift
//  Maintenance
//
//  Created by Maximilian Alexander on 11/27/18.
//  Copyright © 2018 DittoLive. All rights reserved.
//

import Foundation
import Eureka

// MARK: SwitchCell

open class MSwitchCell: Cell<Bool>, CellType {
    
    @IBOutlet public weak var switchControl: UISwitch!
    
    required public init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        let switchC = UISwitch()
        switchControl = switchC
        accessoryView = switchControl
        editingAccessoryView = accessoryView
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    open override func setup() {
        super.setup()
        selectionStyle = .none
        switchControl.addTarget(self, action: #selector(MSwitchCell.valueChanged), for: .valueChanged)
        switchControl.addTarget(self, action: #selector(MSwitchCell.onSwitchChange), for: .valueChanged)
    }
    
    deinit {
        switchControl?.removeTarget(self, action: nil, for: .allEvents)
    }
    
    open override func update() {
        super.update()
        switchControl.setOn(row.value ?? false, animated: true)
        switchControl.isEnabled = !row.isDisabled
    }
    
    @objc func valueChanged() {
        row.value = switchControl?.isOn ?? false
    }
    
    @objc func onSwitchChange(switchControl: UISwitch) {
        let row: MSwitchRow = self.row as! MSwitchRow
        row.callbackOnSwitchChange?(switchControl.isOn)
    }
}

// MARK: SwitchRow

open class _MSwitchRow: Row<MSwitchCell> {
    required public init(tag: String?) {
        super.init(tag: tag)
        displayValueFor = nil
    }
}

/// Boolean row that has a UISwitch as accessoryType
public final class MSwitchRow: _MSwitchRow, RowType {
    
    fileprivate var callbackOnSwitchChange: ((Bool) -> Void)?
    
    required public init(tag: String?) {
        super.init(tag: tag)
    }
    
    @discardableResult
    public func onSwitchChange(_ callback: @escaping (Bool) -> Void) -> Self {
        callbackOnSwitchChange = { (bool) in callback(bool) }
        return self
    }
}
