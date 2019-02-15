/*
 The MIT License (MIT)

 Copyright (c) 2015-present Badoo Trading Limited.

 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
*/

import Foundation
import Chatto
import Ditto

class DemoChatDataSource: ChatDataSourceProtocol {
    
    var disposable: Disposable?

    init() {
        
        // Reading ACCESS_TOKEN.txt file.
        let ACCESS_TOKEN = try! String(contentsOfFile: Bundle.main.path(forResource: "ACCESS_TOKEN", ofType: "txt")!)
        
        DittoMeshKit.set(accessToken: ACCESS_TOKEN)
        DittoMeshKit.set(userIdentifier: UserDefaults.standard.username)
        DittoMeshKit.set(displayName: "\(UserDefaults.standard.username)-device")
        DittoMeshKit.set(siteId: UserDefaults.standard.siteId)
        DittoMeshKit.set(applicationId: "dittochat")
        DittoMeshKit.shared().minimumLogLevel = .debug
        DittoMeshKit.shared().start()
        
        
        do {
            var fireCount: Int = 0
            self.disposable = try DittoMeshKit.shared().collection("room").find().observe({ [weak self] (docs, changes) in
                guard let `self` = self else { return }
                fireCount += 1
                self.setFromStore(docs: docs, isFirstLoad: fireCount == 1)
            })
        } catch  {
            fatalError()
        }
        
    }

    lazy var messageSender: DemoChatMessageSender = {
        let sender = DemoChatMessageSender()
        sender.onMessageChanged = { [weak self] (message) in
            guard let sSelf = self else { return }
            sSelf.delegate?.chatDataSourceDidUpdate(sSelf)
        }
        return sender
    }()

    var hasMoreNext: Bool {
        return false
    }

    var hasMorePrevious: Bool {
        return false
    }

    var chatItems: [ChatItemProtocol] = []

    weak var delegate: ChatDataSourceDelegateProtocol?

    func loadNext() {
        
    }

    func loadPrevious() {
        
    }

    func addTextMessage(_ text: String) {
        _ = try? DittoMeshKit.shared().collection("room").write({ (tx) in
            tx.insert([
                "body": text,
                "timestamp": Date().timeIntervalSince1970,
                "username": UserDefaults.standard.username
            ])
        })
    }
    
    func setFromStore(docs: [Document], isFirstLoad: Bool) {
        var chatMessages: [DemoTextMessageModel] = []
        for doc in docs {
            let _id: String = doc["_id"] as! String
            let body: String = (doc["body"] as! String)
            let username: String = doc["username"] as! String
            let timestampNumber = doc["timestamp"] as! NSNumber
            let timestamp: Date = Date(timeIntervalSince1970: TimeInterval(timestampNumber.doubleValue))
            let message = DemoChatMessageFactory.makeTextMessage(_id, text: body, username: username, timestamp: timestamp)
            chatMessages.append(message)
        }
        self.chatItems = chatMessages.sorted(by: { (a, b) -> Bool in
            return a.date < b.date
        })
        self.delegate?.chatDataSourceDidUpdate(self, updateType: isFirstLoad ? .firstLoad : .normal)
    }

    func adjustNumberOfMessages(preferredMaxCount: Int?, focusPosition: Double, completion:(_ didAdjust: Bool) -> Void) {
        
    }
    
    deinit {
        disposable?.dispose()
    }
}
