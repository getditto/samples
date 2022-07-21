//
//  MessageBubble.swift
//  DittoMessages
//
//  Created by Maximilian Alexander on 7/18/22.
//

import SwiftUI

struct MessageView: View {

    var name: String?
    var bodyText: String

    var body: some View {
        VStack(alignment: .leading) {
            if let name = name {
                Text(name)
                    .bold()
            }
            Text(bodyText)
        }

    }
}

struct MessageBubble_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            VStack(alignment: .leading) {
                MessageView(
                    name: "Maximilian", bodyText: "Hello World"
                )
            }
            .frame(minWidth: .infinity)
        }
    }
}
