//
//  TasksApp.swift
//  Tasks
//
//  Created by Maximilian Alexander on 8/26/21.
//

import SwiftUI
import DittoSwift

@main
struct TasksApp: App {

    @State var isPresentingAlert = false
    @State var errorMessage = ""
    
    public static var firstNameList = ["Henry", "William", "Geoffrey", "Jim", "Yvonne", "Jamie", "Leticia", "Priscilla", "Sidney", "Nancy", "Edmund", "Bill", "Megan"]


    var body: some Scene {
        WindowGroup {
            TasksListScreen()
                .onAppear(perform: {
                    do {
                        try DittoManager.shared.ditto.startSync()
                    } catch (let err){
                        isPresentingAlert = true
                        errorMessage = err.localizedDescription
                    }
                })
                .alert(isPresented: $isPresentingAlert) {
                    Alert(title: Text("Uh Oh"), message: Text("There was an error trying to start the sync. Here's the error \(errorMessage) Ditto will continue working as a local database."), dismissButton: .default(Text("Got it!")))
                }
        }
    }
}
