//
//  RoomEditScreenViewModel.swift
//  DittoMessages
//
//  Created by Maximilian Alexander on 7/20/22.
//

import Foundation
import Combine

class RoomEditScreenViewModel: ObservableObject {

    @Published var name: String = ""
    @Published var saveButtonDisabled = false

    var cancellables = Set<AnyCancellable>()

    init() {
        $name
            .map({ $0.isEmpty })
            .assign(to: \.saveButtonDisabled, on: self)
            .store(in: &cancellables)
    }

    func createRoom() {
        DittoManager.shared.createRoom(name: name)
    }

}
