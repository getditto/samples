//
//  EditProductView.swift
//  CombineMenu
//
//  Created by Maximilian Alexander on 3/3/22.
//

import SwiftUI
import Combine

class EditProductViewModel: ObservableObject {
    private var productIdToEdit: String?
    private var categoryIdForProductToAdd: String?

    private let ditto = DittoManager.shared.ditto

    @Published var selectedCategory: Category?
    @Published var categories: [Category] = []
    @Published var name: String = ""
    @Published var detail: String = ""

    var navigationTitle: String
    var saveButtonText: String

    private var cancellables = Set<AnyCancellable>()

    init(productIdToEdit: String?, categoryIdForProductToAdd: String?) {
        self.productIdToEdit = productIdToEdit
        self.categoryIdForProductToAdd = categoryIdForProductToAdd
        self.navigationTitle = productIdToEdit != nil ? "Edit Product": "Create Product"
        self.saveButtonText = productIdToEdit != nil ? "Save Changes": "Create Product"

        let categoriesPublisher = ditto.store["categories"].findAll()
            .liveQueryPublisher()
            .tryMap({ try $0.documents.map({ try $0.typed(as: Category.self).value }) })
            .catch({ _ in Just([]) });

        categoriesPublisher
            .assign(to: \.categories, on: self)
            .store(in: &cancellables);

        Just(categoryIdForProductToAdd)
            .combineLatest(categoriesPublisher.first())
            .map({ (categoryId, allCategories) -> Category? in
                return allCategories.first(where: { $0._id == categoryId })
            })
            .assign(to: \.selectedCategory, on: self)
            .store(in: &cancellables);

        guard let productIdToEdit = productIdToEdit, let product = try? ditto.store["products"].findByID(productIdToEdit).exec()?.typed(as: Product.self).value else {
                return
            }
        self.name = product.name
        self.detail = product.detail
    }

    func save() {
        try! ditto.store["products"].upsert([
            "_id": productIdToEdit,
            "name": name,
            "detail": detail,
            "categoryId": selectedCategory?._id
        ])
    }

    func changeSelectedCategory(_ category: Category) {
        self.selectedCategory = category
    }
}

struct EditProductView: View {

    @Environment(\.dismiss) private var dismiss

    @ObservedObject var viewModel: EditProductViewModel

    init(productIdToEdit: String?, categoryIdForProductToAdd: String?) {
        viewModel = EditProductViewModel(productIdToEdit: productIdToEdit, categoryIdForProductToAdd: categoryIdForProductToAdd)
    }

    var body: some View {
        NavigationView {
            Form {
                Section("Category") {
                    ForEach(viewModel.categories) { category in
                        HStack {
                            Image(systemName: viewModel.selectedCategory?._id == category._id ? "circle.fill" : "circle")
                            Text(category.name)
                        }.onTapGesture {
                            viewModel.changeSelectedCategory(category)
                        }
                    }
                }
                Section {
                    Text("Product Name")
                    TextField("Product Name", text: $viewModel.name)
                }
                Section {
                    Text("Product Detail")
                    TextEditor(text: $viewModel.detail)
                        .frame(minHeight: 100)
                }
                Section {
                    Button(viewModel.saveButtonText) {
                        viewModel.save()
                        dismiss()
                    }
                }
            }
            .toolbar(content: {
                ToolbarItemGroup(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            })
            .navigationTitle(viewModel.navigationTitle)
        }
    }
}

struct EditProductView_Previews: PreviewProvider {
    static var previews: some View {
        EditProductView(productIdToEdit: "123abc", categoryIdForProductToAdd: "123abc")
    }
}
