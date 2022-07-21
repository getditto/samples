//
//  MessageBubble.swift
//  DittoMessages
//
//  Created by Maximilian Alexander on 7/20/22.
//  Credits to: https://prafullkumar77.medium.com/swiftui-creating-a-chat-bubble-like-imessage-using-path-and-shape-67cf23ccbf62
//

import SwiftUI

struct MessageBubbleView: View {

    let messageWithUser: MessageWithUser

    private var direction: MessageBubbleShape.Direction {
        if messageWithUser.user.id == UserDefaults.standard.userId {
            return .right
        }
        return .left
    }

    private var formatter: DateFormatter {
        let f = DateFormatter()
        f.timeStyle = .short
        return f
    }

    private var backgroundColor: Color {
        if direction == .left {
            return Color(UIColor.tertiarySystemFill)
        }
        return Color.blue
    }

    private var textColor: Color {
        if direction == .left {
            return Color(UIColor.label)
        }
        return Color.white
    }
    
    init(messageWithUser: MessageWithUser) {
        self.messageWithUser = messageWithUser
    }

    var edgeInsets: EdgeInsets {
        switch direction {
        case .left:
            return EdgeInsets(top: 2, leading: 20, bottom: 0, trailing: 20)
        case .right:
            return EdgeInsets(top: 2, leading: 20, bottom: 0, trailing: 20)
        }
    }

    var body: some View {
        HStack {
            if direction == .right {
                Spacer()
            }
            VStack(alignment: direction == .right ? .trailing : .leading, spacing: 2) {
                Text(messageWithUser.message.text)
                Text(formatter.string(from: messageWithUser.message.createdOn))
                    .font(.system(size: UIFont.smallSystemFontSize))
            }
            .padding(EdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16))
            .background(backgroundColor)
            .foregroundColor(textColor)
            .clipShape(MessageBubbleShape(direction: direction))
            if direction == .left {
                Spacer()
            }
        }
        .padding(edgeInsets)
    }
}

struct MessageBubbleShape: Shape {

    enum Direction {
        case left
        case right
    }

    let direction: Direction

    func path(in rect: CGRect) -> Path {
        return (direction == .left) ? getLeftBubblePath(in: rect) : getRightBubblePath(in: rect)
    }

    private func getLeftBubblePath(in rect: CGRect) -> Path {
        let width = rect.width
        let height = rect.height
        let path = Path { p in
            p.move(to: CGPoint(x: 25, y: height))
            p.addLine(to: CGPoint(x: width - 20, y: height))
            p.addCurve(to: CGPoint(x: width, y: height - 20),
                       control1: CGPoint(x: width - 8, y: height),
                       control2: CGPoint(x: width, y: height - 8))
            p.addLine(to: CGPoint(x: width, y: 20))
            p.addCurve(to: CGPoint(x: width - 20, y: 0),
                       control1: CGPoint(x: width, y: 8),
                       control2: CGPoint(x: width - 8, y: 0))
            p.addLine(to: CGPoint(x: 21, y: 0))
            p.addCurve(to: CGPoint(x: 4, y: 20),
                       control1: CGPoint(x: 12, y: 0),
                       control2: CGPoint(x: 4, y: 8))
            p.addLine(to: CGPoint(x: 4, y: height - 11))
            p.addCurve(to: CGPoint(x: 0, y: height),
                       control1: CGPoint(x: 4, y: height - 1),
                       control2: CGPoint(x: 0, y: height))
            p.addLine(to: CGPoint(x: -0.05, y: height - 0.01))
            p.addCurve(to: CGPoint(x: 11.0, y: height - 4.0),
                       control1: CGPoint(x: 4.0, y: height + 0.5),
                       control2: CGPoint(x: 8, y: height - 1))
            p.addCurve(to: CGPoint(x: 25, y: height),
                       control1: CGPoint(x: 16, y: height),
                       control2: CGPoint(x: 20, y: height))

        }
        return path
    }

    private func getRightBubblePath(in rect: CGRect) -> Path {
        let width = rect.width
        let height = rect.height
        let path = Path { p in
            p.move(to: CGPoint(x: 25, y: height))
            p.addLine(to: CGPoint(x:  20, y: height))
            p.addCurve(to: CGPoint(x: 0, y: height - 20),
                       control1: CGPoint(x: 8, y: height),
                       control2: CGPoint(x: 0, y: height - 8))
            p.addLine(to: CGPoint(x: 0, y: 20))
            p.addCurve(to: CGPoint(x: 20, y: 0),
                       control1: CGPoint(x: 0, y: 8),
                       control2: CGPoint(x: 8, y: 0))
            p.addLine(to: CGPoint(x: width - 21, y: 0))
            p.addCurve(to: CGPoint(x: width - 4, y: 20),
                       control1: CGPoint(x: width - 12, y: 0),
                       control2: CGPoint(x: width - 4, y: 8))
            p.addLine(to: CGPoint(x: width - 4, y: height - 11))
            p.addCurve(to: CGPoint(x: width, y: height),
                       control1: CGPoint(x: width - 4, y: height - 1),
                       control2: CGPoint(x: width, y: height))
            p.addLine(to: CGPoint(x: width + 0.05, y: height - 0.01))
            p.addCurve(to: CGPoint(x: width - 11, y: height - 4),
                       control1: CGPoint(x: width - 4, y: height + 0.5),
                       control2: CGPoint(x: width - 8, y: height - 1))
            p.addCurve(to: CGPoint(x: width - 25, y: height),
                       control1: CGPoint(x: width - 16, y: height),
                       control2: CGPoint(x: width - 20, y: height))

        }
        return path
    }
}

import Fakery

struct MessageBubbleView_Previews: PreviewProvider {

    static let faker = Faker()

    static var messagesWithUsers: [MessageWithUser] = [
        MessageWithUser(message: Message(id: UUID().uuidString, text: Self.faker.lorem.sentence(), createdOn: Date(), userId: "max", roomId: "public"), user: User(id: "max", firstName: "Maximilian", lastName: "Alexander")),
        MessageWithUser(message: Message(id: UUID().uuidString, text: Self.faker.lorem.sentence(), createdOn: Date(), userId: "max", roomId: "public"), user: User(id: "max", firstName: "Maximilian", lastName: "Alexander")),
    ]

    static var previews: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(messagesWithUsers) { m in
                    MessageBubbleView(messageWithUser: m)
                }
            }
        }
    }
}
