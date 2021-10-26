//
//  MeView.swift
//  COOL_NAME_HERE
//
//  Created by Hayden Davidson on 4/28/21.
//

import SwiftUI
import RealmSwift




struct MeView: View {
//    @EnvironmentObject var monthModel : MDPModel
    @EnvironmentObject var state: AppState
    @State private var userName = ""
//    @StateObject var monthModel = MDPModel()
    
    var body: some View {
        if state.loggedIn && state.userHasCompany {
            NavigationView {
                VStack(alignment: .center) {
                    AvatarThumbNailView(photo: state.user?.userPreferences?.avatarImage ?? Photo(), imageSize: 100 )
                    
                    Text(state.user?.userPreferences?.displayName ?? "Set DisplayName")
                        .lineLimit(1)
                        .minimumScaleFactor(0.75)
                    if state.user?.role != nil {
                        UserRoleView()
                            .environment(\.realmConfiguration,
                                          app.currentUser!.configuration(partitionValue: "public=public"))
                    }
                    
                    
                    List {
                        Section(header: Text("Schedule")) {
//                            NavigationLink("Requests", destination: ScheduleView())
                            NavigationLink("My Availability", destination: AvailabilityView()
//                                            .environmentObject(monthModel)
//                                            .environmentObject(state)
                                            .environment(\.realmConfiguration,
                                                          app.currentUser!.configuration(partitionValue: "user=\(state.user?._id ?? "")")))
                            NavigationLink("My Schedule") {
                                ScheduleView()
                                
                            }
                            NavigationLink("Shift Requests") {
                            
                                    ShiftRequestListView()
                                        .environment(\.realmConfiguration,
                                                  app.currentUser!.configuration(partitionValue: "public=public"))
                            }
                        }
                        Section(header: Text("Time Sheet")) {
                            NavigationLink("Hours Worked", destination: Text("Hours Worked"))
                            NavigationLink("Get Paid", destination: Text("Get Paid"))
                        }
                        Section(header: Text("Settings")) {
                            NavigationLink("Edit Profile", destination: ProfileView()
                                            .environment(\.realmConfiguration,
                                                          app.currentUser!.configuration(partitionValue: "user=\(state.user?._id ?? "")")))
                        }
                        
                        
                        
                    }
                    .navigationBarItems(trailing: state.loggedIn ? LogoutButton() : nil)
                    
                }
            }
        } else {
            if state.loggedIn {
                VStack(alignment: .center) {
                    AvatarThumbNailView(photo: state.user?.userPreferences?.avatarImage ?? Photo(), imageSize: 100 )
                    
                    Text(state.user?.userPreferences?.displayName ?? "Set DisplayName")
                        .lineLimit(1)
                        .minimumScaleFactor(0.75)
                    
                    List {
                        Section(header: Label("Settings", systemImage: "gear")) {
                            NavigationLink("Edit Profile", destination: ProfileView()
                                            .environment(\.realmConfiguration,
                                                          app.currentUser!.configuration(partitionValue: "user=\(state.user?._id ?? "")")))
                        }
                        RequestListView()
                            .environment(\.realmConfiguration,
                                          app.currentUser!.configuration(partitionValue: "public=public"))
                    }
                    .refreshable {
                        print(state.userHasCompany)
                        if state.userHasCompany {
                            print("reload dashboard")
                            
                        }
                    }
                }
                .navigationBarItems(trailing: state.loggedIn ? LogoutButton() : nil)
            }
        }
    }
    
}

struct MeView_Previews: PreviewProvider {
    static var previews: some View {
        MeView()
    }
}

struct RequestListView: View {
    @ObservedResults(Request.self) var requests
    @EnvironmentObject var state: AppState
    
    var filteredRequests: Results<Request> {
        return requests.filter(NSPredicate(format: "crewMember == %@", state.user!.userName))
    }
    
    var body: some View {
        Section(header: Label("Company Invites", systemImage: "envelope")) {
            if state.user?.companyID == "pending" && filteredRequests.count < 1 {
                Text("We found a pending request for you. Give us a moment to pull up the details.")
            } else {
                ForEach(filteredRequests) { request in
                    RequestView(request: request)
                        .environment(\.realmConfiguration,
                                      app.currentUser!.configuration(partitionValue: "public=public"))
                        
                }
            }
        }
    }
}

struct UserRoleView: View {
    @EnvironmentObject var state: AppState
    @ObservedResults(Company.self) var companies
    
    
    var userCompany: String {
        let company = companies.first { company in
            company._id == state.user?.companyID
        }
        if company != nil {
            return company!.companyName
        } else {
            return "Unknown"
        }
        
    }
    
    
    var body: some View {
        Text("\(state.user?.role ?? "") of \(userCompany)")
            .font(.caption)
    }
}
