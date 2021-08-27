//
//  EditTaskView.swift
//  Tasks
//
//  Created by Maximilian Alexander on 8/16/21.
//

import SwiftUI
import CombineDitto
import Combine

struct EditTaskView: View {

    class ViewModel: ObservableObject {

        @Published var canDelete: Bool
        @Published var body: String
        @Published var isCompleted: Bool

        var task: Task?

        init(task: Task?) {
            self.task = task
            self.body = task?.body ?? ""
            self.canDelete = task != nil;
            self.isCompleted = task?.isCompleted ?? false
        }

        func save() {
            if let task = task {
                // the user is attempting to update
                AppDelegate.ditto.store["tasks"].findByID(task._id).update { mutableDoc in
                    guard let mutableDoc = mutableDoc else { return }
                    mutableDoc["isCompleted"].set(self.isCompleted)
                    mutableDoc["body"].set(self.body)
                }
            } else {
                // the user is attempting to create
                let task = Task(_id: UUID().uuidString, body: body, isCompleted: isCompleted)
                try! AppDelegate.ditto.store["tasks"].insert(task)
            }
        }

        func delete() {
            guard let task = task else { return }
            AppDelegate.ditto.store["tasks"].findByID(task._id).remove()
        }
    }

    var isSheetPresented: Binding<Bool>
    @ObservedObject var viewModel: ViewModel

    init(task: Task?, isSheetPresented: Binding<Bool>) {
        self.viewModel = ViewModel(task: task)
        self.isSheetPresented = isSheetPresented
    }

    var body: some View {
        Form {
            Section {
                VStack(alignment: .leading) {
                    Text("Body:")
                    TextEditor(text: $viewModel.body)
                        .frame(minHeight: 80)
                }
                VStack(alignment: .leading) {
                    Toggle("Is Completed", isOn: $viewModel.isCompleted)
                }
            }
            Section {
                Button("Save") {
                    viewModel.save()
                    isSheetPresented.wrappedValue = false
                }
            }
        }
        .toolbar(content: {
            ToolbarItemGroup(placement: .navigationBarLeading) {
                Button(action: {
                    isSheetPresented.wrappedValue = false
                }, label: {
                    Text("Cancel")
                })
            }
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                if viewModel.canDelete {
                    Button(action: {
                        viewModel.delete()
                        isSheetPresented.wrappedValue = false
                    }, label: {
                        Image(systemName: "trash")
                    })
                }
            }
        })
        .navigationTitle(viewModel.task == nil ? "Create Task": "Edit Task")

    }
}

struct EditTaskView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            EditTaskView(task: nil, isSheetPresented: .constant(true))
        }
    }
}
