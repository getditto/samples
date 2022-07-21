//
//  ProfileScreen.swift
//  DittoMessages
//
//  Created by Maximilian Alexander on 7/20/22.
//

import SwiftUI

struct ProfileScreen: View {

    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel = ProfileScreenViewModel()

    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("First Name", text: $viewModel.firstName)
                    TextField("Last Name", text: $viewModel.lastName)
                }
                Button {
                    viewModel.saveChanges()
                    dismiss()
                } label: {
                    Text("Save Changes")
                }
                .disabled(viewModel.saveButtonDisabled)
            }
            .navigationTitle("Profile")
            .toolbar(content: {
                ToolbarItemGroup(placement: .navigationBarLeading) {
                    if !viewModel.dismissDisabled {
                        Button {
                            dismiss()
                        } label: {
                            Text("Cancel")
                        }
                    }
                }
            })
            .interactiveDismissDisabled(viewModel.dismissDisabled)
        }
    }
}

struct ProfileScreen_Previews: PreviewProvider {
    static var previews: some View {
        ProfileScreen()
    }
}
