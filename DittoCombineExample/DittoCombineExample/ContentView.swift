import SwiftUI
import Combine

struct ContentView: View {

    private class ViewModel: ObservableObject {
        private var cancellables = Set<AnyCancellable>()

        init() {
            DittoManager.shared.startSync()
            DittoManager.shared.setDummyData()

            // print categories
            DittoManager.shared.categories.sink { categories in
                print("All categories: \(categories.map { $0.name })")
            }
            .store(in: &cancellables)

            // print products
            DittoManager.shared.products.sink { products in
                print("All products: \(products.map { $0.name })")
            }
            .store(in: &cancellables)

            // print products by a category
            DittoManager.shared.productsBy(categoryName: "drinks").sink { products in
                print("Products in drink category: \(products.map { $0.name })")
            }
            .store(in: &cancellables)

            // print products with categories
            DittoManager.shared.categoryWithProducts.sink { list in
                list.forEach {
                    print("Products in category '\($0.category.name)': \($0.products.map { $0.name })")
                }
            }
            .store(in: &cancellables)
        }
    }

    @ObservedObject private var viewModel = ViewModel()

    var body: some View {
        EmptyView()
    }
}
