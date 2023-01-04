import DittoSwift
import Foundation

struct Category: Identifiable, Equatable, Hashable {
    let id: String
    let name: String
    
    init(id: String? = nil, name: String) {
        self.id = id ?? name
        self.name = name
    }
    
    init(document: DittoDocument) {
        self.id = document[dbIdKey].stringValue
        self.name = document[nameKey].stringValue
    }
}

struct Product: Identifiable, Equatable, Hashable {
    let id: String
    let name: String
    let categoryId: String
    
    init(id: String = UUID().uuidString, name: String, categoryId: String? = nil) {
        self.id = id
        self.name = name
        self.categoryId = categoryId ?? name
    }
    
    init(document: DittoDocument) {
        self.id = document[dbIdKey].stringValue
        self.name = document[nameKey].stringValue
        self.categoryId = document[categoryIdKey].stringValue
    }
}

struct CategoryWithProducts: Identifiable {
    let category: Category
    var products: [Product]
    var id: String {
        return self.category.id
    }
}
