import Combine
import SwiftUI

struct ProductsListView: View {
    @StateObject private var viewModel = ProductsViewModel()

    var body: some View {
        VStack {
            List {
                ForEach(viewModel.categorizedProducts) { categorizedProducts in
                    Section(categorizedProducts.category.name) {
                        ForEach(categorizedProducts.products) { product in
                            ProductListItemView(product)
                                .onTapGesture {
                                    viewModel.presentProductEdit(
                                        productIdToEdit: product.id,
                                        categoryIdForProductToAdd: product.categoryId
                                    )
                                }
                        }
                    }
                }
            }
        }
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarLeading) {
                Button("Prepopulate") {
                    viewModel.prepopulate()
                }
            }
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Menu {
                    if !viewModel.categorizedProducts.isEmpty {
                        Text(categoriesTitleKey)
                        ForEach(viewModel.categorizedProducts) { cat in
                            Button(cat.category.name) {
                                viewModel.presentProductEdit(
                                    productIdToEdit: nil,
                                    categoryIdForProductToAdd: cat.category.id
                                )
                            }
                        }
                    }
                    Button(addCategoryTitleKey) {
                        viewModel.presentProductEdit(
                            productIdToEdit: nil,
                            categoryIdForProductToAdd: nil
                        )
                    }
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $viewModel.isPresentingProductView, onDismiss: {
            viewModel.clearEditingData()
        }, content: {
            EditProductView(
                productIdToEdit: viewModel.editingProductId,
                categoryIdForProductToAdd: viewModel.editingCategoryId
            )
        })
        .navigationTitle("Products")
    }
}
