//
//  ShiftRequestListView.swift
//  ShiftRequestListView
//
//  Created by Hayden Davidson on 8/11/21.
//

import SwiftUI
import RealmSwift

struct ShiftRequestListView: View {
    @ObservedResults(Request.self) var requests
    @EnvironmentObject var state: AppState
    
    var filteredRequests: Results<Request> {
        let userRequest = requests.filter(NSPredicate(format: "crewMember == %@", state.user!.userName))
        return userRequest.filter(NSPredicate(format: "type == %@", "shift"))
    }
    
    var body: some View {
        Section {
            if filteredRequests.count < 1 {
                Text("No shift requests at this time.")
            } else {
                List {
                    ForEach(filteredRequests) { request in
                        RequestView(request: request)
                            .environment(\.realmConfiguration,
                                          app.currentUser!.configuration(partitionValue: "public=public"))
                            
                    }
                    .onDelete(perform: $requests.remove)
                }
            }
        }
        .navigationTitle("Shift Requests")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct ShiftRequestListView_Previews: PreviewProvider {
    static var previews: some View {
        ShiftRequestListView()
    }
}
