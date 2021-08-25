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

        var cancellables = Set<AnyCancellable>()

        init() {
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
