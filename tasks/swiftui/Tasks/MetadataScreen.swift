///
//  MetadataScreen.swift
//  Tasks
//
//  Created by Eric Turner on 10/4/23.
//
//  Copyright © 2023 ___ORGANIZATIONNAME___. All rights reserved.

import Combine
import SwiftUI

class MetadataVM: ObservableObject {
    @Published var key = ""
    @Published var value = ""
    @Published var displayMetadata: String = ""
    private var tmpMetadata: [String: Any] = DittoManager.shared.ditto.smallPeerInfo.metadata
    
    init() {
        displayMetadata = tmpMetadata.description
    }
    
    func save() {
        if !tmpMetadata.isEmpty {
            DittoManager.shared.updateSmallPeerInfoMetadata(tmpMetadata)
        }
    }
    
    func preview() {
        tmpMetadata[key] = value
        displayMetadata = tmpMetadata.description
    }
}


struct MetadataScreen: View {
    @Environment(\.presentationMode) private var presentationMode
    @StateObject var vm = MetadataVM()
    @Namespace var previewID
    
    var body: some View {
        NavigationView {
            VStack {
                ScrollViewReader { proxy in
                    Form {
                        VStack {
                            Text(
                                "Add key/value pair(s) to current metadata. Preview every change.\n" +
                                "(single/double quotes not allowed)"
                            )
                                .font(.footnote)
                                .id(1)
                        }

                        Section("Add key/value pair") {
                            TextField("key", text: $vm.key).lineLimit(1)
                            TextField("value", text: $vm.value).lineLimit(3)
                        }
                        .disableAutocorrection(true)
                        .autocapitalization(.none)
                        .id(2)
                        
                        Section {
                            Button("Preview") {
                                vm.preview()
                            }
                            .disabled(vm.key.isEmpty || vm.value .isEmpty)
                            .id(3)
                        }
                        Section {
                            TextField("", text: $vm.displayMetadata, axis: .vertical)
                                .id(previewID)
                            .onChange(of: vm.displayMetadata) { _ in
                                withAnimation {
                                    proxy.scrollTo(previewID, anchor: .center)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Metadata")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(leading: Button("Save") {
                self.presentationMode.wrappedValue.dismiss()
                vm.save()
            })
            .navigationBarItems(trailing: Button("Cancel") {
                self.presentationMode.wrappedValue.dismiss()
            })
        }
    }
}



struct MetadataScreen_Previews: PreviewProvider {
    static var previews: some View {
        MetadataScreen()
    }
}
