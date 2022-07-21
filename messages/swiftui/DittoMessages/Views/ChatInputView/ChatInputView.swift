//
//  ChatInputView.swift
//  DittoMessages
//
//  Created by Maximilian Alexander on 7/18/22.
//

import SwiftUI

struct ChatInputView: View {

    @Binding var text: String
    var placeholder: String = "Message"

    var onSendButtonTappedCallback: (() -> Void)? = nil
    var onInputFocus: (() -> Void)? = nil

    var body: some View {
        HStack(alignment: .bottom) {
            Spacer(minLength: 12)
            HStack(alignment: .bottom) {
                ExpandingTextView(text: $text)
                    .padding(EdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 8))
                Button {
                    onSendButtonTappedCallback?()
                } label: {
                    Image(systemName: "arrow.up")
                        .padding(.all, 4)
                        .foregroundColor(Color.white)
                        .background(text.isEmpty ? Color.gray : Color.blue)
                        .clipShape(Circle())
                }
                .disabled(text.isEmpty)
                .padding(.bottom, 6)
                Spacer(minLength: 8)
            }
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(.secondary, lineWidth: 1)
            )
            .padding(.bottom, 12)
            Spacer(minLength: 12)
        }
    }


    func onSendButtonTapped(_ callback: (() -> Void)?) -> Self {
        var selfCopy = self
        selfCopy.onSendButtonTappedCallback = callback
        return selfCopy
    }

}

struct ChatInputView_Previews: PreviewProvider {
    static var previews: some View {
        ChatInputView(text: .constant("Hellosdfsdfsdfsdfsdfsdfsdfsdfsdfsdfsdfsdfsdfsdfsdfsdfsdfsdfsdfsdfsdfasdfasdfsdfsdfsdfsdf"))
    }
}
