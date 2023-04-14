//
//  ContentView.swift
//  iOS-auth0
//
//  Created by Karissa McKelvey on 3/9/22.
//

import Auth0
import Combine
import DittoSwift
import SwiftUI

class AuthDelegate: DittoAuthenticationDelegate {
    var token: String
    
    init (token: String) {
        self.token = token
    }
    
    func authenticationRequired(authenticator: DittoAuthenticator) {
        authenticator.loginWithToken(self.token, provider: "glitch") { error in
            if let err = error {
                print("\(#function).authenticator.loginWithToken callback: Login request completed with error: \(err.localizedDescription)")
            }
        }
    }

    func authenticationExpiringSoon(authenticator: DittoAuthenticator, secondsRemaining: Int64) {
        print("Auth token expiring in \(secondsRemaining)")
    }
}

extension Ditto {
    struct Config {
        static var appID = "YOUR_APP_ID_HERE"
    }
}

class ProfileViewModel: ObservableObject {
    enum State {
        case isLoading
        case failed(Error)
        case loaded(UserInfo)
    }

    let credentialsManager = CredentialsManager(authentication: Auth0.authentication())
    @Published var ditto: Ditto?
    @Published private(set) var state = State.isLoading
    @Published var docs: [DittoDocument] = []
    var authDelegate = AuthDelegate(token: "")
    var carsPublisherCancellable: AnyCancellable? = AnyCancellable({})

    func setCarsPublisher() {
        guard let ditto = self.ditto else { return }
        
        carsPublisherCancellable = ditto.store.collection("cars")
            .findAll()
            .liveQueryPublisher()
            .map { docs, _ in
                docs
            }
            .receive(on: DispatchQueue.main)
            .sink {[weak self] docs in
                self?.docs = docs
            }
    }
    
    func logout() {
        Task {
            ditto?.store["cars"].findAll().evict()
            
            await MainActor.run {
                carsPublisherCancellable = nil
                docs = []
                state = .isLoading
                ditto?.stopSync()
            }
            
            ditto?.auth?.logout()
            
            do {
                try await Auth0.webAuth().clearSession()
            } catch {
                print("Auth0 logout error: \(error.localizedDescription)")
            }
        }
    }
    
    func login() {
        Task {
            do {
                let creds = try await Auth0.webAuth().scope("openid profile").start()
                let _ = credentialsManager.store(credentials: creds)
                
                await getProfile()
            } catch {
                await MainActor.run { self.state = .failed(error) }
                print("Auth0 login error: \(error.localizedDescription)")
            }
        }
    }
    
    func getProfile() async {
        
        await MainActor.run { self.state = .isLoading }
        
        do {
            let creds = try await credentialsManager.credentials(withScope: "openid profile")
            authDelegate.token = creds.accessToken
            
            if ditto == nil {
                let identity = DittoIdentity.onlineWithAuthentication(
                    appID: Ditto.Config.appID,
                    authenticationDelegate: authDelegate
                )
                
                let ditto = Ditto(identity: identity)
                
                await MainActor.run {[weak self] in
                    self?.ditto = ditto
                    self?.setCarsPublisher()
                }
            } else {
                authDelegate.authenticationRequired(authenticator: ditto!.auth!)
                setCarsPublisher()
            }
            
            do {
                try ditto!.startSync()
            } catch {
                await MainActor.run { self.state = .failed(error) }
                print("\(#function) Error: \(error.localizedDescription)")
            }
            
            
            do {
                let profile = try await Auth0.authentication()
                    .userInfo(withAccessToken: authDelegate.token)
                    .start()
                await MainActor.run { self.state = .loaded(profile) }
            } catch {
                await MainActor.run { self.state = .failed(error) }
                print("\(#function) Error: \(error.localizedDescription)")
            }
            
        } catch {
            print("\(#function) Error: \(error.localizedDescription)")
            await MainActor.run { self.state = .failed(error) }
        }
    }
    
    func addCar() {
        try! ditto!.store["cars"].upsert([
            "make": "Tesla"
        ] as [String: Any?])
    }
}

struct ContentView: View {
    @StateObject var viewModel: ProfileViewModel = ProfileViewModel()
    
    var body: some View {
        VStack {
            switch viewModel.state {
            case .isLoading:
                Button("Login") { viewModel.login() }
                    .padding()
                
            case .failed(let error):
                Text("Error!\n\(error.localizedDescription)")
                
            case .loaded(let user):
                Text(user.name ?? "Unknown")
                
                Button("Logout") {
                    Task { viewModel.logout() }
                }
                .padding()
                
                Button("Add car") {
                    viewModel.addCar()
                }
                .padding()
            }
            
            Text("Cars: " + String(viewModel.docs.count))
        }
    }
}
