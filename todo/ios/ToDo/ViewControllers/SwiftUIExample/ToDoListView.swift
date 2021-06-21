//
//  ToDoListView.swift
//  ToDo
//
//  Created by Maximilian Alexander on 6/19/21.
//

import SwiftUI
import DittoSwift
import Combine
import CombineDitto

struct ToDoListView: View {

    @ObservedObject var dataSource: DataSource
    @State private var newText: String = ""

    var body: some View {
        List {
            Section(header: Text("Create new to do")) {
                HStack {
                    TextField("New To Do", text: $newText)
                    Button(action: {}) {
                        Text("Add")
                            .fontWeight(.bold)
                            .padding()
                    }.onTapGesture {
                        dataSource.add(text: newText)
                        newText = ""
                    }
                }
            }
            Section(header: Text("Current to do items"))  {
                ForEach(dataSource.todos, id: \.id) { todo in
                    HStack(spacing: 10) {
                        Button(action: {
                            dataSource.toggle(id: todo.id, isDone: !todo.isDone)
                        }){
                            Image(todo.isDone ? "box_checked": "box_empty").scaledToFit()
                        }
                        Text(todo.body)
                    }
                    .transition(AnyTransition.opacity)
                    .buttonStyle(PlainButtonStyle())

                }.onDelete(perform: dataSource.delete)
                .animation(.default)
            }
        }
        .navigationTitle("SwiftUI ToDo Example")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    dataSource.deleteAll()
                }, label: {
                    Image(systemName: "trash")
                })
            }
        }
        .onAppear(perform: {
            dataSource.start()
        })
    }
}

struct ToDoListView_Previews: PreviewProvider {
    static var previews: some View {
        ToDoListView(dataSource: DataSource())
    }
}


class DataSource: ObservableObject {

    @Published var todos = [ToDo]()
    var cancellables = Set<AnyCancellable>()

    private let todoPublisher = AppDelegate.ditto.store["todos"].findAll().publisher()

    func start() {
        todoPublisher
            .map({ snapshot in
                return snapshot
                    .documents.map({ ToDo($0) })
            })
            .assign(to: &$todos)
    }

    func add(text: String) {
        try! AppDelegate.ditto.store["todos"].insert([
            "body": text,
            "isDone": false
        ])
    }

    func toggle(id: String, isDone: Bool) {
        AppDelegate.ditto.store["todos"].findByID(id).update { mutableDoc in
            mutableDoc?["isDone"].set(isDone)
        }
    }

    func delete(_ indexSet: IndexSet) {
        let todoIds = indexSet.map({ todos[$0].id })
        todoIds.forEach { id in
            AppDelegate.ditto.store["todos"].findByID(id).remove()
        }
    }

    func deleteAll() {
        AppDelegate.ditto.store["todos"].findAll().remove()
    }
}
