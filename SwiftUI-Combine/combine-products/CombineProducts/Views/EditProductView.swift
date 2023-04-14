//
//  EditProductView.swift
//  CombineProducts
//
//  Created by Eric Turner on 12/20/22.
//

import SwiftUI

struct EditProductView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: EditProductViewModel
    
    @State var newCategoryName: String = ""
    @FocusState private var isNewCategoryFocused: Bool

    init(productIdToEdit: String?, categoryIdForProductToAdd: String?) {
        viewModel = EditProductViewModel(
            productIdToEdit: productIdToEdit,
            categoryIdForProductToAdd: categoryIdForProductToAdd
        )
    }

    var body: some View {
        NavigationView {
            Form {
                Section(categorySectionKey) {
                    // new Category textfield and handling
                    if viewModel.selectedCategory == nil {
                        TextField(requiredKey, text: $newCategoryName)
                            .textInputAutocapitalization(.never)
                            .disableAutocorrection(true)
                            .onChange(of: newCategoryName) { text in
                                viewModel.editingCategoryId = text
                            }
                    } else {
                        // selected Category
                        HStack {
                            Image(systemName: circleFillImgKey)
                            Text(viewModel.selectedCategory!.name)
                        }
                    }
                }
                Section(productNameTitleKey) {
                    TextField(requiredKey, text: $viewModel.productName)
                        .textInputAutocapitalization(.never)
                        .disableAutocorrection(true)
                }
                Section {
                    HStack {
                        Spacer()
                        Button(viewModel.saveButtonText) {
                            viewModel.save()
                            dismiss()
                        }
                        Spacer()
                    }
                    .disabled(
                        (newCategoryName.isEmpty && viewModel.selectedCategory == nil) ||
                        viewModel.productName.isEmpty
                    )
                }
            }
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarLeading) {
                    Button(cancelTitleKey) {
                        dismiss()
                    }
                }
            }
            .navigationTitle(viewModel.navigationTitle)
        }
    }
}

//struct EditProductView_Previews: PreviewProvider {
//    static var previews: some View {
//        EditProductView()
//    }
//}
