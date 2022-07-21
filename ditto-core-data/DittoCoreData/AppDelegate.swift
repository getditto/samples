//
//  AppDelegate.swift
//  DittoCoreData
//
//  Created by Maximilian Alexander on 6/17/21.
//

import UIKit
import DittoSwift
import CoreData

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    static var persistentContainer: NSPersistentContainer!
    static var ditto: Ditto!

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.

        Self.ditto = {
            // read license token
            let path = Bundle.main.path(forResource: "license_token", ofType: "txt") // file path for file "data.txt"
            let licenseToken = try! String(contentsOfFile: path!, encoding: String.Encoding.utf8)
            let ditto = Ditto()
            try! ditto.setOfflineOnlyLicenseToken(licenseToken)
            try! ditto.startSync()
            return ditto
        }()

        Self.persistentContainer = {
            let container = NSPersistentContainer(name: "Model")
            container.loadPersistentStores(completionHandler: { (storeDescription, error) in
                if let error = error as NSError? {
                    fatalError("Unresolved error \(error), \(error.userInfo)")
                }
            })
            return container

        }()

        window = UIWindow()
        window?.rootViewController = {
            let navigationController = UINavigationController(rootViewController: StartViewController())
            return navigationController
        }()
        window?.makeKeyAndVisible()
        return true
    }


}

