//
//  ContentView.swift
//  SwitchToLatestExample
//
//  Created by Maximilian Alexander on 8/10/22.
//

import SwiftUI
import Combine

struct StartingPage: View {
    var body: some View {
        NavigationView {
            VStack {
                List {
                    NavigationLink("Problem - improper usage") {
                        ProblemPage()
                    }
                    NavigationLink("Solution - with switchToLatest") {
                        SolutionPage()
                    }
                }
                VStack(spacing: 16) {
                    Text("Note, this example uses Ditto as a local store only and does not use the peer to peer synchronization for illustration purposes")
                    Link("Visit switchToLatest() Apple Docs", destination: URL(string: "https://developer.apple.com/documentation/combine/publisher/switchtolatest()-453ht")!)
                    Link("Visit Ditto Docs", destination: URL(string: "https://docs.ditto.live")!)
                }
                .padding()
            }
            .navigationTitle("switchToLatest()")

        }
    }
}

struct StartingPage_Previews: PreviewProvider {
    static var previews: some View {
        StartingPage()
    }
}
