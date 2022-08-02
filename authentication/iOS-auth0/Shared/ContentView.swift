//
//  ContentView.swift
//  Shared
//
//  Created by Karissa McKelvey on 3/9/22.
//

import SwiftUI
import Auth0
import DittoSwift

class AuthDelegate: DittoAuthenticationDelegate {
    var token: String
    
    init (token: String) {
        self.token = token
    }
    func authenticationRequired(authenticator: DittoAuthenticator) {
        authenticator.loginWithToken(self.token, provider: "glitch") { err in
            print("Login request completed. Error? \(err)")
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
    
    func logout () {
        Auth0
            .webAuth()
            .clearSession(federated: false) { result in
                if result {
                    if (self.ditto != nil) {
                        self.ditto!.auth?.logout(cleanup: { ditto in
                            ditto.store.collection("cars").findAll().evict()
                        })
                    }
                    self.state = State.isLoading
                }
            }
    }
    
    func login () {
        Auth0
            .webAuth()
            .scope("openid profile")
            .audience("https://dev-0zipncfu.us.auth0.com/userinfo")
            .start { result in
                switch result {
                case .success(let credentials):
                    print("Obtained credentials: \(credentials)")
                    self.credentialsManager.store(credentials: credentials)
                    self.getProfile()
                case .failure(let error):
                    print("Failed with: \(error)")
                    self.state = State.failed(error)
                }
            }
    }
    
    func getProfile () {
        print("getting profile")
        self.state = State.isLoading
        credentialsManager.credentials { error, credentials in
            guard error == nil, let credentials = credentials else {
                // Handle error
                self.state = State.failed(error as! Error)
                return
            }
            
            guard let accessToken = credentials.accessToken else {
                // Handle Error
                self.state = State.failed(error as! Error)
                return
            }
        
            let identity = DittoIdentity.onlineWithAuthentication(
                appID: "YOUR_APP_ID_HERE",
                authenticationDelegate: AuthDelegate(token: accessToken)
            )

            let ditto = Ditto(identity: identity)
            try! ditto.startSync()
            
            self.ditto = ditto
            let liveQuery = ditto.store.collection("cars").findAll().observe { docs, event in
                self.docs = docs
            }
            
            print("getting profile")
            Auth0
                .authentication()
                .userInfo(withAccessToken: accessToken)
                .start { result in
                    switch(result) {
                    case .success(let profile):
                        self.state = State.loaded(profile)
                        print("got profile")
                    case .failure(let error):
                        // Handle the error
                        self.state = State.failed(error)
                    }
                }
        }
    }
        
}

struct ContentView: View {
    @ObservedObject var viewModel: ProfileViewModel = ProfileViewModel()
    
    var body: some View {
       
        switch viewModel.state {
        case .isLoading:
            Button("Login", action: viewModel.login)
                .padding()
        case .failed(let error):
            Text("Error!")
        case .loaded(let user):
            Text(user.name ?? "Unknown")
            Button("Logout", action: viewModel.logout)
            
        }
    
        Text("Cars:" + String(viewModel.docs.count))
        
    }
}
