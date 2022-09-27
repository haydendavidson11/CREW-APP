//
//  ContentView.swift
//  COOL_NAME_HERE
//
//  Created by Hayden Davidson on 3/27/21.
//

import Foundation
import SwiftUI
import RealmSwift

struct ContentView: View {
    @EnvironmentObject var state: AppState
    
    @State private var userName = ""
    @State private var password = ""
    @State private var ToMeView = false
    @State private var ToMainView = false
    @State private var ToProfileSetup = false
    @State private var ToCheckForCompanyView = false
    
    
    // Navigates the user to the main view when appropriate
    var goToMainView: Bool {
        if state.loggedIn && state.user != nil && state.user?.userPreferences != nil && state.userHasCompany {
            
            return true
        } else {
            
            return false
        }
    }
    
    // Navigates the user to the profile setup view when the user has no profile
    var goToProfileSetup: Bool {
        if state.loggedIn && state.user != nil && state.user?.userPreferences == nil {
            
            return true
        } else {
            
            return false
        }
    }
    
    // Navigates the user to either send a request to join a company or view a pending request.
    var goToCheckForCompanyView: Bool {
        if state.loggedIn && state.user != nil && state.user?.userPreferences != nil && state.userHasCompany == false {
            
            return true
        } else {
            
            return false
        }
    }
    
    // Navigates the user to a version of Me View when the user's company ID is set to "pending".
    var goToMeView: Bool {
        if state.loggedIn
            && state.user != nil
            && state.user?.userPreferences != nil
            && state.user?.companyID == "pending"
        {
            return true
        }
            return false
    }
    
    var body: some View {
        ZStack {
            VStack {
                if (state.user != nil) && state.loggedIn {
                    if goToMainView {
                        MainView()
                    } else if goToProfileSetup {
                        NavigationView {
                            ProfileSetupView()
                            // Opens the user realm on this View
                                .environment(\.realmConfiguration,
                                              app.currentUser!.configuration(partitionValue: "user=\(state.user?._id ?? "")"))
                        }
                    } else if goToMeView {
                        NavigationView {
                            MeView()
                            // Opens the user realm on this View
                                .environment(\.realmConfiguration,
                                              app.currentUser!.configuration(partitionValue: "user=\(state.user?._id ?? "")"))
                        }
                    } else if goToCheckForCompanyView {
                        NavigationView {
                            ConfirmCompanyView(userID: state.user?._id ?? "")
                            // Opens the user's realm on this view 
                                .environment(\.realmConfiguration,
                                              app.currentUser!.configuration(partitionValue: "user=\(state.user?._id ?? "")"))
                        }
                    }
                    
                } else {
                    NavigationView{
                        LoginView()
                            .navigationViewStyle(StackNavigationViewStyle())
                    }
                    
                }
            }
        }
        .accentColor(.brandPrimary)
        
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
