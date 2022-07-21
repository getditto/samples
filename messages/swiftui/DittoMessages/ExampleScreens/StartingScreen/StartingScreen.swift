//
//  StartingScreen.swift
//  DittoMessages
//
//  Created by Maximilian Alexander on 7/20/22.
//

import SwiftUI

struct StartingScreen: View {

    @ObservedObject var viewModel = StartingScreenViewModel()

    var body: some View {
        NavigationView {
            List {
                Section {
                    NavigationLink {
                        ChatScreen(roomId: "public")
                    } label: {
                        Label("Public Room", systemImage: "message.fill")
                    }
                }
                Section {
                    ForEach(viewModel.rooms) { room in
                        NavigationLink {
                            ChatScreen(roomId: room.id)
                        } label: {
                            Label(room.name, systemImage: "message")
                        }
                    }
                }
            }
            .navigationTitle("Ditto SwiftUI Chat")
            .sheet(isPresented: $viewModel.presentProfileScreen) {
                ProfileScreen()
            }
            .sheet(isPresented: $viewModel.presentCreateRoomScreen) {
                RoomEditScreen()
            }
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarLeading ) {
                    Button {
                        viewModel.tappedProfileButton()
                    } label: {
                        Image(systemName: "person.circle")
                    }
                }
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button {
                        viewModel.createRoomButtonClicked()
                    } label: {
                        Label("New Room", systemImage: "plus.message.fill")
                    }
                }
            }
        }
    }
}

struct StartingScreen_Previews: PreviewProvider {
    static var previews: some View {
        StartingScreen()
    }
}
