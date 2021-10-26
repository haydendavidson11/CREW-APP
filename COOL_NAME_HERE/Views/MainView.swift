//
//  MainView.swift
//  COOL_NAME_HERE
//
//  Created by Hayden Davidson on 3/28/21.
//

// This is the Main Tab View of the app. Once the user is logged in, has a company, and has setup their profile they are directed here.

import SwiftUI
import RealmSwift

struct MainView: View {
    
    @EnvironmentObject var state: AppState
    
    var body: some View {
        TabView {
            if state.loggedIn {
                ClientsView()
                    .tabItem { Image(systemName: "person.3")
                        Text("Clients")
                    }
                // Opens the companies public realm
                    .environment(\.realmConfiguration,
                                  app.currentUser!.configuration(partitionValue: "public=\(state.user?.companyID ?? "")"))
                JobsList()
                    .tabItem {
                        Image(systemName: "wrench.and.screwdriver")
                        Text("Jobs")
                    }
                // Opens the companies public realm
                    .environment(\.realmConfiguration,
                                  app.currentUser!.configuration(partitionValue: "public=\(state.user?.companyID ?? "")"))
                
                TodayView()
                    .tabItem { Image(systemName: "calendar")
                        Text("Today")
                        
                    }
                // Opens the companies public realm
                    .environment(\.realmConfiguration,
                                 app.currentUser!.configuration(partitionValue: "public=\(state.user?.companyID ?? "")"))
                
                CompanyView()
                    .tabItem {
                        Image(systemName: "building.2")
                        Text("Business")
                    }
                // Opens the public realm
                    .environment(\.realmConfiguration,
                                 app.currentUser!.configuration(partitionValue: "public=public"))
                
                
                MeView()
                // Opens the user's realm
                    .environment(\.realmConfiguration,
                                 app.currentUser!.configuration(partitionValue: "user=\(state.user?._id ?? "")"))
                    .tabItem {
                        Image(systemName: "person")
                        Text("Me")
                    }
            } else {
                NavigationView {
                    LoginView()
                }
            }
            
        }
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
