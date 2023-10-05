//
//  TasksListScreen.swift
//  Tasks
//
//  Created by Maximilian Alexander on 8/26/21.
//

import SwiftUI
import DittoSwift

//------------------------------------------------------------------------------------------
// TEST smallPeerInfo with v4.4.0 on portal-dev.ditto.live
extension TasksListScreenViewModel {
    func clickedSmallPeerInfo() {
        isPresentingMetadataScreen = true
    }
}
//------------------------------------------------------------------------------------------

class TasksListScreenViewModel: ObservableObject {
    @Published var tasks = [Task]()
    @Published var isPresentingEditScreen: Bool = false
    @Published var isPresentingNameScreen: Bool = false
    @Published var isPresentingSettingsScreen: Bool = false
    @Published var userId: String = ""    
    private(set) var taskToEdit: Task? = nil
    
    //------------------------------------------------------------------------------------------
    // TEST smallPeerInfo with v4.4.0 on portal-dev.ditto.live
    @Published var isPresentingMetadataScreen = false
    //------------------------------------------------------------------------------------------
    
    var liveQuery: DittoLiveQuery?
    var subscription: DittoSubscription?

    init() {
        if (liveQuery == nil) {
            createQuery()
        }
    }
    
    public func createQuery() {
        var query = "(!isDeleted)"
        if (userId != "") {
            query += "&& invitationIds.\(userId) == true"
        }
            
        self.subscription = DittoManager.shared.ditto.store["tasks"]
            .find(query).subscribe()
        
        self.liveQuery = DittoManager.shared.ditto.store["tasks"]
            .find(query)
            .observeLocal(eventHandler: {  docs, event in
                print(event.description)
                self.tasks = docs.map({ Task(document: $0) })
                print(self.tasks)
            })
        DittoManager.shared.ditto.store["tasks"].find("isDeleted == true").evict()
    }
    
    public static func randomFakeFirstName() -> String {
        return TasksApp.firstNameList.randomElement()!
    }
    
    func toggle(task: Task) {
        DittoManager.shared.ditto.store["tasks"].findByID(task._id)
            .update { mutableDoc in
                guard let mutableDoc = mutableDoc else { return }
                mutableDoc["isCompleted"].set(!mutableDoc["isCompleted"].boolValue)
            }
    }
    
    func clickedInvite(task: Task) {
        DittoManager.shared.ditto.store["tasks"].findByID(task._id)
            .update { mutableDoc in
                guard let mutableDoc = mutableDoc else { return }
                let userId = TasksListScreenViewModel.randomFakeFirstName()
                mutableDoc["invitationIds"][userId] = true
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
    
    func clickedGear() {
        taskToEdit = nil
        isPresentingNameScreen = true
    }
    
    func clickedSettings() {
        isPresentingSettingsScreen = true
    }
}

struct TasksListScreen: View {

    @StateObject var viewModel = TasksListScreenViewModel()

    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.tasks) { task in
                    TaskRow(task: task,
                        onToggle: { task in viewModel.toggle(task: task) },
                        onClickBody: { task in viewModel.clickedBody(task: task) },
                        onClickInvite: { task in viewModel.clickedInvite(task: task)}
                    )
                }
            }
            .navigationTitle("Tasks - SwiftUI")
            //------------------------------------------------------------------------------------------
            // TEST smallPeerInfo with v4.4.0 on portal-dev.ditto.live

            /* orig
            .navigationBarItems(leading: Button(action: {
                viewModel.clickedSettings()
            }, label: {
                Image(systemName: "gearshape")
            }))
            .navigationBarItems(trailing: Button(action: {
                viewModel.clickedPlus()
            }, label: {
                Image(systemName: "plus")
            }))
            .navigationBarItems(trailing: Button(action: {
                viewModel.clickedGear()
            }, label: {
                Image(systemName: "gear")
            }))
            */
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        viewModel.clickedSettings()
                    }, label: {
                        Image(systemName: "gearshape")
                    })
                }
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Menu {
                        Button("New Task") {
                            viewModel.clickedPlus()
                        }
                        Button("Small Peer Info") {
                            viewModel.clickedSmallPeerInfo()
                        }
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            //------------------------------------------------------------------------------------------
            .sheet(isPresented: $viewModel.isPresentingSettingsScreen) {
                DittoToolsListView()
            }
            .sheet(isPresented: $viewModel.isPresentingEditScreen, content: {
                EditScreen(task: viewModel.taskToEdit, userId: viewModel.userId).onDisappear {
                    viewModel.createQuery()
                }
            })
            .sheet(isPresented: $viewModel.isPresentingNameScreen, content: {
                NameScreen(viewModel: viewModel).onDisappear {
                    viewModel.createQuery()
                }
            })
            //------------------------------------------------------------------------------------------
            // TEST smallPeerInfo with v4.4.0 on portal-dev.ditto.live
            .sheet(isPresented: $viewModel.isPresentingMetadataScreen, content: {
                MetadataScreen()
            })
            //------------------------------------------------------------------------------------------
        }
    }
}

struct TasksListScreen_Previews: PreviewProvider {
    static var previews: some View {
        TasksListScreen()
    }
}
