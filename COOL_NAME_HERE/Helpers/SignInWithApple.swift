//
//  SignInWithApple.swift
//  SignInWithApple
//
//  Created by Hayden Davidson on 7/26/21.
//

import SwiftUI
import AuthenticationServices

// 1
final class SignInWithApple: UIViewRepresentable {
    // 2
    func makeUIView(context: Context) -> ASAuthorizationAppleIDButton {
        // 3
        return ASAuthorizationAppleIDButton()
    }
    
    
    func updateUIView(_ uiView: ASAuthorizationAppleIDButton, context: Context) {
    }
}
