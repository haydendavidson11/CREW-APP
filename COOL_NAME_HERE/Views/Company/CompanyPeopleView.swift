//
//  CompanyPeopleView.swift
//  COOL_NAME_HERE
//
//  Created by Hayden Davidson on 6/15/21.
//

import SwiftUI
import RealmSwift

struct CompanyPeopleView: View {
    @EnvironmentObject var state: AppState
    @Environment(\.presentationMode) var presentationMode
    @ObservedResults(CrewMember.self) var crewMembers
    @ObservedRealmObject var company: Company
    
    
    @State private var showingAddPeopleView = false
    @State private var showingShareSheet = false
    
    
    let columns = [GridItem(.flexible()),
                   GridItem(.flexible()),
                   GridItem(.flexible())]
    
    var body: some View {
        VStack(alignment: .leading) {
            
            HStack {
                Text("Admins")
                    .bold()
                    .foregroundColor(.brandPrimary)
                    .font(.caption)
                Spacer()
            }
            
            
            
            if company.admins.count > 0 {
                LazyVGrid(columns: columns) {
                    ForEach(company.admins, id: \.self) { admin in
                        if let crewMember = crewMembers.first(where: { person in
                            person._id == admin
                        }) {
                            CrewMemberImageView(crewMember: crewMember)
                            
                        }
                    }
                    
                }
            } else {
                Text("No Admins found.")
                    .font(.caption)
                    .padding()
            }
            
            
            Divider()
                .padding()
            
            HStack {
                Text("Managers")
                    .bold()
                    .foregroundColor(.brandPrimary)
                    .font(.caption)
                Spacer()
            }
            
            
            
            if company.managers.count > 0 {
                LazyVGrid(columns: columns) {
                    ForEach(company.managers, id: \.self) { manager in
                        if let crewMember = crewMembers.first(where: { person in
                            person._id == manager
                        }) {
                            CrewMemberImageView(crewMember: crewMember)
                        }
                    }
                }
            } else {
                Text("No Managers found.")
                    .font(.caption)
                    .padding()
            }
            
            
            Divider()
                .padding()
            
            HStack {
                Text("Members")
                    .bold()
                    .foregroundColor(.brandPrimary)
                    .font(.caption)
                Spacer()
            }
            
            
            
            
            if company.members.count > 0 {
                LazyVGrid(columns: columns) {
                    ForEach(company.members, id: \.self) { member in
                        if let crewMember = crewMembers.first(where: { person in
                            person._id == member
                        }) {
                            CrewMemberImageView(crewMember: crewMember)
                        }
                    }
                }
            } else {
                Text("No Members found.")
                    .font(.caption)
                    .padding()
            }
            
            
            
            Spacer()
            
            
            
        }
        .padding()
        .navigationBarItems(trailing: company.admins.contains(state.user?._id ?? "") ? Button(action: {showingAddPeopleView = true}) {
            Image(systemName: "plus")
                .foregroundColor(.brandPrimary)
        } : nil)
        .navigationTitle("People")
        .navigationBarTitleDisplayMode(.inline)
        .accentColor(.brandPrimary)
        .sheet(isPresented: $showingAddPeopleView) {
            AddPeopleView()
                .environment(\.realmConfiguration,
                              app.currentUser!.configuration(partitionValue: "public=public"))
        }
        
    }
    
}


struct AddPeopleView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var state: AppState
    @Environment(\.realm) var publicRealm
    @ObservedResults(Request.self) var requests
    @ObservedResults(Company.self) var companies
    
    @State private var showingShareSheet = false
    
    @State private var email = ""
    
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var showingAlert = false
    @State private var roleSelection: Role = .member
    
    var userCompanyID: String {
        print("\(companies.count) companies available in add people view")
        let userCompany = companies.filter(NSPredicate(format: "_id == %@", state.user?.companyID ?? ""))
        
        if userCompany.count > 0 {
            print("Found senders Company")
            return userCompany.first!._id
        } else {
            print("Could not find a company matching the senders CompanyID")
            return "Unknown"
        }
        
    }
    
    let roles = ["Admin", "Member", "Manager"]
    
    
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "envelope")
                .resizable()
                .scaledToFit()
                .frame(width: 150, height: 150)
                .foregroundColor(.brandPrimary)
            
            Text("Enter the email and position of the person you'd like to invite to join your business.")
                .multilineTextAlignment(.center)
            TextField("Email", text: $email)
            
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
            
            
            
            CallToActionButton(title: "Send Invite", action: {
                sendInvite(to: email)
                showingShareSheet = true
                
            })
                .disabled(email.isEmpty)
        }
        .padding()
        .alert(isPresented: $showingAlert, content: {
            Alert(title: Text(alertTitle), message: Text(alertMessage), dismissButton: .default(Text("OK"), action: {
                email = ""
                self.presentationMode.wrappedValue.dismiss()}))
        })
        .sheet(isPresented: $showingShareSheet, onDismiss: {
            showingAlert = true
        }, content: {
            ShareSheet(activityItems: ["Join my business as a \(roleSelection) on Crew! Download the app, click 'Join existing business', create your account using \(email) as your userName and accept the invite on your account."])
        })
        
    }
    
    func sendInvite(to: String) {
        // TODO: Send invite to email listed.
        print("sent invite to \(email)")
        
        var companyName: String {
            var companyName = "Unknown"
            for company in companies {
                if company._id == userCompanyID {
                    companyName = company.companyName
                }
            }
            return companyName
        }
        
        let newRequest = Request()
        newRequest.sender = companyName
        newRequest.recipient = email
        newRequest.typeState = .invite
        newRequest.requestState = .pending
        newRequest.company = userCompanyID
        newRequest.crewMember = email
        newRequest.role = roleSelection.asString
        newRequest.requestDescription = "\(state.user?.userPreferences?.displayName ?? "") invited \(newRequest.crewMember!) to join \(companyName) as a \(newRequest.role ?? "")"
        
        $requests.append(newRequest)
        alertTitle = "Success!"
        alertMessage = "Invite sent to \(email)"
    }
}

struct CompanyPeopleView_Previews: PreviewProvider {
    static var previews: some View {
        CompanyPeopleView(company: Company())
    }
}


struct CrewMemberImageView: View {
    
    @State private var showingDetailView = false
    
    var crewMember: CrewMember
    var date: Date?
    
    var body: some View {
        VStack {
            AvatarThumbNailView(photo: crewMember.avatarImage ?? Photo(), imageSize: 80)
            Text(crewMember.displayName ?? "")
                .font(.caption)
                .foregroundColor(.brandPrimary)
        }
        .onTapGesture {
            self.showingDetailView = true
        }
        
        .sheet(isPresented: $showingDetailView, onDismiss: {self.showingDetailView = false}) {
            CrewMemberDetailView(crewMember: crewMember, date: date)
                .accentColor(.brandPrimary)
        }
    }
}
