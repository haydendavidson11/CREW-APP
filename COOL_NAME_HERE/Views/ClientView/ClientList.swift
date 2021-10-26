//
//  ClientList.swift
//  COOL_NAME_HERE
//
//  Created by Hayden Davidson on 4/8/21.
//

import SwiftUI
import RealmSwift

struct ClientList: View {
    @EnvironmentObject var state: AppState
    
    @ObservedResults(Client.self) var clients
    @ObservedResults(CrewMember.self) var crewMembers
    
    @State private var clientId = ""
    @State private var filterType: FilterOn = .firstName
    @State var searchFilter: String = ""
    
    @Binding var showingDetailSheet: Bool
    @Binding var  showingAddClientSheet: Bool
    
    
    private enum FilterOn: String {
        case firstName = "firstName"
        case lastName = "lastName"
        case email = "email"
        case phoneNumber = "phoneNumber"
        
        var asString: String {
            self.rawValue
        }
        
    }
    
    var canEditAndDelete: Bool {
        if state.user?.role == "Admin" {
            return true
        } else {
            return false
        }
    }
    
    var canAddClient: Bool {
        if state.user?.role == "Admin" || state.user?.role == "Manager" {
            return true
        } else {
            return false
        }
    }
    
    
    
    var filteredClients: Results<Client> {
        if searchFilter.isEmpty {
            return clients.sorted(byKeyPath: "firstName", ascending: true)
        } else {
            return clients.filter( NSPredicate(format: "\(filterType) CONTAINS[c] %@", searchFilter)).sorted(byKeyPath: "firstName", ascending: true)
        }
    }
    
    
    var body: some View {
        if state.loggedIn {
            VStack {
                if clients.isEmpty {
                    if canAddClient {
                        Text("Add clients by pressing the + button in the top right corner.")
                    } else {
                        Text("The business has no clients.")
                    }
                    
                } else {
                    VStack {
                        List{
                            ForEach(filteredClients, id: \.id) { client in
                                Button("\(client.firstName) \(client.lastName)") {
                                    state.shouldIndicateActivity = true
                                    self.clientId = client._id
                                    guard case self.clientId = client._id else {
                                        state.shouldIndicateActivity = false
                                        return }
                                    
                                    if self.clientId != "" {
                                        state.shouldIndicateActivity = false
                                        showingDetailSheet = true
                                    }
                                }
                            }.onDelete(perform: canEditAndDelete ? $clients.remove : nil)
                        }
                        .searchable(text: $searchFilter)
                        
                    }
                    
                }
                
            }
            .navigationTitle("Clients")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(leading: canEditAndDelete ? EditButton() : nil , trailing: canAddClient ? Button(action: {showingAddClientSheet = true }, label: {
                Image(systemName: "plus")
            }) : nil)
            .listStyle(SidebarListStyle())
            .sheet(isPresented: $showingDetailSheet, content: {
                CardView(client: clients.first(where: {$0._id == clientId}) ?? Client())
            })
            .environment(\.realmConfiguration,
                          app.currentUser!.configuration(partitionValue: "public=\(state.user?.companyID ?? "")"))
        }
    }
}

//struct ClientList_Previews: PreviewProvider {
//    static var previews: some View {
//        ClientList()
//    }
//}
