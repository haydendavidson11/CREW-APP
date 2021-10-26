//
//  LogoutButton.swift
//  COOL_NAME_HERE
//
//  Created by Hayden Davidson on 4/29/21.
//
import SwiftUI
import RealmSwift

struct LogoutButton: View {
    @EnvironmentObject var state: AppState
    @Environment(\.realm) var userRealm

    
    var body: some View {
        Button("Log Out") {
            state.shouldIndicateActivity = true
            logout()
        }
        .disabled(state.shouldIndicateActivity)
    }
    
    private func logout() {
        app.currentUser?.logOut()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in
            }, receiveValue: {
                state.shouldIndicateActivity = false
                state.logoutPublisher.send($0)
            })
            .store(in: &state.cancellables)
    }
}


//struct LogoutButton_Previews: PreviewProvider {
//    static var previews: some View {
//        LogoutButton()
//    }
//}
