//
//  CombineMenuApp.swift
//  CombineMenu
//
//  Created by Maximilian Alexander on 3/3/22.
//

import SwiftUI

@main
struct CombineMenuApp: App {
    var body: some Scene {
        WindowGroup {
            NavigationView {
                MenuView()
            }
            .navigationViewStyle(StackNavigationViewStyle())
        }
    }
}
