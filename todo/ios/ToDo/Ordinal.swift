//
//  Ordinal.swift
//  ToDo
//
//  Created by Maximilian Alexander on 6/11/21.
//

import Foundation

import Foundation

protocol Ordinal {
    var ordinal: Float { get }
}

/// Calculate the ordinal float for a dragged item in a multi-section view
func calculateOrdinal(sourceIndex: Int, destinationIndex: Int, items: [Ordinal], differentSection: Bool) -> Float {
    let newOrdinal: Float
    if destinationIndex == 0 {
        if let oldFirst = items.first?.ordinal {
            newOrdinal = oldFirst - 1.0
        } else {
            newOrdinal = 0.0
        }
    } else if (!differentSection && destinationIndex == items.count - 1)
                || (differentSection && destinationIndex == items.count) {
        if let oldLast = items.last?.ordinal {
            newOrdinal = oldLast + 1.0
        } else {
            newOrdinal = 0.0
        }
    } else {
        var indexAbove = destinationIndex - 1
        var indexBelow = destinationIndex
        if !differentSection {
            if indexAbove >= sourceIndex {
                indexAbove += 1
                indexBelow += 1
            }
        }
        let lower = items[indexAbove].ordinal
        let upper = items[indexBelow].ordinal
        newOrdinal = (lower + upper) / 2.0
    }
    return newOrdinal
}
