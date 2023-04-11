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
    private var cancellables = Set<AnyCancellable>()
    
    func logout() {
        docs = []
        state = .isLoading

        Task {
            do {
                ditto?.auth?.logout(cleanup: { ditto in
                    print("logout() ditto.auth.logout.cleanup closure - evict all from cars")
                    ditto.store.collection("cars").findAll().evict()
                })

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
                
                await MainActor.run {
                    self.ditto?.stopSync()
                    self.ditto = nil
                }
                
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
            
            let accessToken = creds.accessToken
            let identity = DittoIdentity.onlineWithAuthentication(
                appID: Ditto.Config.appID,
                authenticationDelegate: AuthDelegate(token: accessToken)
            )
            
            let ditto = Ditto(
                identity: identity,
                persistenceDirectory: Ditto.newPersistenceDir
            )
            
            do {
                try ditto.startSync()
            } catch {
                print("\(#function): ditto.startSync() Error: \(error.localizedDescription)")
            }
            
            await MainActor.run {[weak self] in
                self?.ditto = ditto
                
                let _ = ditto.store.collection("cars").findAll().observeLocal {[weak self] docs, event in
                    self?.docs = docs
                }
            }
            
            do {
                let profile = try await Auth0.authentication().userInfo(withAccessToken: accessToken).start()
                await MainActor.run { self.state = .loaded(profile) }
            } catch {
                print("\(#function): Auth0.getProfile failed with error: \(error.localizedDescription)")
                await MainActor.run { self.state = .failed(error) }
            }
            
        } catch {
            await MainActor.run { self.state = .failed(error) }
            print("\(#function): Auth0.credentialsManger.credentials() Error: \(error.localizedDescription)")
        }
    }
    
    func addCar() {
        try! ditto!.store.collection("cars").upsert([
            "make": "Toyota"
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
            
            Text("Cars:" + String(viewModel.docs.count))
        }
    }
}
