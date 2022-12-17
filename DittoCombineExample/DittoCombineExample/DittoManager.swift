import Combine
import DittoSwift
import Foundation

final class DittoManager {

    static let shared = DittoManager()

    private let ditto: Ditto!

    private var cancellables = Set<AnyCancellable>()

    private init() {
        ditto = Ditto()
        try! ditto.setOfflineOnlyLicenseToken(
            "o2d1c2VyX2lkdTExODE0NDU2ODIwNjc3NjI1MjAxN2ZleHBpcnl4GDIwMjMtMDEtMTVUMjA6MjM6MDAuMzg0WmlzaWduYXR1cmV4WGt5REdkbkhid3RqWjl1Nk5uTllhM1g1K1ZMc2ZWU1RTOUR5Q1p4TlVYUXhWRzM1RENWWHJBWWd0N3NUTEZVbmtmWEJsMXhoL1JOeWRZZXVZeEV0L1NnPT0="
        )
    }

    deinit {
        cancellables.removeAll()
    }

    func startSync() {
        let isPreview: Bool = ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
        if !isPreview {
            var transportConfig = DittoTransportConfig()
            transportConfig.enableAllPeerToPeer()
            ditto.transportConfig = transportConfig
            try! ditto.startSync()
        }
    }

    var categories: AnyPublisher<[Category], Never> {
        return ditto.store.collection("categories").findAll()
            .liveQueryPublisher()
            .map({ snapshot in
                return snapshot.documents.map({
//                    try! $0.typed(as: Category.self).value
                    Category(document: $0)
                })
            })
            .eraseToAnyPublisher()
    }

    var products: AnyPublisher<[Product], Never> {
        return ditto.store.collection("products").findAll()
            .liveQueryPublisher()
            .map { snapshot in
                return snapshot.documents.map {
//                    try! $0.typed(as: Product.self).value
                    Product(document: $0)
                }
            }
            .eraseToAnyPublisher()
    }

    func productsBy(categoryName: String) -> AnyPublisher<[Product], Never> {
        return ditto.store.collection("products").find("categoryName == '\(categoryName)'")
            .liveQueryPublisher()
            .map { snapshot in
                return snapshot.documents.map {
//                    try! $0.typed(as: Product.self).value
                    Product(document: $0)
                }
            }
            .eraseToAnyPublisher()
    }

    var categoryWithProducts: AnyPublisher<[CategoryWithProducts], Never> {
        return ditto.store.collection("categories").findAll().liveQueryPublisher()
            .map { snapshot in
                return snapshot.documents.compactMap { [weak self] in
                    guard let self = self else { return nil }
                    let category = Category(document: $0)//try! $0.typed(as: Category.self).value
                    let products = self.ditto.store.collection("products").find("categoryName == '\(category.name)'").exec()
                    return CategoryWithProducts(
                        category: category,
                        products: products.map { Product(document: $0) } //try! $0.typed(as: Product.self).value }
                    )
                }
            }
        .eraseToAnyPublisher()
    }

    func setDummyData() {
        let categories = ditto.store.collection("categories").findAll().exec()
        guard categories.isEmpty else { return /* set dummy only first time */ }
        //orig
//        try! ditto.store.collection("categories").upsert(Category(name: "drinks"))
//        try! ditto.store.collection("categories").upsert(Category(name: "snacks"))
//
//        try! ditto.store.collection("products").upsert(Product(name: "milk", categoryName: "drinks"))
//        try! ditto.store.collection("products").upsert(Product(name: "chocolate", categoryName: "snacks"))
        try! ditto.store.collection("categories").upsert(
            ["name": "drinks"] as [String: Any?]
        )
        
        try! ditto.store.collection("categories").upsert(
            ["name": "snacks"] as [String: Any?]
        )
        
        try! ditto.store.collection("products").upsert(
            ["name": "drinks", "categoryName": "drinks"] as [String: Any?]
        )
        
        try! ditto.store.collection("products").upsert(
            ["name": "chocolate", "categoryName": "snacks"] as [String: Any?]
        )
    }
}
