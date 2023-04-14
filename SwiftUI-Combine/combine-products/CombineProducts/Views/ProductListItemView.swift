//
//  ProductListItemView.swift
//  CombineProducts
//
//  Created by Eric Turner on 12/20/22.
//

import SwiftUI

struct ProductListItemView: View {
    var product: Product
//    var productDescription: String
    
    init(_ product: Product) {
        self.product = product
    }

    var body: some View {
        VStack(alignment: .leading) {
            Text(product.name)
                .bold()
//            Text(productDescription)
//                .font(.caption)
        }
    }
}
