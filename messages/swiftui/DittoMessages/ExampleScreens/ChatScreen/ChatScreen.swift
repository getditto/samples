//
//  ChatScreen.swift
//  DittoMessages
//
//  Created by Maximilian Alexander on 7/20/22.
//

import SwiftUI

struct ChatScreen: View {

    @ObservedObject var viewModel: ChatScreenViewModel

    init(roomId: String = "public") {
        viewModel = ChatScreenViewModel(roomId: roomId)
    }

    var body: some View {
        VStack {
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(viewModel.messagesWithUsers) { m in
                            MessageBubbleView(messageWithUser: m)
                                .id(m.id)
                                .transition(.slide)
                        }
                    }
                }
                .onChange(of: viewModel.messagesWithUsers.count, perform: { value in
                    withAnimation {
                        proxy.scrollTo(viewModel.messagesWithUsers.last?.id)
                    }
                })
            }
            ChatInputView(text: $viewModel.inputText)
                .onSendButtonTapped {
                    viewModel.sendMessage()
                }
        }
        .navigationTitle(viewModel.roomName)
        .frame(
            minWidth: 0,
            maxWidth: .infinity,
            minHeight: 0,
            maxHeight: .infinity,
            alignment: .topLeading
        )
    }
}

struct ChatScreen_Previews: PreviewProvider {
    static var previews: some View {
        ChatScreen()
    }
}
