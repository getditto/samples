import SwiftUI
//import 

@main
struct DittoCombineExampleApp: App {
    var body: some Scene {
        WindowGroup {
            NavigationView {
                ProductsListView()
            }
            .navigationViewStyle(StackNavigationViewStyle())
        }
    }
}
