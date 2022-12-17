//
//  ContentView.swift
//  CombineMenu
//
//  Created by Maximilian Alexander on 3/3/22.
//

import Combine
import SwiftUI

struct MenuView: View {
    @StateObject var viewModel = MenuViewModel()

    var body: some View {
        VStack {
            List {
                ForEach(viewModel.categorizedProducts) { categorizedProducts in
                    Section(categorizedProducts.category.name) {
                        ForEach(categorizedProducts.products) { product in
                            ProductListItemView(
                                productName: product.name,
                                productDescription: product.detail
                            )
                            .onTapGesture {
                                viewModel.presentProductEdit(
                                    productIdToEdit: product.id,
                                    categoryIdForProductToAdd: categorizedProducts.category.id
                                )
                            }
                        }.onDelete { indexSet in
                            viewModel.deleteProduct(
                                categorizedProducts: categorizedProducts,
                                indexSet: indexSet
                            )
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
                    ForEach(viewModel.categorizedProducts) { cat in
                        Button(cat.category.name) {
                            viewModel.presentProductEdit(
                                productIdToEdit: nil,
                                categoryIdForProductToAdd: cat.category.id
                            )
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
            EditProductView(
                productIdToEdit: viewModel.productIdToEdit,
                categoryIdForProductToAdd:
                    viewModel.categoryIdForProductToAdd
            )
        })
        .navigationTitle("Combine Menu")
    }
}

#if DEBUG
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            MenuView()
        }
    }
}
#endif
