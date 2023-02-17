//
//  SolutionViewModel.swift
//  SwitchToLatestExample
//
//  Created by Maximilian Alexander on 8/10/22.
//

import Foundation
import DittoSwift
import Combine

class SolutionViewModel: ObservableObject {

    @Published var carrier: String = DittoManager.carriers.randomElement()!
    @Published var flights: [Flight] = []

    var cancellables = Set<AnyCancellable>()

    init() {

        $carrier
            .removeDuplicates() // useful to not run if the value is different
            .map({ carrier in 
                return DittoManager.shared.ditto.store.collection("flights").find("carrier == $args.carrier", args: ["carrier": carrier])
                    .liveQueryPublisher()
            })
            .switchToLatest()
            .map({ (docs, _) in
                return docs.map({ Flight(document: $0) })
            })
            .assign(to: \.flights, on: self)
            .store(in: &cancellables)
    }
}
