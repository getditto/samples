import XCTest
import DittoSwift


final class SwiftUITests: XCTestCase {
   
    var ditto1: DittoInstance!
    var ditto2: DittoInstance!
    
    override func setUp() {
        self.ditto1 = DittoInstance(appID: "test-app")
        self.ditto2 = DittoInstance(appID: "test-app")
        try! self.ditto1.ditto?.tryStartSync()
        try! self.ditto2.ditto?.tryStartSync()
    }
    
    func testExample() throws {
        let initialResultExpectation = expectation(description: "Initial event received")
        let docID = try! ditto1.ditto!.store.collection("cars").upsert(["make": "toyota", "color": "red"])
        let subs = ditto2.ditto!.store.collection("cars").findByID(docID).subscribe()
        let liveQuery = ditto2.ditto!.store.collection("cars").findByID(docID).observeLocal { doc, event in
            if (!event.isInitial) {
                XCTAssertEqual(doc!.value["make"] as! String, "toyota")
                initialResultExpectation.fulfill()
            }
        }
        
        wait(for: [initialResultExpectation], timeout: 2)
        subs.stop()
        liveQuery.stop()
        ditto1.stop()
        ditto2.stop()
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
    
    public init(appID: String) {
        
        // No need for cleanup, as the TestsSetup class is configured as NSPrincipalClass
        // and will delete topLevelDittoDir() before any test job is run
        let instanceDir = topLevelDittoDir()
            .appendingPathComponent(appID)
            .appendingPathComponent(UUID().uuidString)

        self.instanceDir = instanceDir
        self.ditto = Ditto(
            identity: .offlinePlayground(appID: appID, persistenceDirectory: instanceDir),
            persistenceDirectory: instanceDir
        )
        let testLicense = "YOUR_LICENSE_HERE"
        try! self.ditto!.setOfflineOnlyLicenseToken(testLicense)
    }
    
    public func stop() {
        self.ditto!.stopSync()
        self.ditto = nil
    }
}
