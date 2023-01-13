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
struct CategorizedProducts: Identifiable {
    var category: Category
    var products: [Product]
    var id: String {
        category.id
    }
}
