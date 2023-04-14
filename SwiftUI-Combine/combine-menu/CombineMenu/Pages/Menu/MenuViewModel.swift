//
//  MenuViewModel.swift
//  CombineMenu
//
//  Created by Eric Turner on 12/16/22.
//

import Combine
import DittoSwift
import SwiftUI

class MenuViewModel: ObservableObject {
    @Published var categorizedProducts = [CategorizedProducts]()
    @Published var isPresentingProductView = false
    
    private let ditto = DittoManager.shared.ditto
    private var productsCollection: DittoCollection {
        return self.ditto.store["products"]
    }
    private var categoriesCollection: DittoCollection {
        return self.ditto.store["categories"]
    }
    
    var productIdToEdit: String?
    var categoryIdForProductToAdd: String?

    init() {
        let productsPublisher = productsCollection.findAll().liveQueryPublisher()
            .tryMap { $0.documents.map { Product(document: $0) } }

        let categoriesPublisher = categoriesCollection.findAll().liveQueryPublisher()
            .tryMap { $0.documents.map { Category(document: $0) } }

        categoriesPublisher.combineLatest(productsPublisher)
            .map { (categories, products) in
                return categories.map({ category -> CategorizedProducts in
                    let filteredProducts = products.filter { product in product.categoryId == category.id }
                    return CategorizedProducts(category: category, products: filteredProducts)
                })
            }
            .catch { _ in
                Just([])
            }
            .assign(to: &$categorizedProducts)
    }

    func presentProductEdit(productIdToEdit: String?, categoryIdForProductToAdd: String?) {
        self.isPresentingProductView = true
        self.productIdToEdit = productIdToEdit
        self.categoryIdForProductToAdd = categoryIdForProductToAdd
    }
    
    func deleteProduct(categorizedProducts: CategorizedProducts, indexSet: IndexSet) {
        indexSet.map({ categorizedProducts.products[$0] }).forEach { productToDelete in
            productsCollection.findByID(productToDelete.id).remove()
        }
    }

    func clearEditingData() {
        self.productIdToEdit = nil
        self.categoryIdForProductToAdd = nil
        self.isPresentingProductView = false
    }

    func prepopulate() {
        try! categoriesCollection
            .upsert( ["_id": "drinks", "name": "Drinks"] as [String: Any?] )
        try! categoriesCollection
            .upsert( ["_id": "entrees", "name": "Entrees"] as [String: Any?] )
        try! categoriesCollection
            .upsert( ["_id": "dessert", "name": "Desserts"] as [String: Any?] )
        
        try! productsCollection
            .upsert(
                ["_id": "coca-cola",
                 "name": "Coca Cola",
                 "detail": "Coca Cola soft drink",
                 "categoryId": "drinks"
                ] as [String: Any?]
            )
        try! productsCollection
            .upsert(
                ["_id": "diet-pepsi",
                 "name": "Diet Pepsi",
                 "detail": "Diet Pepsi standard flavor",
                 "categoryId": "drinks"
                ] as [String: Any?]
            )
        try! productsCollection
            .upsert(
                ["_id": "cappucino",
                 "name": "Cappucino",
                 "detail": "One shot of espresso and steamed milk",
                 "categoryId": "drinks"
                ] as [String: Any?]
            )
        try! productsCollection
            .upsert(
                ["_id": "chicken-sandwich",
                 "name": "Chicken Sandwich",
                 "detail": "A grilled chicken sandwich with tomatoes, lettuce and mustard.",
                 "categoryId": "entrees"
                ] as [String: Any?]
            )
        try! productsCollection
            .upsert(
                ["_id": "roast-beef",
                 "name": "Roast Beef",
                 "detail": "A roast beef sandwich with tomatoes, lettuce and mustard.",
                 "categoryId": "entrees"
                ] as [String: Any?]
            )
        try! productsCollection
            .upsert(
                ["_id": "fettuccine-alfredo",
                 "name": "Fettuccine Alfredo",
                 "detail": "Fresh fettuccine tossed with butter and Parmesan cheese.",
                 "categoryId": "entrees"
                ] as [String: Any?]
            )
        try! productsCollection
            .upsert(
                ["_id": "chocolate-chip-cookie",
                 "name": "Chocolate Chip Cookie",
                 "detail": "Chocolate Chip Cookie",
                 "categoryId": "dessert"
                ] as [String: Any?]
            )
        try! productsCollection
            .upsert(
                ["_id": "vanilla-ice-cream",
                 "name": "Vanilla Ice Cream",
                 "detail": "Vanilla Ice Cream",
                 "categoryId": "dessert"
                ] as [String: Any?]
            )
        try! productsCollection
            .upsert(
                ["_id": "caramel-candy",
                 "name": "Caramel Candy",
                 "detail": "Caramel Candy",
                 "categoryId": "dessert"
                ] as [String: Any?]
            )
    }
}

