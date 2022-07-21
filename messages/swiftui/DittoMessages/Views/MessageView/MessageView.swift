//
//  MessageBubble.swift
//  DittoMessages
//
//  Created by Maximilian Alexander on 7/18/22.
//

import SwiftUI



struct MessageView: View {

    static var timeFormat: DateFormatter {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }

    var name: String?
    var bodyText: String
    var createdOn: Date

    var body: some View {
        VStack(alignment: .leading) {
            if let name = name {
                Text(name)
                    .bold()
            }
            Text(bodyText)
            Text(Self.timeFormat.string(from: createdOn))
                .fontWeight(.light)
                .font(.footnote)
        }
    }
}

struct MessageView_Previews: PreviewProvider {
    static var previews: some View {
        LazyVStack(alignment: .leading) {
            MessageView(
                name: "Maximilian", bodyText: "Hello World", createdOn: Date()
            )
        }
    }
}
