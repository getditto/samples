//
//  AppDelegate.swift
//  ToDo
//
//  Created by Maximilian Alexander on 5/27/21.
//

import UIKit
import DittoSwift
import Fakery

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    static var ditto: Ditto!

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.

        Self.ditto = Ditto()
        Self.ditto.deviceName = makeupRandomDeviceName()
        try! Self.ditto.setLicenseToken(readLicenseToken())
        try! Self.ditto.tryStartSync()
        
        return true
    }

    // read license token:

    func readLicenseToken() -> String {
        let path = Bundle.main.path(forResource: "license_token", ofType: "txt") // file path for file "data.txt"
        let string = try! String(contentsOfFile: path!, encoding: String.Encoding.utf8)
        return string
    }

    func makeupRandomDeviceName() -> String {
        guard let name = UserDefaults.standard.string(forKey: "name") else {
            let faker = Faker()
            let name = faker.name.firstName()
            UserDefaults.standard.setValue(name, forKey: "name")
            return name
        }
        return name
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

