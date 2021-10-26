//
//  RoleChangeRequest.swift
//  COOL_NAME_HERE
//
//  Created by Hayden Davidson on 9/28/21.
//

import SwiftUI
import RealmSwift


struct RoleChangeRequest: View {
    @EnvironmentObject var state: AppState
    @Environment(\.realm) var publicRealm
    
    @ObservedResults(Request.self) var requests
    @ObservedResults(Company.self) var companies
    
    @State private var roleSelection: Role = .member
    @State private var showingActionSheet = false
    @State private var actionSheetTitle = ""
    @State private var actionSheetMessage = ""
    @State private var showingAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    
    var crewMember: CrewMember
    
    var body: some View {
        VStack {
            VStack {
                AvatarThumbNailView(photo: crewMember.avatarImage ?? Photo(), imageSize: 130)
                Text(crewMember.displayName ?? "")
                
                Text("Current Position")
                Text(crewMember.role ?? "Member")
                    .font(.subheadline)
                    .bold()
            }
            .padding(.bottom, 40)
            
            
            VStack {
                Text("Select New Position")
                Picker(roleSelection.asString, selection: $roleSelection) {
                    ForEach(Array(Role.allCases), id: \.self) {
                        Text($0.rawValue)
                    }
                }
                .pickerStyle(.segmented)
                
                
                if roleSelection == .admin {
                    Text("Admins have full access to create and edit client and job information, approve requests and send invites for the business.")
                        .multilineTextAlignment(.center)
                        .font(.caption)
                        .frame(height: 60)
                } else if roleSelection == .manager {
                    Text("Managers have full access to create and edit client and job information, create crews, and change job status.")
                        .multilineTextAlignment(.center)
                        .font(.caption)
                        .frame(height: 60)
                } else {
                    Text("Members can view business, client, and job information. They can edit their own information and approve requests sent to them.")
                        .multilineTextAlignment(.center)
                        .font(.caption)
                        .frame(height: 60)
                }
                
                CallToActionButton(title: "Send Request") {
                    actionSheetTitle = "Send Request?"
                    actionSheetMessage = "If \(crewMember.displayName ?? "Crew Member") accepts the change, their permissions to edit, add, and delete business information will change according to their new role"
                    showingActionSheet = true
                }
                
            }
            .padding(.vertical)
        }
        .padding()
        .actionSheet(isPresented: $showingActionSheet) {
            ActionSheet(title: Text(actionSheetTitle), message: Text(actionSheetMessage), buttons: [.default(Text("Send"), action: {
                // Send request for role change
                sendRequest()
            }), .cancel()])
        }
        .alert(isPresented: $showingAlert) {
            Alert(title: Text(alertTitle), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
        .onAppear {
            initData()
        }
    }
    
    func initData() {
        switch crewMember.role {
        case "Manager":
            self.roleSelection = .manager
        case "Admin":
            self.roleSelection = .admin
        default:
            self.roleSelection = .member
        }
    }
    
    func sendRequest() {
        
        var companyName: String {
            var companyName = "Unknown"
            for company in companies {
                if company._id == state.user?.companyID  {
                    companyName = company.companyName
                }
            }
            return companyName
        }
        
        let newRequest = Request()
        newRequest.sender = companyName
        newRequest.recipient = crewMember.userName
        newRequest.typeState = .roleChange
        newRequest.requestState = .pending
        newRequest.company = state.user?.companyID
        newRequest.crewMember = crewMember.userName
        newRequest.role = roleSelection.asString
        newRequest.requestDescription = "\(state.user?.userPreferences?.displayName ?? "") wants to change \(newRequest.crewMember ?? "")'s role from \(crewMember.role ?? "") to \(newRequest.role ?? "")"
        
        $requests.append(newRequest)
        alertTitle = "Success!"
        alertMessage = "Request sent to \(crewMember.displayName ?? "Crew Member")"
        showingAlert = true
        
    }
}

struct RoleChangeRequest_Previews: PreviewProvider {
    static var crewMember = CrewMember()
    
    static var previews: some View {
        RoleChangeRequest(crewMember: crewMember)
    }
}
