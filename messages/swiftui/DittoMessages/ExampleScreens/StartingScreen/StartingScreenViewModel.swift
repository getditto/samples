//
//  StartingScreenViewModel.swift
//  DittoMessages
//
//  Created by Maximilian Alexander on 7/20/22.
//

import Foundation
import Combine

class StartingScreenViewModel: ObservableObject {

    @Published var presentProfileScreen: Bool = false
    @Published var presentCreateRoomScreen = false
    @Published var rooms: [Room] = []

    var cancellables = Set<AnyCancellable>()

    init() {
        presentProfileScreen = UserDefaults.standard.userId == nil

        DittoManager
            .shared
            .allRooms()
            .assign(to: \.rooms, on: self)
            .store(in: &cancellables)
    }

    func tappedProfileButton() {
        presentProfileScreen = true
    }

    func createRoomButtonClicked() {
        presentCreateRoomScreen = true
    }
}
