//
//  ContentView.swift
//  Tasks
//
//  Created by Maximilian Alexander on 8/16/21.
//

import SwiftUI
import Combine
import CombineDitto

struct TasksListView: View {

    class ViewModel: ObservableObject {

        @Published var tasks = [Task]()
        @Published var selectedTask: Task?
        @Published var isShowingEditSheet = false

        @Published var isErrored: Bool = false
        @Published var errorMessage: String?

        var cancellables = Set<AnyCancellable>()

        init() {
            do {
                try AppDelegate.ditto.setLicenseToken("<REPLACE_ME>")
                try AppDelegate.ditto.tryStartSync()
            } catch (let err) {
                self.isErrored = true
                self.errorMessage = err.localizedDescription
            }

            AppDelegate.ditto.store["tasks"].findAll()
                .publisher()
                .map({ (snapshot) in
                    return snapshot.documents.map{ doc in try! doc.typed(as: Task.self).value }
                })
                .eraseToAnyPublisher()
                .assign(to: \.tasks, on: self)
                .store(in: &cancellables)
        }

        deinit {
            cancellables.removeAll()
        }

        func delete(_id: String) {
            AppDelegate.ditto.store["tasks"].findByID(_id).remove()
        }

        func toggle(_id: String) {
            AppDelegate.ditto.store["tasks"].findByID(_id).update { mutableDoc in
                guard let mutableDoc = mutableDoc else { return }
                mutableDoc["isCompleted"].set(!mutableDoc["isCompleted"].boolValue)
            }
        }

    }

    @ObservedObject var viewModel = ViewModel()

    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.tasks, id: \._id) { task in
                    HStack {
                        Image(systemName: task.isCompleted ? "largecircle.fill.circle" : "circle")
                            .onTapGesture {
                                viewModel.toggle(_id: task._id)
                            }
                        Text(task.body)
                            .onTapGesture {
                                viewModel.selectedTask = task
                                viewModel.isShowingEditSheet = true
                            }
                    }
                }
                .onDelete(perform: { indexSet in
                    indexSet.forEach { i in
                        viewModel.delete(_id: viewModel.tasks[i]._id)
                    }
                })
            }
            .alert(isPresented: $viewModel.isErrored) {
                let errorMessage = viewModel.errorMessage ?? ""
                return Alert(title: Text("Uh oh"), message: Text("There was an error starting Ditto. That's okay, it'll still work as a local database. Here's the error:\n \(errorMessage)"), dismissButton: .default(Text("Got it!")))
            }
            .sheet(isPresented: $viewModel.isShowingEditSheet, content: {
                NavigationView {
                    EditTaskView(task: viewModel.selectedTask, isSheetPresented: $viewModel.isShowingEditSheet)
                }
            })
            .navigationTitle("Tasks")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        viewModel.selectedTask = nil
                        viewModel.isShowingEditSheet = true
                    }, label: {
                        Image(systemName: "plus")
                    })
                }
            }
        }
    }
}

struct TasksListView_Previews: PreviewProvider {
    static var previews: some View {
        TasksListView()
    }
}
