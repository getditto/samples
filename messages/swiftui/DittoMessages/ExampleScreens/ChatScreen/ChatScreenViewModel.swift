//
//  ChatScreenViewmodel.swift
//  DittoMessages
//
//  Created by Maximilian Alexander on 7/20/22.
//

import Foundation
import Combine

class ChatScreenViewModel: ObservableObject {

    let roomId: String

    @Published var inputText: String = ""
    @Published var roomName: String = ""
    @Published var messagesWithUsers = [MessageWithUser]()

    var cancellables = Set<AnyCancellable>()

    init(roomId: String) {
        self.roomId = roomId
        let users = DittoManager.shared.allUsers()
        let messages = DittoManager.shared.messages(roomId: roomId)

        messages.combineLatest(users)
            .map({ messages, users -> [MessageWithUser] in
                var messagesWithUsers = [MessageWithUser]()
                for message in messages {
                    guard let user = users.first(where: { $0.id == message.userId }) else {
                        continue
                    }
                    messagesWithUsers.append(MessageWithUser(message: message, user: user))
                }
                return messagesWithUsers
            })
            .assign(to: \.messagesWithUsers, on: self)
            .store(in: &cancellables)

        DittoManager.shared.room(roomId: roomId)
            .map({ room -> String in
                if roomId == "public" {
                    return "Public Room"
                }
                return room?.name ?? ""
            })
            .assign(to: \.roomName, on: self)
            .store(in: &cancellables)
    }

    func sendMessage() {
        DittoManager.shared.createMessage(roomId: roomId, text: inputText)
        inputText = ""
    }

}
