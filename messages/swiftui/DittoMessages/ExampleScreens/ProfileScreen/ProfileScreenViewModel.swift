//
//  ProfileScreenViewModel.swift
//  DittoMessages
//
//  Created by Maximilian Alexander on 7/20/22.
//

import Foundation
import Combine

class ProfileScreenViewModel: ObservableObject {

    @Published var dismissDisabled = false
    @Published var saveButtonDisabled = false
    @Published var firstName: String = ""
    @Published var lastName: String = ""

    var cancellables = Set<AnyCancellable>()

    init() {

        DittoManager.shared
            .me()
            .map({ $0?.firstName ?? "" })
            .assign(to: \.firstName, on: self)
            .store(in: &cancellables)

        DittoManager.shared
            .me()
            .map({ $0?.lastName ?? "" })
            .assign(to: \.lastName, on: self)
            .store(in: &cancellables)

        UserDefaults.standard.userIdPublisher
            .map({ $0 == nil })
            .assign(to: \.dismissDisabled, on: self)
            .store(in: &cancellables)

        $firstName.combineLatest($lastName)
            .map({ firstName, lastName -> Bool in
                return firstName.isEmpty || lastName.isEmpty
            })
            .assign(to: \.saveButtonDisabled, on: self)
            .store(in: &cancellables)
    }

    func saveChanges() {
        DittoManager.shared.saveMe(firstName: firstName, lastName: lastName)
    }


}
