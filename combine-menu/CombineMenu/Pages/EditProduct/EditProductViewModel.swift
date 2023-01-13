//
//  EditProductViewModel.swift
//  CombineMenu
//
//  Created by Eric Turner on 12/16/22.
//

import Combine
import Foundation

class EditProductViewModel: ObservableObject {
    @Published var selectedCategory: Category?
    @Published var categories: [Category] = []
    @Published var name: String = ""
    @Published var detail: String = ""
    private var cancellables = Set<AnyCancellable>()
    
    private var productIdToEdit: String?
    private var categoryIdForProductToAdd: String?
    private let ditto = DittoManager.shared.ditto

    var navigationTitle: String
    var saveButtonText: String

    init(productIdToEdit: String?, categoryIdForProductToAdd: String?) {
        self.productIdToEdit = productIdToEdit
        self.categoryIdForProductToAdd = categoryIdForProductToAdd        
        self.navigationTitle = productIdToEdit != nil ? "Edit Product": "Create Product"
        self.saveButtonText = productIdToEdit != nil ? "Save Changes": "Create Product"

        let categoriesPublisher = ditto.store["categories"].findAll()
            .liveQueryPublisher()
            .tryMap({ $0.documents.map({ Category(document: $0) }) })
            .catch({ _ in Just([]) });

        categoriesPublisher
            .assign(to: \.categories, on: self)
            .store(in: &cancellables);

        Just(categoryIdForProductToAdd)
            .combineLatest(categoriesPublisher.first())
            .map({ (categoryId, allCategories) -> Category? in
                return allCategories.first(where: { $0.id == categoryId })
            })
            .assign(to: \.selectedCategory, on: self)
            .store(in: &cancellables);

        guard let productIdToEdit,
              let doc = ditto.store["products"].findByID(productIdToEdit).exec()
        else { return }

        self.name = doc["name"].stringValue
        self.detail = doc["detail"].stringValue
    }

    func save() {
        try! ditto.store["products"].upsert(
            ["_id": productIdToEdit ?? UUID().uuidString,
             "name": name,
             "detail": detail,
             "categoryId": self.selectedCategory?.id
            ] as [String: Any?]
        )
    }

    func changeSelectedCategory(_ category: Category) {
        self.selectedCategory = category
    }
}
