//
//  MeView.swift
//  COOL_NAME_HERE
//
//  Created by Hayden Davidson on 4/28/21.
//

import SwiftUI
import RealmSwift

struct MeView: View {
    
    @EnvironmentObject var state: AppState
    @State private var userName = ""
    
    
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
                        Section(header: Label("Schedule", systemImage: "calendar.circle")) {
                            
                            NavigationLink("My Availability", destination: AvailabilityView()
                                           
                                            .environment(\.realmConfiguration,
                                                          app.currentUser!.configuration(partitionValue: "user=\(state.user?._id ?? "")")))
                                            .environmentObject(state)
                            NavigationLink("My Schedule") {
                                ScheduleView()
                                
                            }
                            NavigationLink("Shift Requests") {
                                
                                ShiftRequestListView()
                                    .environment(\.realmConfiguration,
                                                  app.currentUser!.configuration(partitionValue: "public=public"))
                            }
                        }
                        
// TODO:
//                        Section(header: Text("Time Sheet")) {
//                            NavigationLink("Hours Worked", destination: Text("Hours Worked"))
//                            NavigationLink("Get Paid", destination: Text("Get Paid"))
//                        }
                        
                        Section(header:  Label("Settings", systemImage: "gear")) {
                            NavigationLink("Edit Profile", destination: ProfileView()
                                            .environment(\.realmConfiguration,
                                                          app.currentUser!.configuration(partitionValue: "user=\(state.user?._id ?? "")")))
                        }
                    }
                    .navigationBarItems(leading: NavigationLink(
                        destination: allRequestView()
                            .environment(\.realmConfiguration,
                                          app.currentUser!.configuration(partitionValue: "public=public")),
                        label: {
                            MailBoxView()
                                .environment(\.realmConfiguration,
                                              app.currentUser!.configuration(partitionValue: "public=public"))
                        }), trailing: state.loggedIn ? LogoutButton() : nil)
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
    @EnvironmentObject var state: AppState
    
    @ObservedResults(Request.self) var requests
    
    @State private var timedOut = false
    
    @State private var companyName = ""
    
    @State private var goToMeView = false

    var filteredRequests: Results<Request> {
        return requests.filter(NSPredicate(format: "recipient == %@", state.user!.userName))
    }
    
    var receivedRequests: Results<Request> {
        return requests.filter(NSPredicate(format: "recipient == %@", state.user!.userName))
    }
    
    var sentRequests: Results<Request> {
        return requests.filter(NSPredicate(format: "sender == %@", state.user!.userName))
    }
    
    var hasRequest: Bool  {
        return receivedRequests.count > 0 || sentRequests.count > 0
    }
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    let now = Date()
    
    var body: some View {
        if state.user != nil {
            Section(header: Label("Company Invites", systemImage: "envelope")) {
//                if state.user?.companyID == "pending"  {
                    if receivedRequests.count < 1 && sentRequests.count < 1 && state.user?.companyID == "pending" && !timedOut {
                        HStack {
                            ProgressView()
                            Text("Looking for a pending request. Give us a moment to pull up the details.")
                        }
                        .onReceive(timer) { time in
                            if time > now.addingTimeInterval(10) {
                                timedOut = true
                            }
                        }
                    } else {
                        
                        if timedOut && !hasRequest  && state.loggedIn {
                            Text("You have no pending request at this time.")
                            NavigationLink("Request invite to existing business", destination: CompanyPickerView(companyName: $companyName, goToMeView: $goToMeView)
                                            .environment(\.realmConfiguration,
                                                          app.currentUser!.configuration(partitionValue: "public=public")))
                                .foregroundColor(.brandPrimary)
                        }
                        
                        if sentRequests.count > 0 {
                            VStack {
                                Text("Sent")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                ForEach(sentRequests) { request in
                                    if state.loggedIn {
                                        RequestView(request: request)
                                            .environment(\.realmConfiguration,
                                                          app.currentUser!.configuration(partitionValue: "public=public"))
                                    }
                                    
                                }
                            }
                        }
                        
                        if receivedRequests.count > 0 {
                            VStack {
                                Text("Received")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                ForEach(receivedRequests) { request in
                                    RequestView(request: request)
                                        .environment(\.realmConfiguration,
                                                      app.currentUser!.configuration(partitionValue: "public=public"))
                                    
                                }
                            }
                        }
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
