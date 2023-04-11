//
//  ProblemViewModel.swift
//  SwitchToLatestExample
//
//  Created by Maximilian Alexander on 8/10/22.
//

import Foundation
import DittoSwift
import Combine

class ProblemViewModel: ObservableObject {

    @Published var carrier: String = DittoManager.carriers.randomElement()!
    @Published var flights: [Flight] = []

    var cancellables = Set<AnyCancellable>()

    init() {
        $carrier.sink { carrier in
            DittoManager.shared.ditto.store.collection("flights").find("carrier == $args.carrier", args: ["carrier": carrier])
                .liveQueryPublisher()
                .sink { (docs, _) in
                    self.flights = docs.map({ Flight(document: $0) })
                }
                .store(in: &self.cancellables)
        }
        .store(in: &cancellables)
    }
}
