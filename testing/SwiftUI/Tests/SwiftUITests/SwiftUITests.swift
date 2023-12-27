import XCTest
import DittoSwift


final class SwiftUITests: XCTestCase {

    var ditto1: DittoInstance!
    var ditto2: DittoInstance!

    override func setUp() {
        self.ditto1 = DittoInstance()
        self.ditto2 = DittoInstance()
        try! self.ditto1.ditto?.startSync()
        try! self.ditto2.ditto?.startSync()
    }

    func testExample() async throws {
        let exeption = expectation(description: "doc inserted")
        let collectionName = "cars"

        // Inserting a car into 'ditto1' store
        let car = ["make": "toyota", "color": "red"]
        try await ditto1!.ditto!.store.execute(
            query: "INSERT INTO \(collectionName) DOCUMENTS (:car)",
            arguments: ["car": car]
        )

        let selectQuery = "SELECT * FROM \(collectionName)"

        // Registering a subscription from 'ditto2'
        try ditto2.ditto!.sync.registerSubscription(query: selectQuery)

        // Registering a result observer on 'ditto2' store
        try ditto2.ditto!.store.registerObserver(query: selectQuery) { result in
            print("@@ Result:", result.items.count)
            if let value = result.items.first?.value {
                XCTAssertEqual(value["make"] as! String, "toyota")
                exeption.fulfill()
            }
        }

        await fulfillment(of: [exeption], timeout: 5)
    }
}


func topLevelDittoDir() -> URL {
    let fileManager = FileManager.default
    return try! fileManager.url(
        for: .documentDirectory,
        in: .userDomainMask,
        appropriateFor: nil,
        create: false
    ).appendingPathComponent("ditto_top_level")
}


/// Test helper which wraps a Ditto instance.
public class DittoInstance {
    internal var ditto: Ditto?
    private let instanceDir: URL

    public init() {
        let appID = "YOUR_LICENSE_HERE"
        let onlinePlaygroundToken = "YOUR_LICENSE_HERE"

        // No need for cleanup, as the TestsSetup class is configured as NSPrincipalClass
        // and will delete topLevelDittoDir() before any test job is run
        let instanceDir = topLevelDittoDir()
            .appendingPathComponent(appID)
            .appendingPathComponent(UUID().uuidString)

        self.instanceDir = instanceDir
        self.ditto = Ditto(
            identity: .onlinePlayground(appID: appID, token: onlinePlaygroundToken, enableDittoCloudSync: false),
            persistenceDirectory: instanceDir
        )

        try! self.ditto!.disableSyncWithV3()
    }

    public func stop() {
        self.ditto!.stopSync()
        self.ditto = nil
    }
}
