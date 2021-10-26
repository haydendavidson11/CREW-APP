//
//  LoginView.swift
//  COOL_NAME_HERE
//
//  Created by Hayden Davidson on 4/12/21.
//


import SwiftUI
import RealmSwift
import AuthenticationServices

struct LoginView: View {
    
    @EnvironmentObject var state: AppState
    @State var username = ""
    @State private var password = ""
    @State var newUser = false
    @State private var emailSent = false
    
    @State private var showingPasswordResetSheet = false
    
    private enum Dimensions {
        static let padding: CGFloat = 16.0
    }
    
    var body: some View {
        VStack(spacing: Dimensions.padding) {
            Spacer()
            Image("logo")
                .resizable()
                .scaledToFit()
                .frame(height: 100)
            Spacer()
            InputField(title: "Email/Username",
                       text: self.$username)
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
            InputField(title: "Password",
                       text: self.$password,
                       showingSecureField: true)
            CallToActionButton(
                title: "Log In",
                action: { self.userAction(username: self.username, password: self.password) })
            
            // TODO: Implement sign in with Apple
            //                    SignInWithApple()
            //                        .frame(height: 50)
            //                        .onTapGesture(perform: loginWithApple)
            //                        .cornerRadius(50)
            
            
            Divider()
            
            HStack {
                NavigationLink(destination: CreateOrJoinView()) {
                    Text("Create New Account")
                        .foregroundColor(.brandPrimary)
                }
                Spacer()
                
            }
            HStack {
                NavigationLink {
                    ResetPasswordView(email: $username)
                } label: {
                   Text("Forgot Password?")
                        .foregroundColor(.brandPrimary)
                }
                
               
                
                Spacer()
            }
            Spacer()
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(true)
        .padding(.horizontal, Dimensions.padding)

    }
    
    private func userAction(username: String, password: String) {
        state.shouldIndicateActivity = true
        if newUser {
            signup(username: username, password: password)
        } else {
            login(username: username, password: password)
        }
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
                }
            }, receiveValue: {
                self.state.error = nil
                login(username: username, password: password)
            })
            .store(in: &state.cancellables)
    }
    
    // TODO: Implement sign in with Apple
    //    private func showAppleLogin() {
    //      // 1
    //      let request = ASAuthorizationAppleIDProvider().createRequest()
    //
    //      // 2
    //      request.requestedScopes = [.fullName, .email]
    //
    //      // 3
    //      let controller = ASAuthorizationController(authorizationRequests: [request])
    //    }
    
    // TODO: Implement sign in with Apple
    //    private func loginWithApple() {
    //        showAppleLogin()
    //
    //        let credentials = Credentials.apple(idToken: "<token>")
    //        print(credentials)
    //        app.login(credentials: credentials)
    //            .receive(on: DispatchQueue.main)
    //            .sink(receiveCompletion: {
    //                    state.shouldIndicateActivity = false
    //                    switch $0 {
    //                    case .finished:
    //                       break
    //                    case .failure(let error):
    //                       self.state.error = error.localizedDescription
    //                    }
    //              }, receiveValue: {
    //                    self.state.error = nil
    //                    state.loginPublisher.send($0)
    //              })
    //              .store(in: &state.cancellables)
    //    }
    
    private func login(username: String, password: String) {
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

//struct LoginView_Previews: PreviewProvider {
//    static var previews: some View {
//                LoginView()
//    }
//}

