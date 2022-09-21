//
//  EditScreen.swift
//  Tasks
//
//  Created by Maximilian Alexander on 8/27/21.
//

import SwiftUI
import DittoSwift

class EditScreenViewModel: ObservableObject {

    @Published var canDelete: Bool = false
    @Published var body: String = ""
    @Published var isCompleted: Bool = false

    private let _id: String?
    private let ditto: Ditto

    init(ditto: Ditto, task: Task?) {
        self._id = task?._id
        self.ditto = ditto

        canDelete = task != nil
        body = task?.body ?? ""
        isCompleted = task?.isCompleted ?? false
    }

    func save() {
        if let _id = _id {
            // the user is attempting to update
            ditto.store["tasks"].findByID(_id).update({ mutableDoc in
                mutableDoc?["isCompleted"].set(self.isCompleted)
                mutableDoc?["body"].set(self.body)
            })
        }else {
            // the user is attempting to upsert
            try! ditto.store["tasks"].upsert([
                "body": body,
                "isCompleted": isCompleted,
                "isDeleted": false
            ])
        }
    }

    func delete() {
        guard let _id = _id else { return }
        ditto.store["tasks"].findByID(_id).update { doc in
            doc?["isDeleted"].set(true)
        }
//        ditto.store["tasks"].findByID(_id).evict()
    }

}

struct EditScreen: View {

    @Environment(\.presentationMode) private var presentationMode
    @ObservedObject var viewModel: EditScreenViewModel

    init(ditto: Ditto, task: Task?) {
        viewModel = EditScreenViewModel(ditto: ditto, task: task)
    }

    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("Body", text: $viewModel.body)
                    Toggle("Is Completed", isOn: $viewModel.isCompleted)
                }
                Section {
                    Button(action: {
                        viewModel.save()
                        self.presentationMode.wrappedValue.dismiss()
                    }, label: {
                        Text(viewModel.canDelete ? "Save" : "Create")
                    })
                }
                if viewModel.canDelete {
                    Section {
                        Button(action: {
                            viewModel.delete()
                            self.presentationMode.wrappedValue.dismiss()
                        }, label: {
                            Text("Delete")
                                .foregroundColor(.red)
                        })
                    }
                }
            }
            .navigationTitle(viewModel.canDelete ? "Edit Task": "Create Task")
            .navigationBarItems(trailing: Button(action: {
                self.presentationMode.wrappedValue.dismiss()
            }, label: {
                Text("Cancel")
            }))
        }
    }
}

struct EditScreen_Previews: PreviewProvider {
    static var previews: some View {
        EditScreen(ditto: Ditto(), task: Task(body: "Get Milk", isCompleted: true))
    }
}
