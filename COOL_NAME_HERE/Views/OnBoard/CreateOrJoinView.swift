//
//  CreateOrJoinView.swift
//  COOL_NAME_HERE
//
//  Created by Hayden Davidson on 7/12/21.
//

import SwiftUI

struct CreateOrJoinView: View {
    @State private var isActive = false
    @State private var navigate = false
    @State private var goToLogin = false
    
    
    var body: some View {
        VStack {
            
            Section {
                Text("Welcome to CREW.")
                    .font(.title)
                    .foregroundColor(.brandPrimary)
                Text("Are you looking to create an account for your business or join an existing business?")
                    .padding(.vertical)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal)
            Divider()
                .padding()
            VStack(spacing: 16) {
                NavigationLink(destination: SetUpAccountView(setUpNewCompany: true), isActive: $isActive) {
                    CallToActionButton(title: "Create new business", action: {self.isActive.toggle()})
                }
                
                NavigationLink(destination: SetUpAccountView(setUpNewCompany: false), isActive: $navigate) {
                    CallToActionButton(title: "Join existing business") {
                        self.navigate.toggle()
                    }
                }
            }
            .padding(.horizontal)
            Divider()
                .padding()
            
            HStack {
                NavigationLink(destination: OnBoardLoginView(), isActive: $goToLogin) {
                    Button("Login") {
                        self.goToLogin.toggle()
                    }
                }
                Spacer()
            }
            .padding(.horizontal)
        }
        .navigationBarBackButtonHidden(true)
        .accentColor(.brandPrimary)
    }
}

struct CreateOrJoinView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            CreateOrJoinView()
        }
    }
}
