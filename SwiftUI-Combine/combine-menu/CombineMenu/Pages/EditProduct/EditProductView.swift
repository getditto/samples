//
//  EditProductView.swift
//  CombineMenu
//
//  Created by Maximilian Alexander on 3/3/22.
//

import Combine
import SwiftUI

struct EditProductView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: EditProductViewModel

    init(productIdToEdit: String?, categoryIdForProductToAdd: String?) {
        viewModel = EditProductViewModel(
            productIdToEdit: productIdToEdit,
            categoryIdForProductToAdd: categoryIdForProductToAdd
        )
    }

    var body: some View {
        NavigationView {
            Form {
                Section("Category") {
                    ForEach(viewModel.categories) { category in
                        HStack {
                            Image(systemName: viewModel.selectedCategory?.id == category.id ? "circle.fill" : "circle")
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

#if DEBUG
struct EditProductView_Previews: PreviewProvider {
    static var previews: some View {
        EditProductView(
            productIdToEdit: "123abc",
            categoryIdForProductToAdd: "123abc"
        )
    }
}
#endif
