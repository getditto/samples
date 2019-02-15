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

import UIKit
import Chatto
import ChattoAdditions

// This is a dirty implementation that shows what's needed to add a new type of element
// @see DemoChatItemsDecorator

class NameModel: ChatItemProtocol {
    let uid: String
    static var chatItemType: ChatItemType {
        return "NameModel"
    }

    var type: String { return NameModel.chatItemType }
    let username: String

    init (uid: String, username: String) {
        self.uid = uid
        self.username = username
    }
}

public class NamePresenterBuilder: ChatItemPresenterBuilderProtocol {

    public func canHandleChatItem(_ chatItem: ChatItemProtocol) -> Bool {
        return chatItem is NameModel ? true : false
    }

    public func createPresenterWithChatItem(_ chatItem: ChatItemProtocol) -> ChatItemPresenterProtocol {
        assert(self.canHandleChatItem(chatItem))
        return NamePresenter(
            nameModel: chatItem as! NameModel
        )
    }

    public var presenterType: ChatItemPresenterProtocol.Type {
        return NamePresenter.self
    }
}

class NamePresenter: ChatItemPresenterProtocol {

    let nameModel: NameModel
    init (nameModel: NameModel) {
        self.nameModel = nameModel
    }

    static func registerCells(_ collectionView: UICollectionView) {
        collectionView.register(UINib(nibName: "NameCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "NameCollectionViewCell")
    }

    func dequeueCell(collectionView: UICollectionView, indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "NameCollectionViewCell", for: indexPath)
        return cell
    }

    func configureCell(_ cell: UICollectionViewCell, decorationAttributes: ChatItemDecorationAttributesProtocol?) {
        guard let statusCell = cell as? NameCollectionViewCell else {
            assert(false, "expecting status cell")
            return
        }

        let attrs = [
            NSAttributedStringKey.font: UIFont.systemFont(ofSize: 12.0),
            NSAttributedStringKey.foregroundColor: UIColor.black,
            NSAttributedStringKey.paragraphStyle: {
                let paragraph = NSMutableParagraphStyle()
                paragraph.alignment = self.nameModel.username != UserDefaults.standard.username ? .left : .right
                return paragraph
            }()
        ]
        statusCell.text = NSAttributedString(
            string: self.nameModel.username,
            attributes: attrs)
    }

    var canCalculateHeightInBackground: Bool {
        return true
    }

    func heightForCell(maximumWidth width: CGFloat, decorationAttributes: ChatItemDecorationAttributesProtocol?) -> CGFloat {
        return 30
    }
}
