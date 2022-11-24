//
//  NameScreen.swift
//  Tasks
//
//  Created by Rae McKelvey on 11/23/22.
//

import SwiftUI

struct NameScreen: View {
    @ObservedObject var viewModel: TasksListScreenViewModel
    
    var body: some View {
        
        VStack {
            Picker(selection: $viewModel.userId, label: Text("View as:")) {
                ForEach(TasksApp.firstNameList, id: \.self) { name in
                    Text(name).tag(name).font(Font.title)
                }
                Text("Super Admin").tag("")
            }.pickerStyle(InlinePickerStyle())
        }
    }
}
