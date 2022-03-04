import Foundation

struct Category: Codable {
    let name: String
}

struct Product: Codable {
    let name: String
    let categoryName: String
}

struct CategoryWithProducts: Codable {
    let category: Category
    var products: [Product]
}
