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
import ChattoAdditions

class DemoChatMessageFactory {
    
    private static let demoText =
        "Lorem ipsum dolor sit amet 😇, https://github.com/badoo/Chatto consectetur adipiscing elit , sed do eiusmod tempor incididunt 07400000000 📞 ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore https://github.com/badoo/Chatto eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat 07400000000 non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."
    
    class func makeTextMessage(_ uid: String, text: String, username: String, timestamp: Date) -> DemoTextMessageModel {
        let messageModel = self.makeMessageModel(uid, username: username, type: TextMessageModel<MessageModel>.chatItemType, timestamp: timestamp)
        let textMessageModel = DemoTextMessageModel(messageModel: messageModel, text: text)
        return textMessageModel
    }

    class func makePhotoMessage(_ uid: String, image: UIImage, size: CGSize, username: String, timestamp: Date) -> DemoPhotoMessageModel {
        let messageModel = self.makeMessageModel(uid, username: username, type: PhotoMessageModel<MessageModel>.chatItemType, timestamp: timestamp)
        let photoMessageModel = DemoPhotoMessageModel(messageModel: messageModel, imageSize: size, image: image)
        return photoMessageModel
    }
    
    private class func makeMessageModel(_ uid: String, username: String, type: String, timestamp: Date) -> MessageModel {
        let messageStatus = MessageStatus.success
        let isIncoming = username != UserDefaults.standard.username
        return MessageModel(uid: uid, senderId: username, type: type, isIncoming: isIncoming, date: timestamp, status: messageStatus)
    }
}

extension TextMessageModel {
    static var chatItemType: ChatItemType {
        return "text"
    }
}

extension PhotoMessageModel {
    static var chatItemType: ChatItemType {
        return "photo"
    }
}
