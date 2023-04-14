//
//  EditProductViewModel.swift
//  CombineProducts
//
//  Created by Eric Turner on 12/20/22.
//

import Combine
import DittoSwift
import Foundation

class EditProductViewModel: ObservableObject {
    @Published var selectedCategory: Category?
    @Published var categories: [Category] = []
    @Published var productName: String = ""
    private var cancellables = Set<AnyCancellable>()

    var navigationTitle: String
    var saveButtonText: String

    var editingProductId: String?
    var editingCategoryId: String?
    private let ditto = DittoManager.shared.ditto

    private var productsCollection: DittoCollection {
        return ditto.store[productsKey]
    }
    
    private var categoriesCollection: DittoCollection {
        return ditto.store[categoriesKey]
    }
    
    init(productIdToEdit: String?, categoryIdForProductToAdd: String?) {
        self.editingProductId = productIdToEdit
        self.editingCategoryId = categoryIdForProductToAdd

        self.navigationTitle = productIdToEdit != nil ? editProductTitleKey: createProductTitleKey
        self.saveButtonText = productIdToEdit != nil ? saveChangesTitleKey: createProductTitleKey

        let categoriesPublisher = ditto.store[categoriesKey].findAll()
            .liveQueryPublisher()
            .tryMap { $0.documents.map { Category(document: $0) } }
            .catch { _ in Just([]) }

        categoriesPublisher
            .assign(to: \.categories, on: self)
            .store(in: &cancellables);

        Just(categoryIdForProductToAdd)
            .combineLatest(categoriesPublisher.first())
            .map { (categoryId, allCategories) -> Category? in
                return allCategories.first(where: { $0.id == categoryId })
            }
            .assign(to: \.selectedCategory, on: self)
            .store(in: &cancellables);

        guard let productIdToEdit,
              let doc = ditto.store[productsKey].findByID(productIdToEdit).exec()
        else { return }

        productName = doc[nameKey].stringValue
    }

    func save() {

        if let selectedCat = selectedCategory {
            try! categoriesCollection.upsert([
                dbIdKey: selectedCat.id,
                nameKey: selectedCat.name] as [String : Any?]
            )
        } else if let categoryId = editingCategoryId {
            // create selectedCategory for use in product insertion below
            selectedCategory = Category(name: categoryId)
            
            try! categoriesCollection.upsert([
                dbIdKey: categoryId,
                nameKey: categoryId] as [String: Any?]
            )
        } else {
            print("ERROR: NIL selectedCategory AND empty editingCategoryId -> RETURN")
            return
        }
        
        
        try! productsCollection.upsert([
            dbIdKey: editingProductId ?? UUID().uuidString,
            nameKey: productName,
            categoryIdKey: selectedCategory!.id] as [String: Any?]
        )
    }
    
    func createNewCategory(id: String? = nil, name: String? = nil) {
        guard let name = name else { return }
        let newCat = Category(id: id, name: name)
        selectedCategory = newCat
    }

    func changeSelectedCategory(_ category: Category) {
        selectedCategory = category
    }
}
