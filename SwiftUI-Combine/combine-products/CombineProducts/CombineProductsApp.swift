import SwiftUI

@main
struct CombineProductsApp: App {
    var body: some Scene {
        WindowGroup {
            NavigationView {
                ProductsListView()
            }
            .navigationViewStyle(StackNavigationViewStyle())
        }
    }
}
