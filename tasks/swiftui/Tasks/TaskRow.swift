//
//  TaskRow.swift
//  Tasks
//
//  Created by Maximilian Alexander on 8/27/21.
//

import SwiftUI

struct TaskRow: View {

    let task: Task

    var onToggle: ((_ task: Task) -> Void)?
    var onClickBody: ((_ task: Task) -> Void)?
    var onClickInvite: ((_ task: Task) -> Void)?


    var body: some View {
        HStack {
            Image(systemName: task.isCompleted ? "circle.fill": "circle")
                .renderingMode(.template)
                .foregroundColor(.accentColor)
                .onTapGesture {
                    onToggle?(task)
                }
            if task.isCompleted {
                Text(task.body)
                    .strikethrough()
                    .onTapGesture {
                        onClickBody?(task)
                    }

            } else {
                Text(task.body)
                    .onTapGesture {
                        onClickBody?(task)
                    }
            }
            Spacer()
            Text(task.invitationIds.keys.reduce("", { x, y in
                x +  y + ", "
            })).foregroundColor(Color.gray)
            
            Text("+").onTapGesture {
                onClickInvite?(task)
            }
        }
    }
}

struct TaskRow_Previews: PreviewProvider {
    static var previews: some View {
        List {
            TaskRow(task: Task(body: "Get Milk", isCompleted: true, invitationIds: ["Susan": true, "John": true]))
            TaskRow(task: Task(body: "Do Homework", isCompleted: false, invitationIds: [:]))
            TaskRow(task: Task(body: "Take out trash", isCompleted: true, invitationIds: [:]))
        }
    }
}
