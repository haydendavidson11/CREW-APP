//
//  CheckForCompanyView.swift
//  COOL_NAME_HERE
//
//  Created by Hayden Davidson on 6/14/21.
//

import SwiftUI
import RealmSwift

struct ConfirmCompanyView: View {
    @Environment(\.realm) var userRealm
    @EnvironmentObject var state: AppState
    @ObservedResults(Company.self) var companies
    @ObservedResults(Request.self) var requests
    
    let userID: String
    
    @State var company: Company?
    
    
    
    let inviteURL = URL(string: "https://www.apple.com")!
    
    @State private var companyName = ""
    
    @State private var goToMeView = false
    
    var body: some View {
        VStack {
            if state.loggedIn && goToMeView {
                MeView()
                    .environment(\.realmConfiguration,
                                  app.currentUser!.configuration(partitionValue: "user=\(state.user?._id ?? "")"))
            } else {
                
                if state.loggedIn && !state.setUpNewCompany {
                    VStack(spacing: 16){
                        Text("Looks like you aren't a part of any of our existing businesses")
                            .multilineTextAlignment(.center)
                        NavigationLink("Request invite to existing business", destination: CompanyPickerView(companyName: $companyName, goToMeView: $goToMeView)
                                        .environment(\.realmConfiguration,
                                                      app.currentUser!.configuration(partitionValue: "public=public")))
                            .foregroundColor(.brandPrimary)
                        
                        
                        Spacer()
                    }
                } else {
                    CompanySetUpView()
                        .environment(\.realmConfiguration,
                                      app.currentUser!.configuration(partitionValue: "public=public"))
                }
            }
        }.onAppear(perform: findCompany)
    }
    
    func findCompany() {
        print(companies.count)
        print(requests.count)
        
        guard let userName = state.user?.userName else { return  }
        let invite = requests.filter(NSPredicate(format: "recipient == %@", userName))
        if invite.count != 0 {
            setUserIdToPending()
            goToMeView = true
        }
        
    }
    
    func setUserIdToPending() {
        try! userRealm.write {
            state.user?.companyID = "pending"
            print("User Company Id Set to pending")
        }
    }
}

struct CheckForCompanyView_Previews: PreviewProvider {
    static var previews: some View {
        ConfirmCompanyView(userID: UUID().uuidString)
    }
}

struct CompanyPickerView: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.realm) var publicRealm
    @EnvironmentObject var state: AppState
    @ObservedResults(Company.self) var companies
    @ObservedResults(Request.self) var requests
    @Binding var companyName: String
    @Binding var goToMeView: Bool
    
    @State private var showingShareSheet = false
    
    @State private var searchFilter = ""
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var showingAlert = false

    var filteredCompanies: Results<Company> {
        if searchFilter != "" {
            return companies.filter(NSPredicate(format: "companyName CONTAINS[c] %@", searchFilter))
        } else {
            return companies
        }
    }
    
    var body: some View {
        
        VStack {
            if companies.count > 0 {
                List {
                    ForEach(filteredCompanies) { company in
                        Text(company.companyName)
                            .environment(\.realmConfiguration,
                                          app.currentUser!.configuration(partitionValue: "user=\(state.user?._id ?? "")"))
                            .onTapGesture {
                                self.companyName = company.companyName
                                sendRequest(to: companyName)
                                self.showingShareSheet = true
                                
                                
                            }
                    }
                }
                .searchable(text: $searchFilter)
                
            } else {
                ZStack {
                    ProgressView().progressViewStyle(CircularProgressViewStyle())
                    Text("Fetching Companies...")
                        .offset(y: -20)
                }
            }
        }
        .sheet(isPresented: $showingShareSheet, onDismiss: {self.showingAlert = true}, content: {
            ShareSheet(activityItems: ["I want to join your company on Crew! Log in to your account, go to the company tab, then tap on requests. Find the request from me then accept it with a long press."])
        })
        .alert(isPresented: $showingAlert, content: {
            Alert(title: Text(alertTitle), message: Text(alertMessage), dismissButton: .default(Text("OK"), action: {self.presentationMode.wrappedValue.dismiss()
                goToMeView = true
            }))
        })
        .navigationTitle("Select Company")
    }
    
    func sendRequest(to companyName: String) {
        
        let selectedCompany = companies.first { company in
            company.companyName == companyName
        }
        
        let newRequest = Request()
        newRequest.sender = state.user?.userName
        newRequest.recipient = companyName
        newRequest.typeState = .join
        newRequest.requestState = .pending
        newRequest.company = selectedCompany?._id
        newRequest.crewMember = state.user?.userName
        
        newRequest.requestDescription = "\(state.user?.userPreferences?.displayName ?? state.user!.userName) wants to join your company"
        
        
        try! publicRealm.write {
            $requests.append(newRequest)
            alertTitle = "Success!"
            alertMessage = "Invite sent to \(companyName)"
            print(state.user?.companyID)
        }
        print(state.user?.companyID)
        
        let userConfig =  app.currentUser!.configuration(partitionValue: "user=\(state.user?._id ?? "")")
        try! Realm(configuration: userConfig).write {
            state.user?.companyID = "pending"
            print(state.user?.companyID)
        }
        
    }
}
