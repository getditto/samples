import DittoSwift
import Foundation

//struct Category: Codable {
struct Category: Identifiable, Equatable, Hashable {
    let id: String
    let name: String
//    init(name: String) {
//        self.name = name
//        self.id = UUID().uuidString
//    }
    
    init(document: DittoDocument) {
        self.id = document["_id"].stringValue
        self.name = document["name"].stringValue
    }
}

//struct Product: Codable {
struct Product: Identifiable, Equatable, Hashable {
    let id: String
    let name: String
    let categoryName: String
    
    init(document: DittoDocument) {
        self.id = document["_id"].stringValue
        self.name = document["name"].stringValue
        self.categoryName = document["categoryName"].stringValue
    }
}

//struct CategoryWithProducts: Codable {
struct CategoryWithProducts {//}: Identifiable, Equatable, Hashable {
    let category: Category
    var products: [Product]
    
//    init(document: DittoDocument) {
//        self.id = document["_id"].stringValue
//        self.category = document["category]
//        self.products = document["products
//    }
}
