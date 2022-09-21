//
//  TasksListScreen.swift
//  Tasks
//
//  Created by Maximilian Alexander on 8/26/21.
//

import SwiftUI
import DittoSwift

class TasksListScreenViewModel: ObservableObject {
    @Published var tasks = [Task]()
    @Published var isPresentingEditScreen: Bool = false

    private(set) var taskToEdit: Task? = nil

    let ditto: Ditto
    var liveQuery: DittoLiveQuery?

    init(ditto: Ditto) {
        self.ditto = ditto
        self.liveQuery = ditto.store["tasks"]
            .find("!isDeleted")
            .observe(eventHandler: {  docs, event in
                print(event.description)
                self.tasks = docs.map({ Task(document: $0) })
            })
        ditto.store["tasks"].find("isDeleted == true").evict()
    }

    func toggle(task: Task) {
        self.ditto.store["tasks"].findByID(task._id)
            .update { mutableDoc in
                guard let mutableDoc = mutableDoc else { return }
                mutableDoc["isCompleted"].set(!mutableDoc["isCompleted"].boolValue)
            }
    }

    func clickedBody(task: Task) {
        taskToEdit = task
        isPresentingEditScreen = true
    }

    func clickedPlus() {
        taskToEdit = nil
        isPresentingEditScreen = true
    }
}

struct TasksListScreen: View {

    let ditto: Ditto

    @ObservedObject var viewModel: TasksListScreenViewModel

    init(ditto: Ditto) {
        self.ditto = ditto
        self.viewModel = TasksListScreenViewModel(ditto: ditto)
    }

    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.tasks) { task in
                    TaskRow(task: task,
                        onToggle: { task in viewModel.toggle(task: task) },
                        onClickBody: { task in viewModel.clickedBody(task: task) }
                    )
                }
            }
            .navigationTitle("Tasks - SwiftUI")
            .navigationBarItems(trailing: Button(action: {
                viewModel.clickedPlus()
            }, label: {
                Image(systemName: "plus")
            }))
            .sheet(isPresented: $viewModel.isPresentingEditScreen, content: {
                EditScreen(ditto: ditto, task: viewModel.taskToEdit)
            })
        }
    }
}

struct TasksListScreen_Previews: PreviewProvider {
    static var previews: some View {
        TasksListScreen(ditto: Ditto())
    }
}
