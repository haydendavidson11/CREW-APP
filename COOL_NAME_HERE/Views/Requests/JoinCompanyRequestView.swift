//
//  JoinCompanyRequestView.swift
//  JoinCompanyRequestView
//
//  Created by Hayden Davidson on 8/11/21.
//

import SwiftUI
import RealmSwift

struct JoinCompanyRequestView: View {
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
    
    var requestCompany: Company? {
        return companies.first { company in
            company._id == request.company
        }
    }
    
    var crewMember: CrewMember? {
        
        print("\(crewMembers.count) crewMembers")
        return crewMembers.first { member in
            member._id == request.crewMember
        }
    }
    
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
    
    
    var requestColor: Color {
        switch request.status {
        case "pending": return Color.yellow
        case "accepted":  return Color.green
        case "denied": return Color.red
        default:  return Color.yellow
        }
    }
    
    var requestStatusImage: String {
        switch request.status {
        case "pending": return "questionmark.circle"
        case "accepted":  return "checkmark.circle"
        case "denied": return "x.circle"
        default:  return "questionmark.circle"
        }
    }
    
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
            switch request.type {
            case "join" :
                if isSender {
                    return "You requested to join \(request.recipient ?? "Unknown")."
                } else {
                    return "\(request.sender ?? "Unknown") wants to join your business."
                }
            case "invite" :
                if isSender {
                    return "\(request.sender ?? "You") sent an invite to \(request.recipient ?? "Unknown")."
                } else {
                    return "\(request.sender ?? "Unknown") invited you to join their business."
                }
            case "shift" :
                return request.requestDescription
            default :
                return "There has been a problem with this request. Please delete it and send again."
            }
        } else {
            switch request.type {
            case "join" :
                if isSender {
                    return "Your request to join \(request.recipient ?? "Unknown") has been accepted!"
                } else {
                    return "You have accepted \(request.sender ?? "Unknown")'s request to join your business!"
                }
            case "invite" :
                if isSender {
                    return "Your invite to \(request.recipient ?? "Unknown") has been accepted!"
                } else {
                    return "You have accepted \(request.sender ?? "Unknown")'s invite to join their business."
                }
            case "shift" :
                return request.requestDescription
                
            default :
                return "There has been a problem with this request. Please delete it and send again."
            }
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
                                actionSheetTitle = "Accept and join \(request.sender ?? "Unknown")"
                                actionSheetMessage = "You will be directed to the business account."
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
                if request.type == "join" && isSender {
                    
                    Button("Join") {
                        actionSheetTitle = "Join \(request.sender ?? "")'s business?"
                        actionSheetMessage = "You will be directed to the business account."
                        showingActionSheet = true
                    }
                    .buttonStyle(BorderedButtonStyle())
                    
                } else {
                    Image(systemName: requestStatusImage)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 60)
                        .foregroundColor(requestColor)
                        .contextMenu {
                            if isRecipient {
                                Button("Accept") {
                                    acceptRequest(for: request)
                                    if request.type == "invite" {
                                        actionSheetTitle = "Accept and join \(request.sender ?? "")'s business"
                                        actionSheetMessage = "You will be directed to the business account."
                                    } else {
                                        actionSheetTitle = "Accept \(request.sender ?? "")'s request to join your business?"
                                        actionSheetMessage = "They will have access to your business as a member. you can change their position by selecting their avatar in the business's people list."
                                    }
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
            
        }
        .actionSheet(isPresented: $showingActionSheet) {
            ActionSheet(title: Text(actionSheetTitle), message: Text(actionSheetMessage), buttons:
                            [
                                .default(Text("Accept"), action: {
                                    print("Accepted request!")
                                    print("sending user")
                                    print(state.user?.companyID)
                                    state.loginPublisher.send(app.currentUser!)
                                    print("user sent")
                                    print(state.user?.companyID)
                                }),
                                .cancel(Text("Cancel"), action: {
                                    setRequestToPending(for: request)
                                })
                            ])
        }
        
    }
    
    func acceptRequest(for: Request) {
        try! publicRealm.write {
            if request.type == "join" {
                request.thaw()?.role = "Member"
            }
            request.thaw()?.requestState = .accepted
        }
        
    }
    
    func setRequestToPending(for: Request) {
        try! publicRealm.write {
            request.thaw()?.requestState = .pending
        }
    }
    
    func denyRequest(for: Request) {
        try! publicRealm.write {
            request.thaw()?.requestState = .denied
        }
    }
}

