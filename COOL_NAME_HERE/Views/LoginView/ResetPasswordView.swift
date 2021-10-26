//
//  ResetPasswordView.swift
//  ResetPasswordView
//
//  Created by Hayden Davidson on 9/20/21.
//

import SwiftUI
import RealmSwift

struct ResetPasswordView: View {
    
    @EnvironmentObject var state: AppState
    
    @Binding var email: String
    
    @State private var emailSent = false
    
    
    var body: some View {
        VStack {
            Image(systemName: "lock.shield")
                .resizable()
                .scaledToFit()
                .foregroundColor(.brandPrimary)
                .frame(height: 200)
                .padding()
            
            InputField(title: "Email/Username", text: $email, showingSecureField: false)
                .padding(.horizontal)
                .textContentType(.emailAddress)
            
            CallToActionButton(title: "Send password reset email") {
                app.emailPasswordAuth.sendResetPasswordEmail(email: self.email)
                withAnimation {
                    self.emailSent = true
                }
            }
            .padding(.horizontal)
            .disabled(email.isEmpty)
            
            if emailSent {
                Text("Email Sent: click the link and enter new password.")
                    .padding()
            }

        }
    }
}

struct ResetPasswordView_Previews: PreviewProvider {
    static var previews: some View {
        ResetPasswordView(email: .constant(""))
    }
}
