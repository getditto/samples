///
//  DittoHelpers.swift
//  iOS-auth0
//
//  Created by Eric Turner on 4/10/23.
//
//  Copyright © 2023 DittoLive Incorporated. All rights reserved.

import DittoSwift
import SwiftUI

extension Ditto {
    struct Config {
        static var appID = "YOUR_APP_ID_HERE"
    }
}

///  The following Ditto static properties and function extension are to work around an known issue as of iOS SDK v4.0.0,
///  where a Ditto instance, when set to nil, should release references and resources relating to it but do not right away.
extension Ditto {

    ///  The following directory accessors are used in this demo app to create a new persistence directory for every new authentication
    ///  login. This works around the above mentioned issue of Ditto instance resources not being released right away when initializing
    ///   a new Ditto instance for every new login.
    static var newPersistenceDir: URL? {
        return Ditto.dittoPersistenceDir
            .appendingPathComponent(UUID().uuidString)
    }

    static var dittoPersistenceDir: URL {
        let fileManager = FileManager.default
        return try! fileManager.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: false
        )
        .appendingPathComponent("Ditto", isDirectory: true)
        .appendingPathComponent("PersistenceDirectories", isDirectory: true)
    }
    
    /// This utility function removes accumulated  persistence directories from the filesystem as a cleanup for the workaround
    /// mentioned above.
    static func cleanupAppSupportDir() {
        let fileManager = FileManager.default
        let topDirPath = Self.dittoPersistenceDir.path

        if let paths = try? fileManager.contentsOfDirectory(atPath: topDirPath) {
            for dirPath in paths {
                let fullPath = "\(topDirPath)/\(dirPath)"
                try? fileManager.removeItem(atPath: fullPath)
            }
        }
    }
}

/// This helper class simply listens for an application termination notification and then calls the Ditto cleanup extension function.
class CleanupHelper {
    private var observer: NSObjectProtocol
    
    init() {
        self.observer = NotificationCenter.default.addObserver(
            forName: UIApplication.willTerminateNotification,
            object: nil,
            queue: .main)
        { _ in
            Ditto.cleanupAppSupportDir()
        }
    }
    
    deinit { NotificationCenter.default.removeObserver(observer) }
}



