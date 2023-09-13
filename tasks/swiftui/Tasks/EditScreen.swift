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
    var userId: String = ""

    private let _id: String?

    init(task: Task?, userId: String) {
        self._id = task?._id
        self.userId = userId

        canDelete = task != nil
        body = task?.body ?? ""
        isCompleted = task?.isCompleted ?? false
    }

    func save() {
        if let _id = _id {
            print("EditScreen.save(): CALLED TO UPDATE TASK")
            // the user is attempting to update
            DittoManager.shared.ditto.store["tasks"].findByID(_id).update({ mutableDoc in
                mutableDoc?["isCompleted"].set(self.isCompleted)
                mutableDoc?["body"].set(self.body)
            })
        }else {
            // the user is attempting to upsert
            var task: [String : Any] = [
                "body": body,
                "isCompleted": isCompleted,
                "isDeleted": false,
                "invitationIds": [:] as [String:Any?]
            ]
            
            if (userId != "") {
                task["invitationIds"] = [userId: true]
            }
            
            print("EditScreen.save(): CREATE NEW TASK")
            try! DittoManager.shared.ditto.store["tasks"].upsert(task)
        }
    }

    func delete() {
        guard let _id = _id else { return }
        DittoManager.shared.ditto.store["tasks"].findByID(_id).update { doc in
            doc?["isDeleted"].set(true)
        }
//        ditto.store["tasks"].findByID(_id).evict()
    }

}

struct EditScreen: View {

    @Environment(\.presentationMode) private var presentationMode
    @ObservedObject var viewModel: EditScreenViewModel

    init(task: Task?, userId: String) {
        viewModel = EditScreenViewModel(task: task, userId: userId)
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
        EditScreen(task: Task(body: "Get Milk", isCompleted: true, invitationIds: [:]), userId: "")
    }
}
