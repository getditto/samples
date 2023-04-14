//
//  ProductsViewModel.swift
//  CombineProducts
//
//  Created by Eric Turner on 12/20/22.
//

import Combine
import DittoSwift
import Foundation

class ProductsViewModel: ObservableObject {
    @Published var categorizedProducts = [CategoryWithProducts]()
    private var cancellables = Set<AnyCancellable>()
    
    private let ditto = DittoManager.shared.ditto
    @Published var isPresentingProductView = false
    var editingProductId: String?
    var editingCategoryId: String?

    private var productsCollection: DittoCollection {
        return ditto.store[productsKey]
    }
    
    private var categoriesCollection: DittoCollection {
        return ditto.store[categoriesKey]
    }
    

    init() {
        DittoManager.shared.startSync()
        
        let productsPublisher = productsCollection.findAll().liveQueryPublisher()
            .tryMap { $0.documents.map { Product(document: $0) } }

        let categoriesPublisher = categoriesCollection.findAll().liveQueryPublisher()
            .tryMap { $0.documents.map { Category(document: $0) } }

        categoriesPublisher.combineLatest(productsPublisher)
            .map { (categories, products) in
                return categories.map { category -> CategoryWithProducts in
                    let filteredProducts = products.filter { product in product.categoryId == category.id }
                    return CategoryWithProducts(category: category, products: filteredProducts)
                }
            }
            .catch { _ in
                Just([])
            }
//            .print()
            .assign(to: \.categorizedProducts, on: self)
            .store(in: &cancellables)
    }
    
    func deleteProduct(categorizedProducts: CategoryWithProducts, indexSet: IndexSet) {
        indexSet.map { categorizedProducts.products[$0] }
            .forEach { productToDelete in
                productsCollection.findByID(productToDelete.id).remove()
        }
    }

    func presentProductEdit(productIdToEdit: String?, categoryIdForProductToAdd: String?) {
        isPresentingProductView = true
        self.editingProductId = productIdToEdit
        self.editingCategoryId = categoryIdForProductToAdd
    }

    func clearEditingData() {
        editingProductId = nil
        editingCategoryId = nil
        isPresentingProductView = false
    }
    
    func prepopulate() {
        removeAllData()
        
        try! categoriesCollection.upsert(
            [dbIdKey: "Power Tools", nameKey: "Power Tools"] as [String: Any?]
        )
        
        try! categoriesCollection.upsert(
            [dbIdKey: "Hand Tools", nameKey: "Hand Tools"] as [String: Any?]
        )

        try! categoriesCollection.upsert(
            [dbIdKey: "Shop Tools", nameKey: "Shop Tools"] as [String: Any?]
        )

        try! productsCollection.upsert(
            [nameKey: "circular saw", categoryIdKey: "Power Tools"] as [String: Any?]
        )
        try! productsCollection.upsert(
            [nameKey: "cordless drill", categoryIdKey: "Power Tools"] as [String: Any?]
        )

        try! productsCollection.upsert(
            [nameKey: "Phillips screwdriver", categoryIdKey: "Hand Tools"] as [String: Any?]
        )
        try! productsCollection.upsert(
            [nameKey: "crescent wrench", categoryIdKey: "Hand Tools"] as [String: Any?]
        )
        try! productsCollection.upsert(
            [nameKey: "wire cutters", categoryIdKey: "Hand Tools"] as [String: Any?]
        )
        
        try! productsCollection.upsert(
            [nameKey: "drill press", categoryIdKey: "Shop Tools"] as [String: Any?]
        )
        try! productsCollection.upsert(
            [nameKey: "bench grinder", categoryIdKey: "Shop Tools"] as [String: Any?]
        )

    }
    
    func removeAllData() {
        categorizedProducts.map { $0 }.forEach { catProd in
            catProd.products.map {$0}.forEach { prodToDelete in
                productsCollection.findByID(prodToDelete.id).remove()
            }
            categoriesCollection.findByID(catProd.category.id).remove()
        }
    }
}
