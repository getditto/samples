import Foundation
import Combine
import DittoSwift
import CombineDitto

final class DittoManager {

    static let shared = DittoManager()

    private let ditto: Ditto!

    private var cancellables = Set<AnyCancellable>()

    private init() {
        let identity = DittoIdentity.offlinePlayground(appID: "live.ditto.skyservice")
        ditto = Ditto(identity: identity)
        try! ditto.setLicenseToken("")
    }

    deinit {
        cancellables.removeAll()
    }

    func startSync() {
        let isPreview: Bool = ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
        if !isPreview {
            var transportConfig = DittoTransportConfig()
            transportConfig.enableAllPeerToPeer()
            ditto.setTransportConfig(config: transportConfig)
            try! ditto.tryStartSync()
        }
    }

    var categories: AnyPublisher<[Category], Never> {
        return ditto.store.collection("categories").findAll()
            .publisher()
            .map({ snapshot in
                return snapshot.documents.map({
                    try! $0.typed(as: Category.self).value
                })
            })
            .eraseToAnyPublisher()
    }

    var products: AnyPublisher<[Product], Never> {
        return ditto.store.collection("products").findAll()
            .publisher()
            .map { snapshot in
                return snapshot.documents.map {
                    try! $0.typed(as: Product.self).value
                }
            }
            .eraseToAnyPublisher()
    }

    func productsBy(categoryName: String) -> AnyPublisher<[Product], Never> {
        return ditto.store.collection("products").find("categoryName == '\(categoryName)'")
            .publisher()
            .map { snapshot in
                return snapshot.documents.map {
                    try! $0.typed(as: Product.self).value
                }
            }
            .eraseToAnyPublisher()
    }

    var categoryWithProducts: AnyPublisher<[CategoryWithProducts], Never> {
        return ditto.store.collection("categories").findAll().publisher()
            .map { snapshot in
                return snapshot.documents.compactMap { [weak self] in
                    guard let self = self else { return nil }
                    let category = try! $0.typed(as: Category.self).value
                    let products = self.ditto.store.collection("products").find("categoryName == '\(category.name)'").exec()
                    return CategoryWithProducts(
                        category: category,
                        products: products.map { try! $0.typed(as: Product.self).value }
                    )
                }
            }
        .eraseToAnyPublisher()
    }

    func setDummyData() {
        let categories = ditto.store.collection("categories").findAll().exec()
        guard categories.isEmpty else { return /* set dummy only first time */ }

        try! ditto.store.collection("categories").upsert(Category(name: "drinks"))
        try! ditto.store.collection("categories").upsert(Category(name: "snacks"))

        try! ditto.store.collection("products").upsert(Product(name: "milk", categoryName: "drinks"))
        try! ditto.store.collection("products").upsert(Product(name: "chocolate", categoryName: "snacks"))
    }
}
