//
//  ContentView.swift
//  CombineMenu
//
//  Created by Maximilian Alexander on 3/3/22.
//

import SwiftUI
import DittoSwift
import Combine

class MenuViewModel: ObservableObject {

    @Published var categorizedProducts = [CategorizedProducts]()
    @Published var isPresentingProductView = false
    var productIdToEdit: String?
    var categoryIdForProductToAdd: String?

    private var cancellables = Set<AnyCancellable>()
    private let ditto = DittoManager.shared.ditto
    private var productsCollection: DittoCollection {
        return self.ditto.store["products"]
    }
    private var categoriesCollection: DittoCollection {
        return self.ditto.store["categories"]
    }

    init() {
        let productsPublisher = productsCollection.findAll().liveQueryPublisher()
            .tryMap({ try $0.documents.map({ try $0.typed(as: Product.self).value }) })

        let categoriesPublisher = categoriesCollection.findAll().liveQueryPublisher()
            .tryMap({ try $0.documents.map({ try $0.typed(as: Category.self).value }) })

        categoriesPublisher.combineLatest(productsPublisher)
            .map { (categories, products) in
                return categories.map({ category -> CategorizedProducts in
                    let filteredProducts = products.filter { product in product.categoryId == category._id }
                    return CategorizedProducts(category: category, products: filteredProducts)
                })
            }.catch({ _ in
                Just([])
            })
            .assign(to: \.categorizedProducts, on: self)
            .store(in: &cancellables)
    }

    func prepopulate() {
        try! categoriesCollection
            .upsert(Category(_id: "drinks", name: "Drinks"))
        try! categoriesCollection
            .upsert(Category(_id: "entrees", name: "Entrees"))
        try! categoriesCollection
            .upsert(Category(_id: "dessert", name: "Desserts"))

        try! productsCollection
            .upsert(Product(_id: "coca-cola", name: "Coca Cola", detail: "Coca Cola soft drink", categoryId: "drinks"))
        try! productsCollection
            .upsert(Product(_id: "diet-pepsi", name: "Diet Pepsi", detail: "Diet Pepsi standard flavor", categoryId: "drinks"))
        try! productsCollection
            .upsert(Product(_id: "cappucino", name: "Cappucino", detail: "One shot of espresso and steamed milk", categoryId: "drinks"))

        try! productsCollection
            .upsert(Product(_id: "chicken-sandwich", name: "Chicken Sandwich", detail: "A grilled chicken sandwich with tomatoes, lettuce and mustard.", categoryId: "entrees"))
        try! productsCollection
            .upsert(Product(_id: "roast-beef", name: "Roast Beef", detail: "A roast beef sandwich with tomatoes, lettuce and mustard.", categoryId: "entrees"))
        try! productsCollection
            .upsert(Product(_id: "fettuccine-alfredo", name: "Fettuccine Alfredo", detail: "Fresh fettuccine tossed with butter and Parmesan cheese.", categoryId: "entrees"))

        try! productsCollection
            .upsert(Product(_id: "chocolate-chip-cookie", name: "Chocolate Chip Cookie", detail: "Chocolate Chip Cookie", categoryId: "dessert"))
        try! productsCollection
            .upsert(Product(_id: "vanilla-ice-cream", name: "Vanilla Ice Cream", detail: "Vanilla Ice Cream", categoryId: "dessert"))
        try! productsCollection
            .upsert(Product(_id: "caramel-candy", name: "Caramel Candy", detail: "Caramel Candy", categoryId: "dessert"))
    }

    func deleteProduct(categorizedProducts: CategorizedProducts, indexSet: IndexSet) {
        indexSet.map({ categorizedProducts.products[$0] }).forEach { productToDelete in
            productsCollection.findByID(productToDelete._id).remove()
        }
    }

    func presentProductEdit(productIdToEdit: String?, categoryIdForProductToAdd: String?) {
        self.isPresentingProductView = true
        self.productIdToEdit = productIdToEdit
        self.categoryIdForProductToAdd = categoryIdForProductToAdd
    }

    func clearEditingData() {
        self.productIdToEdit = nil
        self.categoryIdForProductToAdd = nil
        self.isPresentingProductView = false
    }

}


struct MenuView: View {

    @StateObject var viewModel = MenuViewModel()

    var body: some View {
        VStack {
            List {
                ForEach(viewModel.categorizedProducts) { categorizedProducts in
                    Section(categorizedProducts.category.name) {
                        ForEach(categorizedProducts.products) { product in
                            ProductListItemView(productName: product.name, productDescription: product.detail)
                                .onTapGesture {
                                    viewModel.presentProductEdit(productIdToEdit: product._id, categoryIdForProductToAdd: categorizedProducts.category._id)
                                }
                        }.onDelete { indexSet in
                            viewModel.deleteProduct(categorizedProducts: categorizedProducts, indexSet: indexSet)
                        }
                    }
                }
            }
        }
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarLeading, content: {
                Button("Prepopulate") {
                    viewModel.prepopulate()
                }
            })
            ToolbarItemGroup(placement: .navigationBarTrailing, content: {
                Menu(content: {
                    Text("Which Category?")
                    ForEach(viewModel.categorizedProducts) { c in
                        Button(c.category.name) {
                            viewModel.presentProductEdit(productIdToEdit: nil, categoryIdForProductToAdd: c.category._id)
                        }
                    }
                }, label: {
                    Image(systemName: "plus")
                })

            })
        }
        .sheet(isPresented: $viewModel.isPresentingProductView, onDismiss: {
            viewModel.clearEditingData()
        }, content: {
            EditProductView(productIdToEdit: viewModel.productIdToEdit, categoryIdForProductToAdd: viewModel.categoryIdForProductToAdd)
        })
        .navigationTitle("Combine Menu")
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            MenuView()
        }
    }
}
