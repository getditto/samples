//
//  RoomEditScreen.swift
//  DittoMessages
//
//  Created by Maximilian Alexander on 7/20/22.
//

import SwiftUI

struct RoomEditScreen: View {

    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel = RoomEditScreenViewModel()

    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("Room Name", text: $viewModel.name)
                }
                Section {
                    Button {
                        viewModel.createRoom()
                        dismiss()
                    } label: {
                        Text("Create Room")
                    }
                    .disabled(viewModel.saveButtonDisabled)
                }
            }
            .navigationTitle("Create Room")
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Text("Cancel")
                    }

                }
            }
        }
    }
}

struct RoomEditScreen_Previews: PreviewProvider {
    static var previews: some View {
        RoomEditScreen()
    }
}
