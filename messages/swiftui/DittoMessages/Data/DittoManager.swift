//
//  DittoManager.swift
//  DittoMessages
//
//  Created by Maximilian Alexander on 7/20/22.
//

import Foundation
import DittoSwift
import Combine

class DittoManager {

    static let shared = DittoManager()

    private let ditto: Ditto

    init() {
        ditto = Ditto()
        try! ditto.setOfflineOnlyLicenseToken("REPLACE_ME")
        try! ditto.startSync()
    }

    func me() -> AnyPublisher<User?, Never> {
        UserDefaults.standard.userIdPublisher
            .map({ userId -> AnyPublisher<User?, Never> in
                guard let userId = userId else {
                    return Just<User?>(nil).eraseToAnyPublisher()
                }
                return self.ditto.store.collection("users").findByID(userId).singleDocumentLiveQueryPublisher()
                    .map({ doc, _ in
                        guard let doc = doc else { return nil }
                        return User(id: doc["_id"].stringValue, firstName: doc["firstName"].stringValue, lastName: doc["lastName"].stringValue)
                    })
                    .eraseToAnyPublisher()
            })
            .switchToLatest()
            .eraseToAnyPublisher()
    }

    func saveMe(firstName: String, lastName: String) {
        if UserDefaults.standard.userId == nil {
            UserDefaults.standard.userId = UUID().uuidString
        }

        let _ = try? self.ditto.store.collection("users").upsert([
            "_id": UserDefaults.standard.userId,
            "firstName": firstName,
            "lastName": lastName
        ])
    }

    func allUsers() -> AnyPublisher<[User], Never>  {
        return ditto.store.collection("users").findAll().liveQueryPublisher()
            .map({ docs, _ in
                return docs.map({ doc in
                    return User(id: doc["_id"].stringValue, firstName: doc["firstName"].stringValue, lastName: doc["lastName"].stringValue)
                })
            })
            .eraseToAnyPublisher()
    }

    func messages(roomId: String) -> AnyPublisher<[Message], Never> {
        let formatter = ISO8601DateFormatter()
        return ditto.store.collection("messages")
            .find("roomId == $args.roomId", args: ["roomId": roomId])
            .sort("createdOn", direction: .ascending)
            .liveQueryPublisher()
            .map({ docs, _ in
                return docs.map({ doc in
                    return Message(
                        id: doc["_id"].stringValue,
                        text: doc["text"].stringValue,
                        createdOn: formatter.date(from: doc["createdOn"].stringValue)!,
                        userId: doc["userId"].stringValue,
                        roomId: doc["roomId"].stringValue)
                })
            })
            .eraseToAnyPublisher()
    }

    func createMessage(roomId: String, text: String) {
        guard let userId = UserDefaults.standard.userId else { return }
        try! ditto.store.collection("messages")
            .upsert([
                "createdOn": ISO8601DateFormatter().string(from: Date()),
                "text": text,
                "roomId": roomId,
                "userId": userId
            ])
    }

    func allRooms() -> AnyPublisher<[Room], Never> {
        return ditto.store.collection("rooms")
            .findAll()
            .sort("createdOn", direction: .ascending)
            .liveQueryPublisher()
            .map({ docs, _ in
                return docs.map({ Room(document: $0) })
            })
            .eraseToAnyPublisher()
    }

    func room(roomId: String) -> AnyPublisher<Room?, Never> {
        ditto.store.collection("rooms")
            .findByID(roomId)
            .singleDocumentLiveQueryPublisher()
            .map { doc, _  in
                guard let doc = doc else { return nil }
                return Room(document: doc)
            }
            .eraseToAnyPublisher()
    }

    func createRoom(name: String) {
        try! ditto.store.collection("rooms")
            .upsert([
                "_id": UUID().uuidString,
                "name": name,
                "createdOn": ISO8601DateFormatter().string(from: Date())
            ])
    }

}
