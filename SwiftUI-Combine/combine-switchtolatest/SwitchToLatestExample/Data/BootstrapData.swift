//
//  BootstrapData.swift
//  SwitchToLatestExample
//
//  Created by Maximilian Alexander on 8/10/22.
//

import Foundation
import DittoSwift

struct DittoManager {

    static let shared = DittoManager()

    let ditto: Ditto

    static let carriers = ["BA", "LH", "UA", "AS", "JL", "DL", "AF"]

    init() {
        self.ditto = Ditto()
        guard ditto.store.collection("flights").findAll().exec().count == 0 else {
            // no need to bootstrap data if there are documents already in the store
            return
        }

        let airports = ["JFK", "LHR", "ORD", "SEA", "LGA", "FRA", "CDG", "MEX", "ATL"]
        var dataSet: Array<[String: Any]> = []

        for i in 1...1000 {
            let from = airports.randomElement()!
            let to = airports.filter({ $0 != from }).randomElement()!
            dataSet.append([
                "_id": i,
                "carrier": Self.carriers.randomElement()!,
                "number": Int.random(in: 1...9999),
                "from": from,
                "to": to
            ])
        }

        ditto.store.write { transaction in
            dataSet.forEach { data in
                try! transaction["flights"].upsert(data)
            }
        }
    }

}
