//
//  DittoManager.swift
//  Tasks
//
//  Created by Rae McKelvey on 11/23/22.
//

import Combine
import DittoSwift
import DittoExportLogs

// FOR INTERNAL USE ONLY: currently set to Eric's TasksV4Personal dev portal app
// Change to your portal-dev app creds if desired
let authToken = "password"
let authProvider = "auth-webhook"
let appID = "8edded63-8c68-4acc-92ad-e4206cd415b7"

//------------------------------------------------------------------------------------------
// TEST smallPeerInfo with v4.4.4 on portal-dev.ditto.live
class AuthDelegate: DittoAuthenticationDelegate {
    func authenticationRequired(authenticator: DittoAuthenticator) {
        authenticator.login(
            token: authToken,
            provider: authProvider
        )  { clientInfo, err in
            print("Login request completed \(err == nil ? "successfully!" : "with error: \(err.debugDescription)")")
        }
    }

    func authenticationExpiringSoon(authenticator: DittoAuthenticator, secondsRemaining: Int64) {
        authenticator.login(
            token: authToken,
            provider: authProvider
        )  { clientInfo, err in
            print("Login request completed \(err == nil ? "successfully!" : "with error: \(err.debugDescription)")")
        }
    }
}
//------------------------------------------------------------------------------------------

class DittoManager: ObservableObject {
    @Published var loggingOption: DittoLogger.LoggingOptions = .debug
    private static let defaultLoggingOption: DittoLogger.LoggingOptions = .debug//.error
    private var cancellables = Set<AnyCancellable>()
    
    var ditto: Ditto
    
    static var shared = DittoManager()
    
    init() {
        
        self.loggingOption = Self.storedLoggingOption()        
        
        //------------------------------------------------------------------------------------------
        // TEST smallPeerInfo with v4.4.4 on portal-dev.ditto.live
        let authDelegate = AuthDelegate()

        print("DittoManager.init(): initialize Ditto instance")
        self.ditto = Ditto(identity:
            .onlineWithAuthentication(
                appID: appID,
                authenticationDelegate: authDelegate,
                enableDittoCloudSync: false,
                customAuthURL: URL(string: "https://\(appID).cloud-dev.ditto.live")
            )
        )
        
        var config = DittoTransportConfig()
        config.connect.webSocketURLs.insert("wss://\(appID).cloud-dev.ditto.live")
        config.enableAllPeerToPeer()
        ditto.transportConfig = config
        
        // enable smallPeerInfo
        // don't change syncScope from .bigPeerOnly default
        ditto.smallPeerInfo.isEnabled = true
        ditto.smallPeerInfo.syncScope = .bigPeerOnly
        //------------------------------------------------------------------------------------------
        
        // update to v4 AddWins
        do {
            try ditto.disableSyncWithV3()
        } catch let error {
            print("ERROR: disableSyncWithV3() failed with error \"\(error)\"")
        }
        
        // make sure log level is set _before_ starting ditto.
        resetLogging()

        // Prevent Xcode previews from syncing: non-preview simulators and real devices can sync
        let isPreview: Bool = ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
        if !isPreview {
            try! ditto.startSync()
        }
    }
}

extension DittoManager {
    func updateSmallPeerInfoMetadata(_ dict: [String: Any]) {
        do {
            try ditto.smallPeerInfo.setMetadata(dict)
            print("DM.\(#function): smallPeerInfo.metadata set to \(ditto.smallPeerInfo.metadata)")
        } catch {
            print("DM.\(#function): Error setting smallPeerInfo.metadata: \(error.localizedDescription)")
        }
    }
}

extension DittoManager {
    enum UserDefaultsKeys: String {
        case loggingOption = "live.ditto.Tasks-smallPeerInfo.loggingOption"
    }

    fileprivate func storedLoggingOption() -> DittoLogger.LoggingOptions {
        return Self.storedLoggingOption()
    }
    
    // static function for use in init() at launch
    fileprivate static func storedLoggingOption() -> DittoLogger.LoggingOptions {
        if let logOption = UserDefaults.standard.object(
            forKey: UserDefaultsKeys.loggingOption.rawValue
        ) as? Int {
            return DittoLogger.LoggingOptions(rawValue: logOption)!
        } else { //returns the defaultLoggingOption defined above
            return DittoLogger.LoggingOptions(rawValue: defaultLoggingOption.rawValue)!
        }
    }
    
    fileprivate func saveLoggingOption(_ option: DittoLogger.LoggingOptions) {
        UserDefaults.standard.set(option.rawValue, forKey: UserDefaultsKeys.loggingOption.rawValue)
    }

    fileprivate func resetLogging() {
        let logOption = Self.storedLoggingOption()
        switch logOption {
        case .disabled:
            DittoLogger.enabled = false
        default:
            DittoLogger.enabled = true
            DittoLogger.minimumLogLevel = DittoLogLevel(rawValue: logOption.rawValue)!
            if let logFileURL = DittoLogManager.shared.logFileURL {
                DittoLogger.setLogFileURL(logFileURL)
            }
        }
    }
}
