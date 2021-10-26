//
//  CheckForCompanyView.swift
//  COOL_NAME_HERE
//
//  Created by Hayden Davidson on 7/12/21.
//

import SwiftUI
import RealmSwift

struct SetUpAccountView: View {
    @EnvironmentObject var state: AppState
    @State private var userName = ""
    @State private var password = ""
    @State private var navigate = false
    @State private var loggedIn = false
    var setUpNewCompany: Bool
    
    var body: some View {
        VStack {
            Text("Lets set up your account.")
                .font(.title2)
                .foregroundColor(.brandPrimary)
            Divider()
            
            TextField("Email", text: $userName)
                .autocapitalization(.none)
                .textContentType(.emailAddress)
            SecureField("Password", text: $password)
                .textContentType(.password)
            
            Divider()
            
            if setUpNewCompany {
                
                CallToActionButton(title: state.confirmationSent ? "Set up your business" : "Confirm Email") {
                    state.setUpNewCompany = true
                    if state.confirmationSent {
                        login(username: userName, password: password)
                    } else {
                        signup(username: userName, password: password)
                    }
                }
                .padding(.vertical)
                
                
            } else {
                
                CallToActionButton(title: state.confirmationSent ? "Set up profile" : "Confirm Email") {
                    state.setUpNewCompany = false
                    if state.confirmationSent {
                        login(username: userName, password: password)
                    } else {
                        signup(username: userName, password: password)
                    }
                }
                .padding(.vertical)
                
                
            }
            
            // TODO: Implement sign in with Apple
            //            SignInWithApple()
            //                .frame(height: 50)
            //                .onTapGesture(perform: loginWithApple)
            //                .cornerRadius(50)
            
            
        }
        .padding()
        .accentColor(.brandPrimary)
    }
    
    private func loginWithApple() {
        let credentials = Credentials.apple(idToken: "<token>")
        app.login(credentials: credentials)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: {
                state.shouldIndicateActivity = false
                switch $0 {
                case .finished:
                    break
                case .failure(let error):
                    self.state.error = error.localizedDescription
                }
            }, receiveValue: {
                self.state.error = nil
                state.loginPublisher.send($0)
            })
            .store(in: &state.cancellables)
    }
    
    
    private func signup(username: String, password: String) {
        if username.isEmpty || password.isEmpty {
            state.shouldIndicateActivity = false
            return
        }
        self.state.error = nil
        app.emailPasswordAuth.registerUser(email: username, password: password)
            .print()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: {
                state.shouldIndicateActivity = false
                switch $0 {
                case .finished:
                    break
                case .failure(let error):
                    self.state.error = error.localizedDescription
                    if error.localizedDescription ==  "confirmation required" {
                        state.confirmationSent = true
                    }
                        
                        
                }
            }, receiveValue: {
                self.state.error = nil
                login(username: username, password: password)
            })
            .store(in: &state.cancellables)
    }
    
    
    private func login(username: String, password: String)  {
        if username.isEmpty || password.isEmpty {
            state.shouldIndicateActivity = false
            return
        }
        self.state.error = nil
        app.login(credentials: .emailPassword(email: username, password: password))
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: {
                state.shouldIndicateActivity = false
                switch $0 {
                case .finished:
                    break
                case .failure(let error):
                    self.state.error = error.localizedDescription
                }
            }, receiveValue: {
                self.state.error = nil
                state.loginPublisher.send($0)
            })
            .store(in: &state.cancellables)
    }
}

//struct CheckForCompanyView_Previews: PreviewProvider {
//    static var previews: some View {
//        SetUpAccountView()
//    }
//}
