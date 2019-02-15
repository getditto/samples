//
//  IntMStepperRow.swift
//  Maintenance
//
//  Created by Maximilian Alexander on 11/26/18.
//  Copyright © 2018 DittoLive. All rights reserved.
//

import UIKit
import Eureka

// MARK: MStepperCell

public class MStepper: UIStepper {
    enum StepperState: Int {
        case minus = -1
        case plus = 1
        case unset = 0
    }
    
    var plusMinusState: StepperState = .unset
    
    override public var value: Double {
        willSet(value) {
            var isPlus = self.value < value;
            var isMinus = self.value > value
            
            if (self.wraps) {
                if (self.value > self.maximumValue - self.stepValue) {
                    isPlus = value < self.minimumValue + self.stepValue
                    isMinus = isMinus && !isPlus
                } else if (self.value < self.minimumValue + self.stepValue) {
                    isMinus = value > self.maximumValue - self.stepValue
                    isPlus = isPlus && !isMinus
                }
            }
            
            if isPlus {
                self.plusMinusState = .plus
            } else if isMinus {
                self.plusMinusState = .minus
            }
        }
    }
}


open class MStepperCell: Cell<Int>, CellType {
    
    @IBOutlet public weak var stepper: MStepper!
    @IBOutlet public weak var valueLabel: UILabel?
    
    required public init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        let stepper = MStepper()
        self.stepper = stepper
        self.stepper.translatesAutoresizingMaskIntoConstraints = false
        
        let valueLabel = UILabel()
        self.valueLabel = valueLabel
        self.valueLabel?.translatesAutoresizingMaskIntoConstraints = false
        self.valueLabel?.numberOfLines = 1
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        addSubview(stepper)
        addSubview(valueLabel)
        
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[v]-[s]-|", options: .alignAllCenterY, metrics: nil, views: ["s": stepper, "v": valueLabel]))
        addConstraint(NSLayoutConstraint(item: stepper, attribute: .centerY, relatedBy: .equal, toItem: contentView, attribute: .centerY, multiplier: 1.0, constant: 0))
        addConstraint(NSLayoutConstraint(item: valueLabel, attribute: .centerY, relatedBy: .equal, toItem: stepper, attribute: .centerY, multiplier: 1.0, constant: 0))
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    open override func setup() {
        super.setup()
        selectionStyle = .none
        
        stepper.addTarget(self, action: #selector(MStepperCell.valueChanged), for: .valueChanged)
        stepper.addTarget(self, action: #selector(MStepperCell.stepperChanged), for: .valueChanged)
    }
    
    deinit {
        stepper.removeTarget(self, action: nil, for: .allEvents)
    }
    
    open override func update() {
        super.update()
        stepper.isEnabled = !row.isDisabled
        stepper.value = Double(row.value ?? 0)
        stepper.alpha = row.isDisabled ? 0.3 : 1.0
        valueLabel?.textColor = tintColor
        valueLabel?.alpha = row.isDisabled ? 0.3 : 1.0
        valueLabel?.text = row.displayValueFor?(row.value)
        detailTextLabel?.text = nil
    }
    
    @objc func stepperChanged(stepper: MStepper) {
        guard let row = self.row as? MStepperRow else { return }
        if stepper.plusMinusState == .plus {
            row.callbackOnPlusDidClick?()
        } else if stepper.plusMinusState == .minus {
            row.callbackOnMinusDidClick?()
        }
    }
    
    @objc func valueChanged() {
        row.value = stepper.value.toInt()
        row.updateCell()
    }
}

// MARK: MStepperRow

open class _MStepperRow: Row<MStepperCell> {
    required public init(tag: String?) {
        super.init(tag: tag)
        displayValueFor = { value in
            guard let value = value else { return nil }
            return "\(value)"
        }
    }
}

/// Double row that has a UIStepper as accessoryType
public final class MStepperRow: _MStepperRow, RowType {
    
    var callbackOnPlusDidClick: (() -> Void)?
    var callbackOnMinusDidClick: (() -> Void)?
    
    required public init(tag: String?) {
        super.init(tag: tag)
    }
    
    @discardableResult
    public func onPlusDidClick(_ callback: @escaping () -> Void) -> Self {
        callbackOnPlusDidClick = { () in callback() }
        return self
    }
    
    @discardableResult
    public func onMinusDidClick(_ callback: @escaping () -> Void) -> Self {
        callbackOnMinusDidClick = { () in callback() }
        return self
    }
}

fileprivate extension Double {
    func toInt() -> Int? {
        if self > Double(Int.min) && self < Double(Int.max) {
            return Int(self)
        } else {
            return nil
        }
    }
}
