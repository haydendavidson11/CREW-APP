//
//  CompanyRequestsView.swift
//  COOL_NAME_HERE
//
//  Created by Hayden Davidson on 7/13/21.
//

import SwiftUI
import RealmSwift

struct CompanyRequestsView: View {
    
    @EnvironmentObject var state: AppState
    @Environment(\.realm) var publicRealm
    @Environment(\.presentationMode) var presentationMode
    
    @ObservedRealmObject var company: Company
    @ObservedResults(Request.self) var requests
    
    @State private var filter = ""
    
    
    var companyRequests: Results<Request> {
        print("\(requests.count) requests")
        return requests.filter(NSPredicate(format: "company == %@", company._id))
    }
    
    var filteredRequests: Results<Request> {
        print("\(requests.count) requests")
        if filter.isEmpty {
            return requests.filter(NSPredicate(format: "company == %@", company._id))
        } else {
            return companyRequests.filter(NSPredicate(format: "type == %@", filter))
        }
    }
    
    var body: some View {
        VStack {
            if filteredRequests.count > 0 {
                List {
                    ForEach(filteredRequests) { request in
                        RequestView(request: request)
                    }
                    .onDelete(perform: $requests.remove)
                }
            } else {
                Text("You have no request right now.")
                    .padding()
                
            }
        }
        .navigationTitle("Business Requests")
        .navigationBarItems(trailing: FilterButton(filter: $filter))
    }
}



struct RequestView_Previews: PreviewProvider {
    
    
    static var previews: some View {
        RequestView(request: Request())
    }
}

struct FilterButton: View {
    @Binding var filter: String
    
    var body: some View {
        Image(systemName: "line.horizontal.3.decrease.circle")
            .foregroundColor(.brandPrimary)
            .contextMenu(ContextMenu(menuItems: {
                Button("All Requests") {
                    filter = ""
                }
                Button("Invites") {
                    filter = RequestType.invite.asString
                }
                Button("Join Requests") {
                    filter = RequestType.join.asString
                }
                Button("Shift Requests") {
                    filter = RequestType.shift.asString
                }
                Button("Position Changes") {
                    filter = RequestType.roleChange.asString
                }
            }))
    }
}
