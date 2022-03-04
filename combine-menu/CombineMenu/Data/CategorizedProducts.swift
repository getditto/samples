//
//  CategorizedProducts.swift
//  CombineMenu
//
//  Created by Maximilian Alexander on 3/3/22.
//

import Foundation

/**
 This is used with `combineLatest`
 */
struct CategorizedProducts {
    var category: Category
    var products: [Product]
}

extension CategorizedProducts: Identifiable {
    var id: String {
        return self.category._id
    }
}
