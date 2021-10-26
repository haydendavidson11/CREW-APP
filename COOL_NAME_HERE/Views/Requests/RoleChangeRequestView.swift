//
//  RoleChangeRequestView.swift
//  COOL_NAME_HERE
//
//  Created by Hayden Davidson on 9/28/21.
//

import SwiftUI
import RealmSwift

struct RoleChangeRequestView: View {
    @EnvironmentObject var state: AppState
    @Environment(\.realm) var publicRealm
    
    @ObservedResults(CrewMember.self) var crewMembers
    @ObservedResults(Company.self) var companies
    @ObservedResults(Request.self) var requests
    
    @ObservedRealmObject var request: Request
    
    @State private var requestAccepted = false
    @State private var showingActionSheet = false
    @State private var actionSheetTitle = ""
    @State private var actionSheetMessage = ""
    
    // Gets the company associated with the request
    var requestCompany: Company? {
        return companies.first { company in
            company._id == request.company
        }
    }
    
    // Gets the crew Member associated with the request
    var crewMember: CrewMember? {
        print("\(crewMembers.count) crewMembers")
        return crewMembers.first { member in
            member._id == request.crewMember
        }
    }
    
    // Gets the name of the company associated with the request
    var companyName: String {
        var name = "Unknown"
        print("\(companies.count) companies")
        for company in companies {
            if company._id == request.company {
                name = company.companyName
            }
        }
        return name
    }
    
    // Sets the status image color depending on the request status
    var requestColor: Color {
        switch request.status {
        case "pending": return Color.yellow
        case "accepted":  return Color.green
        case "denied": return Color.red
        default:  return Color.yellow
        }
    }
    
    // Sets the status image depending on the request status
    var requestStatusImage: String {
        switch request.status {
        case "pending": return "questionmark.circle"
        case "accepted":  return "checkmark.circle"
        case "denied": return "x.circle"
        default:  return "questionmark.circle"
        }
    }
    
    
    // Checks if the current user is the request's recipient
    var isRecipient: Bool {
        let userCompany = companies.first { company in
            company._id == state.user?.companyID
        }
        
        if request.recipient == state.user?.userName || request.recipient == userCompany?.companyName {
            return true
        } else {
            return false
        }
    }
    
    // Checks if the current user is the request's sender
    var isSender: Bool {
        let userCompany = companies.first { company in
            company._id == state.user?.companyID
        }
        if request.sender == state.user?.userName || request.sender == userCompany?.companyName {
            return true
        } else {
            return false
        }
    }
    
    var requestBody: String {
        if request.status != "accepted" {
            
            return request.requestDescription
                                  
        } else {
            
            return "Position Accepted"
            }
        }
    
    

    
    var body: some View {
        HStack() {
            VStack(alignment: .leading, spacing: 5) {
                Text(request.sender ?? "Unknown")
                    .font(.headline)
                    .lineLimit(1)
                    .minimumScaleFactor(0.50)
                Text(requestBody)
                    .font(.caption)
                    .lineLimit(3)
                    .minimumScaleFactor(0.50)
            }
            Spacer()
            if request.status != "accepted" && request.company != state.user?.companyID {
                // request from user is either pending or declined
                Image(systemName: requestStatusImage)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 60)
                    .foregroundColor(requestColor)
                    .contextMenu {
                        if isRecipient {
                            Button("Accept") {
                                acceptRequest(for: request)
                                actionSheetTitle = "Accept the change of position?"
                                actionSheetMessage = "Your ability to edit, add, and delete company information will change."
                                self.showingActionSheet = true
                            }
                            Button("Decline", role: .destructive) {
                                denyRequest(for: request)
                            }
                        } else {
                            Button("Remove Request", role: .destructive) {
                                $requests.remove(request)
                            }
                            
                        }
                    }

            } else {
                // request has been approved
                Image(systemName: requestStatusImage)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 60)
                    .foregroundColor(requestColor)
                    .contextMenu {
                        if isRecipient {
                            Button("Accept") {
                                acceptRequest(for: request)
                                actionSheetTitle = "Accept the change of position?"
                                actionSheetMessage = "Your ability to edit, add, and delete company information will change."
                                self.showingActionSheet = true
                            }
                            Button("Decline", role: .destructive) {
                                denyRequest(for: request)
                            }
                        } else {
                            Button("Remove Request", role: .destructive) {
                                $requests.remove(request)
                            }
                            
                        }
                    }
            }

        }
        .actionSheet(isPresented: $showingActionSheet) {
            ActionSheet(title: Text(actionSheetTitle), message: Text(actionSheetMessage), buttons:
            [
                .default(Text("Accept"), action: {
                    state.loginPublisher.send(app.currentUser!)
                }),
                .cancel(Text("Cancel"), action: {
                    setRequestToPending(for: request)
                })
                    
            ])
        }
        
    }
    
    // Sets the request's status to "accepted"
    func acceptRequest(for: Request) {
        try! publicRealm.write {
            request.thaw()?.requestState = .accepted
        }
    }
    // Sets the request's status to "pending"
    func setRequestToPending(for: Request) {
        try! publicRealm.write {
            request.thaw()?.requestState = .pending
        }
    }
    
    // Sets the request's status to "denied"
    func denyRequest(for: Request) {
        try! publicRealm.write {
            request.thaw()?.requestState = .denied
        }
    }
}

struct RoleChangeRequestView_Previews: PreviewProvider {
    static var request = Request()
    
    static var previews: some View {
        RoleChangeRequestView(request: request)
    }
}
