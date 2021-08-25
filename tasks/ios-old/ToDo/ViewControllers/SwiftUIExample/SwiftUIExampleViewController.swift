//
//  SwiftUIExampleViewController.swift
//  ToDo
//
//  Created by Maximilian Alexander on 6/19/21.
//

import UIKit
import SwiftUI

class SwiftUIExampleViewController: UIHostingController<ToDoListView> {

    init() {
        super.init(rootView: ToDoListView(dataSource: DataSource()))
    }

    @objc required dynamic init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder, rootView: ToDoListView(dataSource: DataSource()))
    }

}
